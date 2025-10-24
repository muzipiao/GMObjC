//
//  GMSm2Bio.m
//  GMObjC_Example
//
//  Created by lifei on 2021/4/24.
//  Copyright © 2021 lifei. All rights reserved.
//

#import "GMSm2Bio.h"
#import "GMSm2Utils.h"
#import "GMSmUtils.h"
#import <openssl/sm2.h>
#import <openssl/bn.h>
#import <openssl/pem.h>
#import <openssl/evp.h>
#import <openssl/x509.h>
#import <openssl/pkcs12.h>

// 常见证书类型
typedef NS_ENUM(int, GMSm2CerType) {
    GMSm2CerTypeDER = 0,    // DER 格式证书
    GMSm2CerTypeCER,        // CER 格式证书
    GMSm2CerTypePEM,        // PEM 格式证书
    GMSm2CerTypePKCS12,     // PKCS#12 格式证书
    GMSm2CerTypeOTHER,      // 其他二进制格式证书
};

// SM2 公私钥对文件路径
@implementation GMSm2KeyFiles

- (NSString *)description {
    return [NSString stringWithFormat:@"%@,%@", self.publicKeyPath, self.privateKeyPath];
}

@end

// 读取的证书信息
@implementation GMSm2X509Info

- (NSString *)description {
    NSString *version = [NSString stringWithFormat:@"version:%@\n", self.version];
    NSString *publicKey = [NSString stringWithFormat:@"publicKey:%@\n", self.publicKey];
    NSString *privateKey = [NSString stringWithFormat:@"privateKey:%@\n", self.privateKey];
    NSString *effectiveDate = [NSString stringWithFormat:@"effectiveDate:%@\n", self.effectiveDate];
    NSString *expirationDate = [NSString stringWithFormat:@"expirationDate:%@\n", self.expirationDate];
    NSString *serialNumber = [NSString stringWithFormat:@"serialNumber:%@\n", self.serialNumber];
    NSString *signature = [NSString stringWithFormat:@"signature:%@\n", self.signature];
    NSString *signatureAlgorithm = [NSString stringWithFormat:@"signatureAlgorithm:%@\n", self.signatureAlgorithm];
    NSString *sha1Fingerprint = [NSString stringWithFormat:@"sha1Fingerprint:%@\n", self.sha1Fingerprint];
    NSString *sha256Fingerprint = [NSString stringWithFormat:@"sha256Fingerprint:%@\n", self.sha256Fingerprint];
    NSString *country = [NSString stringWithFormat:@"country:%@\n", self.country];
    NSString *commonName = [NSString stringWithFormat:@"commonName:%@\n", self.commonName];
    NSString *organization = [NSString stringWithFormat:@"organization:%@\n", self.organization];
    NSString *organizationalUnit = [NSString stringWithFormat:@"organizationalUnit:%@\n", self.organizationalUnit];
    NSString *issuerCountry = [NSString stringWithFormat:@"issuerCountry:%@\n", self.issuerCountry];
    NSString *issuerCommonName = [NSString stringWithFormat:@"issuerCommonName:%@\n", self.issuerCommonName];
    NSString *issuerOrganization = [NSString stringWithFormat:@"issuerOrganization:%@\n", self.issuerOrganization];
    NSString *issuerOrganizationalUnit = [NSString stringWithFormat:@"issuerOrganizationalUnit:%@\n", self.issuerOrganizationalUnit];
    
    NSString *infoString1 = [NSString stringWithFormat:@"%@%@%@%@%@%@", version, publicKey, privateKey, effectiveDate, expirationDate, serialNumber];
    NSString *infoString2 = [NSString stringWithFormat:@"%@%@%@%@", signature, signatureAlgorithm, sha1Fingerprint, sha256Fingerprint];
    NSString *infoString3 = [NSString stringWithFormat:@"%@%@%@%@", country, commonName, organization, organizationalUnit];
    NSString *infoString4 = [NSString stringWithFormat:@"%@%@%@%@", issuerCountry, issuerCommonName, issuerOrganization, issuerOrganizationalUnit];
    
    return [NSString stringWithFormat:@"%@%@%@%@", infoString1, infoString2, infoString3, infoString4]; // 证书的通用名称
}

@end

@implementation GMSm2Bio

// OpenSSL 1.1.1 以上版本支持国密
+ (void)initialize {
    if (self == [GMSm2Bio class]) {
        if (OPENSSL_VERSION_NUMBER < 0x1010100fL) {
            NSAssert1(NO, @"OpenSSL 版本低于 1.1.1，不支持国密，OpenSSL 当前版本：%s", OPENSSL_VERSION_TEXT);
        }
    }
}

