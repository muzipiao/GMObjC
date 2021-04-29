//
//  GMSm2Bio.m
//  GMObjC_Example
//
//  Created by lifei on 2021/4/24.
//  Copyright © 2021 lifei. All rights reserved.
//

#import "GMSm2Bio.h"
#import <openssl/sm2.h>
#import <openssl/bn.h>
#import <openssl/pem.h>
#import "GMUtils.h"

// 默认椭圆曲线类型 NID_sm2
static int kDefaultBioEllipticCurveType = NID_sm2;

@implementation GMSm2Bio

// OpenSSL 1.1.1 以上版本支持国密
+ (void)initialize
{
    if (self == [GMSm2Bio class]) {
        if (OPENSSL_VERSION_NUMBER < 0x1010100fL) {
            GMLog(@"OpenSSL 当前版本：%s",OPENSSL_VERSION_TEXT);
            NSAssert(NO, @"OpenSSL 版本低于 1.1.1，不支持国密");
        }
    }
}

///MARK: - 读取PEM格式秘钥

+ (nullable NSString *)readPublicKeyFromPemFile:(NSString *)filePath {
    NSString *pemStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return [self readKeyFromPemString:pemStr];
}

+ (nullable NSString *)readPrivateKeyFromPemFile:(NSString *)filePath {
    NSString *pemStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return [self readKeyFromPemString:pemStr];
}

+ (nullable NSString *)readPublicKeyFromPemString:(NSString *)pemStr {
    return [self readKeyFromPemString:pemStr];
}

+ (nullable NSString *)readPrivateKeyFromPemString:(NSString *)pemStr {
    return [self readKeyFromPemString:pemStr];
}

+ (nullable NSString *)readKeyFromPemString:(NSString *)pemStr {
    if (pemStr.length == 0) {
        return nil;
    }
    BOOL isHasPublic = [pemStr containsString:@"PUBLIC KEY"];
    NSAssert(isHasPublic || [pemStr containsString:@"PRIVATE KEY"], @"PEM 格式错误");
    
    const char *pem_str = pemStr.UTF8String;
    BIO *bio_key = NULL;
    EC_KEY *ec_key = NULL;
    NSString *result = nil;
    do {
        bio_key = BIO_new_mem_buf(pem_str, -1);
        if (bio_key == NULL) {
            break;
        }
        if (isHasPublic) {
            PEM_read_bio_EC_PUBKEY(bio_key, &ec_key, NULL, NULL);
        }else{
            PEM_read_bio_ECPrivateKey(bio_key, &ec_key, NULL, NULL);
        }
        if (ec_key == NULL) {
            break;
        }
        
        const EC_POINT *pub_key = EC_KEY_get0_public_key(ec_key);
        const BIGNUM *pri_key = EC_KEY_get0_private_key(ec_key);
        const EC_GROUP *group = EC_KEY_get0_group(ec_key);
        
        if (isHasPublic) {
            char *hex_pub = EC_POINT_point2hex(group, pub_key, EC_KEY_get_conv_form(ec_key), NULL);
            result = [NSString stringWithCString:hex_pub encoding:NSUTF8StringEncoding];
            OPENSSL_free(hex_pub);
        }else{
            char *hex_pri = BN_bn2hex(pri_key);
            result = [NSString stringWithCString:hex_pri encoding:NSUTF8StringEncoding];
            while (result.length < 64) {
                result = [NSString stringWithFormat:@"0%@", result];
            }
            OPENSSL_free(hex_pri);
        }
    } while (NO);
    
    EC_KEY_free(ec_key);
    BIO_free(bio_key);
    
    return result;
}

///MARK: - 读取DER格式秘钥
+ (nullable NSString *)readPublicKeyFromDerFile:(NSString *)filePath {
    NSData *derData = [NSData dataWithContentsOfFile:filePath];
    return [self readPublicKeyFromDerData:derData];
}

+ (nullable NSString *)readPrivateKeyFromDerFile:(NSString *)filePath {
    NSData *derData = [NSData dataWithContentsOfFile:filePath];
    return [self readPrivateKeyFromDerData:derData];
}