// MARK: - 读取PEM格式秘钥
+ (nullable NSString *)readPublicKeyFromPemData:(NSData *)pemData password:(nullable NSData *)pwdData {
    if (pemData == nil || pemData.length == 0) {
        return nil;
    }
    // 判断是否为 X509 结构
    GMSm2X509Info *cerInfo = [self readX509InfoFromData:pemData password:pwdData];
    if (cerInfo.publicKey.length > 0) {
        return cerInfo.publicKey;
    }
    return [self readKeyFromPemData:pemData password:pwdData isPublicKey:YES];
}

+ (nullable NSString *)readPrivateKeyFromPemData:(NSData *)pemData password:(nullable NSData *)pwdData {
    if (pemData == nil || pemData.length == 0) {
        return nil;
    }
    // 判断是否为 X509 结构
    GMSm2X509Info *cerInfo = [self readX509InfoFromData:pemData password:pwdData];
    if (cerInfo.privateKey.length > 0) {
        return cerInfo.privateKey;
    }
    return [self readKeyFromPemData:pemData password:pwdData isPublicKey:NO];
}

+ (nullable NSString *)readKeyFromPemData:(NSData *)pemData password:(nullable NSData *)pwdData isPublicKey:(BOOL)isPublicKey {
    if (pemData == nil || pemData.length == 0) {
        return nil;
    }
    BIO *bio = BIO_new_mem_buf((void *)[pemData bytes], (int)[pemData length]);
    EC_KEY *key = NULL;
    NSString *result = nil;
    do {
        if (bio == NULL) {
            break;
        }
        if (isPublicKey) {
            PEM_read_bio_EC_PUBKEY(bio, &key, NULL, (void *)[pwdData bytes]);
        } else {
            PEM_read_bio_ECPrivateKey(bio, &key, NULL, (void *)[pwdData bytes]);
        }
        if (key == NULL) {
            break;
        }
        const EC_POINT *pub_key = EC_KEY_get0_public_key(key);
        const BIGNUM *pri_key = EC_KEY_get0_private_key(key);
        const EC_GROUP *group = EC_KEY_get0_group(key);
        
        if (isPublicKey) {
            char *hex_pub = EC_POINT_point2hex(group, pub_key, EC_KEY_get_conv_form(key), NULL);
            result = [NSString stringWithCString:hex_pub encoding:NSUTF8StringEncoding];
            OPENSSL_free(hex_pub);
        }else{
            char *hex_pri = BN_bn2hex(pri_key);
            result = [NSString stringWithCString:hex_pri encoding:NSUTF8StringEncoding];
            // 根据椭圆曲线的类型，依据椭圆曲线上的点获取私钥长度，不足前面补0
            size_t maxLen = ((EC_GROUP_get_degree(group) + 7) / 8) * 2;
            result = [GMSmUtils prefixPaddingZero:result maxLen:maxLen];
            if (hex_pri) { OPENSSL_free(hex_pri); }
        }
    } while (NO);
    // Free
    if (key) { EC_KEY_free(key); }
    if (bio) { BIO_free_all(bio); }
    
    return result;
}

// MARK: - 读取DER格式秘钥
+ (nullable NSString *)readPublicKeyFromDerData:(NSData *)derData {
    if (derData == nil || derData.length == 0) {
        return nil;
    }
    // 判断是否为 X509 结构
    GMSm2X509Info *cerInfo = [self readX509InfoFromData:derData password:nil];
    if (cerInfo.publicKey.length > 0) {
        return cerInfo.publicKey;
    }
    return [self readKeyFromDerData:derData isPublicKey:YES];
}

+ (nullable NSString *)readPrivateKeyFromDerData:(NSData *)derData {
    if (derData == nil || derData.length == 0) {
        return nil;
    }
    // 判断是否为 X509 结构
    GMSm2X509Info *cerInfo = [self readX509InfoFromData:derData password:nil];
    if (cerInfo.privateKey.length > 0) {
        return cerInfo.privateKey;
    }
    return [self readKeyFromDerData:derData isPublicKey:NO];
}

+ (nullable NSString *)readKeyFromDerData:(NSData *)derData isPublicKey:(BOOL)isPublicKey {
    if (derData == nil || derData.length == 0) {
        return nil;
    }
    BIO *bio = BIO_new_mem_buf((void *)[derData bytes], (int)[derData length]);
    EC_KEY *key = NULL;
    NSString *result = nil;
    do {
        if (bio == NULL) {
            break;
        }
        if (isPublicKey) {
            d2i_EC_PUBKEY_bio(bio, &key);
        }else{
            d2i_ECPrivateKey_bio(bio, &key);
        }
        if (key == NULL) {
            break;
        }
        const EC_POINT *pub_key = EC_KEY_get0_public_key(key);
        const BIGNUM *pri_key = EC_KEY_get0_private_key(key);
        const EC_GROUP *group = EC_KEY_get0_group(key);
        
        if (isPublicKey) {
            char *hex_pub = EC_POINT_point2hex(group, pub_key, EC_KEY_get_conv_form(key), NULL);
            result = [NSString stringWithCString:hex_pub encoding:NSUTF8StringEncoding];
            OPENSSL_free(hex_pub);
        }else{
            char *hex_pri = BN_bn2hex(pri_key);
            result = [NSString stringWithCString:hex_pri encoding:NSUTF8StringEncoding];
            // 根据椭圆曲线的类型，依据椭圆曲线上的点获取私钥长度，不足前面补0
            size_t maxLen = ((EC_GROUP_get_degree(group) + 7) / 8) * 2;
            result = [GMSmUtils prefixPaddingZero:result maxLen:maxLen];
            if (hex_pri) { OPENSSL_free(hex_pri); }
        }
    } while (NO);
    // Free
    if (key) { EC_KEY_free(key); }
    if (bio) { BIO_free_all(bio); }
    
    return result;
}

// MARK: - 写入PEM/DER格式文件
+ (BOOL)savePublicKey:(NSString *)publicHex toPemFileAtPath:(NSString *)filePath {
    return [self savePubKeyToFile:publicHex filePath:filePath pemType:YES];
}

+ (BOOL)savePrivateKey:(NSString *)privateHex toPemFileAtPath:(NSString *)filePath {
    return [self savePriKeyToFile:privateHex filePath:filePath pemType:YES];
}

+ (BOOL)savePublicKey:(NSString *)publicHex toDerFileAtPath:(NSString *)filePath {
    return [self savePubKeyToFile:publicHex filePath:filePath pemType:NO];
}

+ (BOOL)savePrivateKey:(NSString *)privateHex toDerFileAtPath:(NSString *)filePath {
    return [self savePriKeyToFile:privateHex filePath:filePath pemType:NO];
}

+ (BOOL)savePubKeyToFile:(NSString *)publicKey filePath:(NSString *)filePath pemType:(BOOL)pemType {
    if (publicKey.length == 0 || filePath.length == 0 ) {
        return NO;
    }
    const char *file_path = filePath.UTF8String;
    FILE *fp = fopen(file_path, "w");
    if (fp == NULL) {
        return NO;
    }
    const char *public_key = publicKey.UTF8String;
    EC_GROUP *group = EC_GROUP_new_by_curve_name([GMSm2Utils curveType]);
    EC_KEY *key = NULL;
    EC_POINT *pub_point = NULL;
    BOOL success = YES;
    do {
        key = EC_KEY_new();
        if (!EC_KEY_set_group(key, group)) {
            success = NO;
            break;
        }
        pub_point = EC_POINT_new(group);
        EC_POINT_hex2point(group, public_key, pub_point, NULL);
        if (!EC_KEY_set_public_key(key, pub_point)) {
            success = NO;
            break;
        }
        EC_KEY_set_asn1_flag(key, OPENSSL_EC_NAMED_CURVE);
        if (pemType == YES) {
            if (!PEM_write_EC_PUBKEY(fp, key)) {
                success = NO;
            }
        }else{
            if (!i2d_EC_PUBKEY_fp(fp, key)) {
                success = NO;
            }
        }
    } while (NO);
    // Free
    if (group) { EC_GROUP_free(group); }
    if (key) { EC_KEY_free(key); }
    if (pub_point) { EC_POINT_free(pub_point); }
    fclose(fp);
    
    return success;
}