+ (nullable NSString *)readPublicKeyFromDerData:(NSData *)derData {
    return [self readKeyFromDerData:derData public:YES];;
}

+ (nullable NSString *)readPrivateKeyFromDerData:(NSData *)derData {
    return [self readKeyFromDerData:derData public:NO];
}

+ (nullable NSString *)readKeyFromDerData:(NSData *)derData public:(BOOL)isPublic {
    if (derData == nil || derData.length == 0) {
        return nil;
    }
    BIO *bio_key = NULL;
    EC_KEY *ec_key = NULL;
    NSString *result = nil;
    
    do {
        bio_key = BIO_new_mem_buf(derData.bytes, (int)derData.length);
        if (bio_key == NULL) {
            break;
        }
        if (isPublic) {
            d2i_EC_PUBKEY_bio(bio_key, &ec_key);
        }else{
            d2i_ECPrivateKey_bio(bio_key, &ec_key);
        }
        if (ec_key == NULL) {
            break;
        }
        
        const EC_POINT *pub_key = EC_KEY_get0_public_key(ec_key);
        const BIGNUM *pri_key = EC_KEY_get0_private_key(ec_key);
        const EC_GROUP *group = EC_KEY_get0_group(ec_key);
        
        if (isPublic) {
            char *hex_pub = EC_POINT_point2hex(group, pub_key, EC_KEY_get_conv_form(ec_key), NULL);
            result = [NSString stringWithCString:hex_pub encoding:NSUTF8StringEncoding];
            OPENSSL_free(hex_pub);
        }else{
            char *hex_pri = BN_bn2hex(pri_key);
            result = [NSString stringWithCString:hex_pri encoding:NSUTF8StringEncoding];
            while (result.length < 64) {
                result = [NSString stringWithFormat:@"0%@", result];
            }
            OPENSSL_free(hex_pri);
        }
    } while (NO);
    
    EC_KEY_free(ec_key);
    BIO_free(bio_key);
    
    return result;
}

///MARK: - 写入PEM/DER格式文件
+ (BOOL)savePublicKeyToPemFile:(NSString *)publicKey filePath:(NSString *)filePath {
    return [self savePubKeyToFile:publicKey filePath:filePath pemType:YES];
}

+ (BOOL)savePrivateKeyToPemFile:(NSString *)privateKey filePath:(NSString *)filePath {
    return [self savePriKeyToFile:privateKey filePath:filePath pemType:YES];
}

+ (BOOL)savePublicKeyToDerFile:(NSString *)publicKey filePath:(NSString *)filePath {
    return [self savePubKeyToFile:publicKey filePath:filePath pemType:NO];
}

+ (BOOL)savePrivateKeyToDerFile:(NSString *)privateKey filePath:(NSString *)filePath {
    return [self savePriKeyToFile:privateKey filePath:filePath pemType:NO];
}

+ (BOOL)savePubKeyToFile:(NSString *)publicKey filePath:(NSString *)filePath pemType:(BOOL)pemType{
    if (publicKey.length == 0 || filePath.length == 0 ) {
        return NO;
    }
    const char *file_path = filePath.UTF8String;
    FILE *fp = fopen(file_path, "w");
    
    const char *public_key = publicKey.UTF8String;
    EC_GROUP *group = EC_GROUP_new_by_curve_name(kDefaultBioEllipticCurveType);
    EC_KEY *ec_key = NULL;
    EC_POINT *pub_point = NULL;
    BOOL success = YES;
    
    do {
        ec_key = EC_KEY_new();
        if (!EC_KEY_set_group(ec_key, group)) {
            success = NO;
            break;
        }

        pub_point = EC_POINT_new(group);
        EC_POINT_hex2point(group, public_key, pub_point, NULL);
        if (!EC_KEY_set_public_key(ec_key, pub_point)) {
            success = NO;
            break;
        }
        EC_KEY_set_asn1_flag(ec_key, OPENSSL_EC_NAMED_CURVE);
        if (pemType == YES) {
            if (!PEM_write_EC_PUBKEY(fp, ec_key)) {
                success = NO;
            }
        }else{
            if (!i2d_EC_PUBKEY_fp(fp, ec_key)) {
                success = NO;
            }
        }
    } while (NO);
    
    if (group != NULL) EC_GROUP_free(group);
    EC_POINT_free(pub_point);
    EC_KEY_free(ec_key);
    fclose(fp);
    
    return success;
}

+ (BOOL)savePriKeyToFile:(NSString *)privateKey filePath:(NSString *)filePath pemType:(BOOL)pemType{
    if (privateKey.length == 0 || filePath.length == 0 ) {
        return NO;
    }
    const char *file_path = filePath.UTF8String;
    FILE *fp = fopen(file_path, "w");
    
    const char *private_key = privateKey.UTF8String;
    EC_GROUP *group = EC_GROUP_new_by_curve_name(kDefaultBioEllipticCurveType);
    EC_POINT *pub_point = NULL;
    BIGNUM *pri_big_num = NULL;
    EC_KEY *ec_key = NULL;
    BOOL success = YES;
    
    do {
        if (!BN_hex2bn(&pri_big_num, private_key)) {
            success = NO;
            break;
        }
        ec_key = EC_KEY_new();
        if (!EC_KEY_set_group(ec_key, group)) {
            success = NO;
            break;
        }
        if (!EC_KEY_set_private_key(ec_key, pri_big_num)) {
            success = NO;
            break;
        }
        pub_point = EC_POINT_new(group);
        if (!EC_POINT_mul(group, pub_point, pri_big_num, NULL, NULL, NULL)) {
            success = NO;
            break;
        }
        if (!EC_KEY_set_public_key(ec_key, pub_point)) {
            success = NO;
            break;
        }
        if (pemType == YES) {
            if (!PEM_write_ECPrivateKey(fp, ec_key, NULL, NULL, 0, NULL, NULL)) {
                success = NO;
            }
        }else{
            if (!i2d_ECPrivateKey_fp(fp, ec_key)) {
                success = NO;
            }
        }
    } while (NO);
    
    if (group != NULL) EC_GROUP_free(group);
    EC_POINT_free(pub_point);
    BN_free(pri_big_num);
    EC_KEY_free(ec_key);
    fclose(fp);
    
    return success;
}

///MARK: - 创建PEM/DER格式公私钥
+ (NSArray<NSString *> *)createPemKeyPairFiles {
    return [self createPubFile:@"sm2-pub.pem" priFile:@"sm2-pri.pem"];
}

+ (NSArray<NSString *> *)createDerKeyPairFiles {
    return [self createPubFile:@"sm2-pub.der" priFile:@"sm2-pri.der"];
}

+ (NSArray<NSString *> *)createPubFile:(NSString *)pubFileName priFile:(NSString *)priFileName {
    NSArray<NSString *> *keyPathArray = @[@"", @""];
    BOOL isPem = [pubFileName hasSuffix:@".pem"] && [priFileName hasSuffix:@".pem"];
    BOOL isDer = [pubFileName hasSuffix:@".der"] && [priFileName hasSuffix:@".der"];
    if (isPem == NO && isDer == NO) {
        GMLog(@"密钥保存名称错误：%@，%@", pubFileName, priFileName);
        return keyPathArray;
    }
    
    EC_GROUP *group = EC_GROUP_new_by_curve_name(kDefaultBioEllipticCurveType);
    
    NSString *tmpPath = NSTemporaryDirectory();
    NSString *pubPath = [tmpPath stringByAppendingPathComponent:pubFileName];
    NSString *priPath = [tmpPath stringByAppendingPathComponent:priFileName];
    
    FILE *fpPub = fopen(pubPath.UTF8String, "w");
    FILE *fpPri = fopen(priPath.UTF8String, "w");
    
    EC_KEY *ec_key = NULL; // 密钥对
    BOOL success = YES;
    
    do {
        ec_key = EC_KEY_new();
        if (!EC_KEY_set_group(ec_key, group)) {
            success = NO;
            break;
        }
        if (!EC_KEY_generate_key(ec_key)) {
            success = NO;
            break;
        }
        
        if (isPem == YES) {
            if (!PEM_write_EC_PUBKEY(fpPub, ec_key)) {
                success = NO;
                break;
            }
            if (!PEM_write_ECPrivateKey(fpPri, ec_key, NULL, NULL, 0, NULL, NULL)) {
                success = NO;
                break;
            }
        }else{
            if (!i2d_EC_PUBKEY_fp(fpPub, ec_key)) {
                success = NO;
                break;
            }
            
            if (!i2d_ECPrivateKey_fp(fpPri, ec_key)) {
                success = NO;
                break;
            }
        }
    } while (NO);
    
    if (success == YES) {
        keyPathArray = @[pubPath, priPath];
    }
    
    if (group != NULL) EC_GROUP_free(group);
    EC_KEY_free(ec_key);
    fclose(fpPub);
    fclose(fpPri);
    
    return keyPathArray;
}