+ (BOOL)savePriKeyToFile:(NSString *)privateKey filePath:(NSString *)filePath pemType:(BOOL)pemType{
    if (privateKey.length == 0 || filePath.length == 0 ) {
        return NO;
    }
    const char *file_path = filePath.UTF8String;
    FILE *fp = fopen(file_path, "w");
    if (fp == NULL) {
        return NO;
    }
    const char *private_key = privateKey.UTF8String;
    EC_GROUP *group = EC_GROUP_new_by_curve_name([GMSm2Utils curveType]);
    EC_POINT *pub_point = NULL;
    BIGNUM *pri_num = NULL;
    EC_KEY *key = NULL;
    BOOL success = YES;
    
    do {
        if (!BN_hex2bn(&pri_num, private_key)) {
            success = NO;
            break;
        }
        key = EC_KEY_new();
        if (!EC_KEY_set_group(key, group)) {
            success = NO;
            break;
        }
        if (!EC_KEY_set_private_key(key, pri_num)) {
            success = NO;
            break;
        }
        pub_point = EC_POINT_new(group);
        if (!EC_POINT_mul(group, pub_point, pri_num, NULL, NULL, NULL)) {
            success = NO;
            break;
        }
        if (!EC_KEY_set_public_key(key, pub_point)) {
            success = NO;
            break;
        }
        if (pemType == YES) {
            if (!PEM_write_ECPrivateKey(fp, key, NULL, NULL, 0, NULL, NULL)) {
                success = NO;
            }
        }else{
            if (!i2d_ECPrivateKey_fp(fp, key)) {
                success = NO;
            }
        }
    } while (NO);
    // Free
    if (group) { EC_GROUP_free(group); }
    if (pub_point) { EC_POINT_free(pub_point); }
    if (pri_num) { BN_free(pri_num); }
    if (key) { EC_KEY_free(key); }
    fclose(fp);
    
    return success;
}

// MARK: - 创建PEM/DER格式公私钥
+ (GMSm2KeyFiles *)generatePemKeyFiles {
    NSString *pubFileName = [NSString stringWithFormat:@"sm2-%@-pub.pem", [NSUUID UUID].UUIDString];
    NSString *priFileName = [NSString stringWithFormat:@"sm2-%@-pri.pem", [NSUUID UUID].UUIDString];
    return [self createPubFile:pubFileName priFile:priFileName];
}

+ (GMSm2KeyFiles *)generateDerKeyFiles {
    NSString *pubFileName = [NSString stringWithFormat:@"sm2-%@-pub.der", [NSUUID UUID].UUIDString];
    NSString *priFileName = [NSString stringWithFormat:@"sm2-%@-pri.der", [NSUUID UUID].UUIDString];
    return [self createPubFile:pubFileName priFile:priFileName];
}

+ (GMSm2KeyFiles *)createPubFile:(NSString *)pubFileName priFile:(NSString *)priFileName {
    GMSm2KeyFiles *keyFiles = [[GMSm2KeyFiles alloc] init];
    BOOL isPem = [pubFileName.lowercaseString hasSuffix:@".pem"] && [priFileName.lowercaseString hasSuffix:@".pem"];
    BOOL isDer = [pubFileName.lowercaseString hasSuffix:@".der"] && [priFileName.lowercaseString hasSuffix:@".der"];
    if (isPem == NO && isDer == NO) {
        return keyFiles;
    }
    // 公私钥写入文件
    NSString *tmpPath = NSTemporaryDirectory();
    NSString *pubPath = [tmpPath stringByAppendingPathComponent:pubFileName];
    NSString *priPath = [tmpPath stringByAppendingPathComponent:priFileName];
    FILE *fpPub = fopen(pubPath.UTF8String, "w");
    if (fpPub == NULL) {
        return keyFiles;
    }
    FILE *fpPri = fopen(priPath.UTF8String, "w");
    if (fpPri == NULL) {
        fclose(fpPub);
        return keyFiles;
    }
    
    EC_GROUP *group = EC_GROUP_new_by_curve_name([GMSm2Utils curveType]);
    EC_KEY *key = NULL; // 密钥对
    BOOL success = YES;
    do {
        key = EC_KEY_new();
        if (!EC_KEY_set_group(key, group)) {
            success = NO;
            break;
        }
        if (!EC_KEY_generate_key(key)) {
            success = NO;
            break;
        }
        if (isPem == YES) {
            if (!PEM_write_EC_PUBKEY(fpPub, key)) {
                success = NO;
                break;
            }
            if (!PEM_write_ECPrivateKey(fpPri, key, NULL, NULL, 0, NULL, NULL)) {
                success = NO;
                break;
            }
        }else{
            if (!i2d_EC_PUBKEY_fp(fpPub, key)) {
                success = NO;
                break;
            }
            
            if (!i2d_ECPrivateKey_fp(fpPri, key)) {
                success = NO;
                break;
            }
        }
    } while (NO);
    
    if (success == YES) {
        keyFiles.publicKeyPath = pubPath;
        keyFiles.privateKeyPath = priPath;
    }
    // Free
    if (group) { EC_GROUP_free(group); }
    if (key) { EC_KEY_free(key); }
    fclose(fpPub);
    fclose(fpPri);
    
    return keyFiles;
}

// MARK: - PEM & DER 互转
/// 将 PEM 格式公私钥转换为 DER 格式
/// @param pemData PEM格式密钥数据
/// @param isPublicKey 标记 derData 是公钥/私钥，YES为公钥，NO为私钥
+ (nullable NSData *)convertPemToDer:(NSData *)pemData isPublicKey:(BOOL)isPublicKey {
    if (pemData == nil || pemData.length == 0) {
        return nil;
    }
    // 将 PEM 格式数据转换为 OpenSSL 的 BIO 对象
    BIO *bio = BIO_new_mem_buf((void *)[pemData bytes], (int)[pemData length]);
    BIO *derBio = BIO_new(BIO_s_mem()); // 创建一个内存 BIO，用于存储 DER 格式数据
    EC_KEY *key = NULL; // 根据类型创建 OpenSSL 的 EC_KEY 对象
    NSData *derData = nil;
    do {
        if (bio == NULL || derBio == NULL) {
            break;
        }
        if (isPublicKey) {
            PEM_read_bio_EC_PUBKEY(bio, &key, NULL, NULL);
        } else {
            PEM_read_bio_ECPrivateKey(bio, &key, NULL, NULL);
        }
        if (key == NULL) {
            break;
        }
        // 将公私钥对象写入 DER 格式的内存 BIO 中
        if (isPublicKey) {
            i2d_EC_PUBKEY_bio(derBio, key);
        } else {
            i2d_ECPrivateKey_bio(derBio, key);
        }
        // 从 DER 格式的内存 BIO 中读取数据
        char *derDataBuffer = NULL;
        long derDataLength = BIO_get_mem_data(derBio, &derDataBuffer);
        if (derDataBuffer && derDataLength > 0) {
            derData = [NSData dataWithBytes:derDataBuffer length:derDataLength];
        }
    } while (NO);
    // Free
    if (key) { EC_KEY_free(key); }
    if (bio) { BIO_free_all(bio); }
    if (derBio) { BIO_free_all(derBio); }
    
    return derData;
}

/// 将 DER 格式公私钥转换为 PEM 格式
/// @param derData DER格式密钥数据
/// @param isPublicKey 标记 derData 是公钥/私钥，YES为公钥，NO为私钥
+ (nullable NSData *)convertDerToPem:(NSData *)derData isPublicKey:(BOOL)isPublicKey {
    if (derData == nil || derData.length == 0) {
        return nil;
    }
    // 将 DER 格式数据读入 OpenSSL 的内存 BIO 对象
    BIO *bio = BIO_new_mem_buf((void *)[derData bytes], (int)[derData length]);
    BIO *pemBio = BIO_new(BIO_s_mem()); // 创建一个内存 BIO，用于存储 PEM 格式数据
    EC_KEY *key = EC_KEY_new(); // 根据类型创建 OpenSSL 的 EC_KEY 对象
    NSData *pemData = nil;
    do {
        if (!bio || !pemBio) {
            break;
        }
        if (isPublicKey) {
            d2i_EC_PUBKEY_bio(bio, &key);
        } else {
            d2i_ECPrivateKey_bio(bio, &key);
        }
        if (!key) {
            break;
        }
        // 将公私钥对象写入 PEM 格式的内存 BIO 中
        if (isPublicKey) {
            PEM_write_bio_EC_PUBKEY(pemBio, key);
        } else {
            PEM_write_bio_ECPrivateKey(pemBio, key, NULL, NULL, 0, NULL, NULL);
        }
        // 从 PEM 格式的内存 BIO 中读取数据
        char *pemDataBuffer = NULL;
        long pemDataLength = BIO_get_mem_data(pemBio, &pemDataBuffer);
        if (pemDataBuffer && pemDataLength > 0) {
            pemData = [NSData dataWithBytes:pemDataBuffer length:pemDataLength];
        }
    } while (NO);
    // Free
    if (key) { EC_KEY_free(key); }
    if (bio) { BIO_free_all(bio); }
    if (pemBio) { BIO_free_all(pemBio); }
    
    return pemData;
}