///MARK: - PEM & DER 互转
+ (nullable NSData *)convertPemToDer:(NSString *)pemStr {
    if (pemStr == nil || pemStr.length == 0) {
        return nil;
    }
    NSString *base64Key = [self readBase64KeyFromPemString:pemStr];
    return [GMUtils base64Decode:base64Key];
}

+ (nullable NSString *)convertDerToPem:(NSData *)derData public:(BOOL)isPublic {
    if (derData == nil || derData.length == 0) {
        return nil;
    }
    NSString *prifix = isPublic ? @"-----BEGIN PUBLIC KEY-----\n" : @"-----BEGIN EC PRIVATE KEY-----\n";
    NSString *suffix = isPublic ? @"-----END PUBLIC KEY-----\n" : @"-----END EC PRIVATE KEY-----\n";
    NSString *baseStr = [GMUtils base64Encode:derData];
    NSString *wrapStr = [self wordWrap:baseStr count:64];
    NSString *pemStr = [NSString stringWithFormat:@"%@%@%@", prifix, wrapStr, suffix];
    return pemStr;
}

+ (nullable NSString *)wordWrap:(NSString *)originStr count:(int)perRowCount{
    if (originStr.length <= perRowCount || perRowCount < 1) {
        return originStr;
    }
    NSMutableString *wrapStr = [NSMutableString string];
    int row = (int)originStr.length/perRowCount;
    for (NSInteger i = 0; i < row; i++) {
        NSUInteger loc = i * perRowCount;
        NSString *subStr = [originStr substringWithRange:NSMakeRange(loc, perRowCount)];
        [wrapStr appendFormat:@"%@\n", subStr];
    }
    NSUInteger currentLen = row * perRowCount;
    if (originStr.length > currentLen) {
        NSString *subStr = [originStr substringFromIndex:currentLen];
        [wrapStr appendFormat:@"%@\n", subStr];
    }
    return wrapStr.copy;
}

+ (NSString *)readBase64KeyFromPemString:(NSString *)pemStr{
    if (pemStr.length == 0) {
        return nil;
    }
    NSString *header_pub = @"-----BEGIN PUBLIC KEY-----";
    NSString *footer_pub = @"-----END PUBLIC KEY-----";
    NSString *header_pri = @"-----BEGIN EC PRIVATE KEY-----";
    NSString *footer_pri = @"-----END EC PRIVATE KEY-----";
    NSString *header_pkcs8 = @"-----BEGIN PRIVATE KEY-----";
    NSString *footer_pkcs8 = @"-----END PRIVATE KEY-----";
    pemStr = [pemStr stringByReplacingOccurrencesOfString:header_pub withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:footer_pub withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:header_pri withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:footer_pri withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:header_pkcs8 withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:footer_pkcs8 withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    return pemStr;
}

///MARK: - 椭圆曲线类型
+ (int)ellipticCurveType {
    return kDefaultBioEllipticCurveType;
}

+ (void)setEllipticCurveType:(int)curveType {
    kDefaultBioEllipticCurveType = curveType;
}


@end