// MARK: - 读取证书
/// 从证书文件中读取证书信息
/// @param cerData 证书文件数据
/// @param pwdData 证书密码，默认为空
+ (nullable GMSm2X509Info *)readX509InfoFromData:(NSData *)cerData password:(nullable NSData *)pwdData {
    if (cerData == nil || cerData.length == 0) {
        return nil;
    }
    const unsigned char *certBytes = (const unsigned char *)[cerData bytes];
    size_t dataLength = (size_t)[cerData length];
    // 读取证书类型，证书类型，PEM、CER、DER、PKCS#12等格式
    GMSm2CerType cerType = [self readCerTypeFromData:cerData];
    GMSm2X509Info *cerInfo = [[GMSm2X509Info alloc] init];
    X509 *x509 = NULL;
    switch (cerType) {
        case GMSm2CerTypePEM: {
            BIO *pemBio = BIO_new_mem_buf((void *)[cerData bytes], (int)dataLength);
            x509 = PEM_read_bio_X509(pemBio, NULL, NULL, (void *)[pwdData bytes]);
            if (pemBio) {
                BIO_free(pemBio);
            }
            break;
        }
        case GMSm2CerTypePKCS12: {
            PKCS12 *p12 = d2i_PKCS12(NULL, &certBytes, (long)dataLength);
            if (p12 == NULL) {
                break;
            }
            EVP_PKEY *privateKey = NULL; // PKCS#12解析的私钥，returns 1 for success and zero if an error occurred.
            int pkcs12Ret = PKCS12_parse(p12, (const char *)[pwdData bytes], &privateKey, &x509, NULL);
            if (pkcs12Ret == 1) {
                cerInfo.privateKey = [self readCerPrivateKeyFromEvpKey:privateKey]; // PKCS#12 解析私钥
            }
            if (privateKey) { EVP_PKEY_free(privateKey); }
            if (p12) { PKCS12_free(p12); }
            break;
        }
        default:
            x509 = d2i_X509(NULL, &certBytes, (long)dataLength); // DER 和 CER 等二进制格式
            break;
    }
    if (!x509) {
        return nil; // x509 读取失败
    }
    cerInfo.version = [self readCerVersionFromX509:x509];                                   // 证书的版本号
    cerInfo.publicKey = [self readCerPublicKeyFromX509:x509];                               // 公钥(HEX 格式)
    cerInfo.effectiveDate = [self readCerDateFromX509:x509 isEffectiveDate:YES];            // 生效日期 yyMMddHHmmssZ
    cerInfo.expirationDate = [self readCerDateFromX509:x509 isEffectiveDate:NO];            // 失效日期 yyMMddHHmmssZ
    cerInfo.serialNumber = [self readCerSerialNumberFromX509:x509];                         // 证书的序列号
    cerInfo.signature = [self readCerSignatureFromX509:x509];                               // 签名算法的值
    cerInfo.signatureAlgorithm = [self readCerSignatureAlgorithmFromX509:x509];             // 签名算法类型
    cerInfo.sha1Fingerprint = [self readCerFingerprintFromX509:x509 type:EVP_sha1()];       // 指纹(SHA-1)
    cerInfo.sha256Fingerprint = [self readCerFingerprintFromX509:x509 type:EVP_sha256()];   // 指纹(SHA-256)
    cerInfo.country = [self readCerInfoFromX509:x509 byNID:NID_countryName isIssuer:NO];                                // 证书的国家代码
    cerInfo.commonName = [self readCerInfoFromX509:x509 byNID:NID_commonName isIssuer:NO];                              // 证书的通用名称
    cerInfo.organization = [self readCerInfoFromX509:x509 byNID:NID_organizationName isIssuer:NO];                      // 证书的组织名称
    cerInfo.organizationalUnit = [self readCerInfoFromX509:x509 byNID:NID_organizationalUnitName isIssuer:NO];          // 证书的组织单位名称
    cerInfo.issuerCountry = [self readCerInfoFromX509:x509 byNID:NID_countryName isIssuer:YES];                         // 颁发机构的国家代码
    cerInfo.issuerCommonName = [self readCerInfoFromX509:x509 byNID:NID_commonName isIssuer:YES];                       // 颁发机构的通用名称
    cerInfo.issuerOrganization = [self readCerInfoFromX509:x509 byNID:NID_organizationName isIssuer:YES];               // 颁发机构的组织名称
    cerInfo.issuerOrganizationalUnit = [self readCerInfoFromX509:x509 byNID:NID_organizationalUnitName isIssuer:YES];   // 颁发机构的组织单位名称
    // Free
    if (x509) { X509_free(x509); }
    
    return cerInfo;
}

// 读取 X509 证书的版本号，版本号的实际值是 version + 1，因为版本号从0开始计数
+ (nullable NSString *)readCerVersionFromX509:(const X509 *)x509 {
    if (!x509) {
        return 0;
    }
    long version = X509_get_version(x509) + 1;
    return [NSString stringWithFormat:@"%ld", version];
}

// 从 EVP_PKEY 读取私钥字符串
+ (nullable NSString *)readCerPrivateKeyFromEvpKey:(EVP_PKEY *)evpKey {
    if (!evpKey) {
        return nil;
    }
    BIO *privateBio = BIO_new(BIO_s_mem()); // 读取私钥到内存中
    if (!privateBio) {
        return nil;
    }
    int privateRet = PEM_write_bio_PrivateKey(privateBio, evpKey, NULL, NULL, 0, NULL, NULL);
    if (privateRet == 0) {
        BIO_free(privateBio);
        return nil;
    }
    NSString *privateString = nil;
    char *privateDataBuffer = NULL;
    long privateDataLength = BIO_get_mem_data(privateBio, &privateDataBuffer);
    if (privateDataBuffer && privateDataLength > 0) {
        NSData *privateData = [NSData dataWithBytes:privateDataBuffer length:privateDataLength];
        privateString = [GMSmUtils hexStringFromData:privateData];
    }
    // Free
    if (privateBio) { BIO_free(privateBio); }
    
    return privateString;
}

// 从 X509 数据中读取公钥
+ (nullable NSString *)readCerPublicKeyFromX509:(X509 *)x509 {
    if (!x509) {
        return nil;
    }
    EVP_PKEY *publicKey = X509_get_pubkey(x509);
    if (!publicKey) { return nil; }
    unsigned char *publicBytes = NULL;  // 获取公钥的 ASN.1 编码
    int publicLen = i2d_PublicKey(publicKey, &publicBytes);
    if (publicLen < 0) {
        EVP_PKEY_free(publicKey);
        return nil;
    }
    NSData *publicData = [NSData dataWithBytes:publicBytes length:publicLen];
    NSString *publicString = [GMSmUtils hexStringFromData:publicData];
    if (publicKey) { EVP_PKEY_free(publicKey); }
    
    return publicString;
}

/// 从 X509 数据中读取【生效日期】和【失效日期】，日期格式(UTC时间) yyyyMMddHHmmss
/// @param x509 X509 数据
/// @param isEffectiveDate 从 X509 数据中读取【生效日期】和【失效日期】
+ (nullable NSString *)readCerDateFromX509:(X509 *)x509 isEffectiveDate:(BOOL)isEffectiveDate {
    if (!x509) {
        return nil;
    }
    ASN1_TIME *cerTime = isEffectiveDate ? X509_get_notBefore(x509) : X509_get_notAfter(x509);
    if (!cerTime) {
        return nil;
    }
    int bufferLength = ASN1_STRING_length(cerTime);
    uint8_t *buffer = (uint8_t *)OPENSSL_zalloc(bufferLength + 1);
    if (!buffer) {
        return nil;
    }
    int resultLen = ASN1_STRING_to_UTF8(&buffer, cerTime);
    if (resultLen <= 0) {
        OPENSSL_free(buffer);
        return nil;
    }
    NSString *asn1TimeString = [[NSString alloc] initWithBytes:buffer length:bufferLength encoding:NSUTF8StringEncoding];
    NSDateFormatter *asn1DateFormatter = [[NSDateFormatter alloc] init];
    [asn1DateFormatter setDateFormat:@"yyMMddHHmmss'Z'"];
    NSDate *asn1Date = [asn1DateFormatter dateFromString:asn1TimeString];
    
    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
    [outputDateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *outputDateString = [outputDateFormatter stringFromDate:asn1Date];
    // Free
    if (buffer) { OPENSSL_free(buffer); }
    
    return outputDateString;
}

// 读取证书的序列号
+ (nullable NSString *)readCerSerialNumberFromX509:(X509 *)x509 {
    if (!x509) {
        return nil;
    }
    ASN1_INTEGER *serialNumber = X509_get_serialNumber(x509);
    if (!serialNumber) {
        return nil;
    }
    BIGNUM *bnSerialNumber = ASN1_INTEGER_to_BN(serialNumber, NULL);
    if (!bnSerialNumber) {
        return nil;
    }
    char *hexSerialNumber = BN_bn2hex(bnSerialNumber);
    if (!hexSerialNumber) {
        BN_free(bnSerialNumber);
        return nil;
    }
    NSString *serialNumberString = [NSString stringWithUTF8String:hexSerialNumber];
    // Free
    if (hexSerialNumber) { OPENSSL_free(hexSerialNumber); }
    if (bnSerialNumber) { BN_free(bnSerialNumber); }
    
    return serialNumberString;
}

// 读取签名值
+ (nullable NSString *)readCerSignatureFromX509:(X509 *)x509 {
    if (!x509) {
        return nil;
    }
    const ASN1_BIT_STRING *signatureBitString;
    X509_get0_signature(&signatureBitString, NULL, x509);
    if (!signatureBitString) {
        return nil;
    }
    const unsigned char *signatureBytes = signatureBitString->data;
    NSUInteger signatureLength = signatureBitString->length;
    NSData *signatureData = [NSData dataWithBytes:signatureBytes length:signatureLength];
    NSString *signature = [GMSmUtils hexStringFromData:signatureData];
    return signature;
}

// 读取签名算法
+ (nullable NSString *)readCerSignatureAlgorithmFromX509:(X509 *)x509 {
    if (!x509) {
        return nil;
    }
    const X509_ALGOR *x509Algor = X509_get0_tbs_sigalg(x509);
    if (!x509Algor) {
        return nil;
    }
    const ASN1_OBJECT *signatureAlgorithmASN1;
    X509_ALGOR_get0(&signatureAlgorithmASN1, NULL, NULL, x509Algor);
    if (!signatureAlgorithmASN1) {
        return nil;
    }
    const char *signatureAlgorithmName = OBJ_nid2sn(OBJ_obj2nid(signatureAlgorithmASN1));
    if (!signatureAlgorithmName) {
        return nil;
    }
    NSString *signatureAlgorithm = [NSString stringWithUTF8String:signatureAlgorithmName];
    return signatureAlgorithm;
}

// 读取指纹(SHA-1或SHA-256等等)
+ (nullable NSString *)readCerFingerprintFromX509:(X509 *)x509 type:(const EVP_MD *)type {
    if (!x509) {
        return nil;
    }
    unsigned char buffer[EVP_MAX_MD_SIZE];
    memset(buffer, 0, sizeof(buffer));
    unsigned int bufferLen = sizeof(buffer);
    int digestRet = X509_digest(x509, type, buffer, &bufferLen);
    if (digestRet == 0 || bufferLen <= 0) {
        return nil;
    }
    NSData *digestData = [NSData dataWithBytes:buffer length:bufferLen];
    NSString *digestString = [GMSmUtils hexStringFromData:digestData];
    return digestString;
}

/// 通过 NID 读取证书证书信息，包括国家代码、通用名称、组织名称，组织单位名称。
/// @param x509 X509 对象指针
/// @param nid NID 的值，包括 NID_countryName、NID_commonName、NID_organizationName，NID_organizationalUnitName
/// @param isIssuer 是否为颁布机构信息，YES 颁发机构信息，NO 证书信息
+ (nullable NSString *)readCerInfoFromX509:(X509 *)x509 byNID:(int)nid isIssuer:(BOOL)isIssuer {
    if (!x509) {
        return nil;
    }
    X509_NAME *subjectName = isIssuer ? X509_get_issuer_name(x509) : X509_get_subject_name(x509);
    if (!subjectName) {
        return nil;
    }
    int bufferLength = X509_NAME_get_text_by_NID(subjectName, nid, NULL, 0);
    if (bufferLength <= 0) {
        return nil;
    }
    char *buffer = (char *)OPENSSL_zalloc(bufferLength + 1);
    if (!buffer) {
        return nil;
    }
    // 实际的缓冲区包含空字符（'\0'）在内
    int actualLength = X509_NAME_get_text_by_NID(subjectName, nid, buffer, bufferLength + 1);
    if (actualLength != bufferLength) {
        OPENSSL_free(buffer);
        return nil;
    }
    NSString *bufferString = [NSString stringWithUTF8String:buffer];
    // Free
    if (buffer) { OPENSSL_free(buffer); }
    
    return bufferString;
}

// 判断证书类型
+ (GMSm2CerType)readCerTypeFromData:(NSData *)cerData {
    if (cerData.length == 0) {
        return GMSm2CerTypeOTHER;
    }
    // 判断是否为 PEM 格式
    NSString *cerString = [[NSString alloc] initWithData:cerData encoding:NSUTF8StringEncoding];
    if ([cerString containsString:@"-----BEGIN"] && [cerString containsString:@"-----END"]) {
        return GMSm2CerTypePEM; // PEM 格式
    }
    const unsigned char *dataBytes = cerData.bytes;
    size_t dataLength = (size_t)[cerData length];
    // 判断是否为 PKCS#12 格式
    PKCS12 *p12 = d2i_PKCS12(NULL, &dataBytes, (long)dataLength);
    if (p12) {
        PKCS12_free(p12);
        return GMSm2CerTypePKCS12;
    }
    // 判断是否为 DER 格式
    X509 *x509 = d2i_X509(NULL, &dataBytes, (long)dataLength);
    if (x509) {
        X509_free(x509);
        return GMSm2CerTypeDER;
    }
    // 默认返回CER格式
    return GMSm2CerTypeCER;
}

@end
