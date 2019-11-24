//
//  Sm2Utils.m
//  Created by lifei on 2019/7/9.
//  Copyright © 2019 PacteraLF. All rights reserved.
//

#import "GMSm2Utils.h"
#import "GMSm2Def.h"
#import "GMUtils.h"
#import <openssl/sm2.h>
#import <openssl/evp.h>
#import <openssl/bn.h>

@implementation GMSm2Utils

///MARK: - 创建公私钥对

+ (NSArray<NSString *> *)createKeyPair{
    NSArray<NSString *> *keyArray = @[@"", @""];
    EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_sm2); // 椭圆曲线
    EC_KEY *key = NULL; // 密钥对
    do {
        key = EC_KEY_new();
        if (!EC_KEY_set_group(key, group)) {
            break;
        }
        if (!EC_KEY_generate_key(key)) {
            break;
        }
        const EC_POINT *pub_key = EC_KEY_get0_public_key(key);
        const BIGNUM *pri_key = EC_KEY_get0_private_key(key);

        char *hex_pub = EC_POINT_point2hex(group, pub_key, EC_KEY_get_conv_form(key), NULL);
        char *hex_pri = BN_bn2hex(pri_key);
        
        NSString *hexPubStr = [NSString stringWithCString:hex_pub encoding:NSUTF8StringEncoding];
        NSString *hexPriStr = [NSString stringWithCString:hex_pri encoding:NSUTF8StringEncoding];
        if (hexPubStr.length > 0 && hexPriStr.length > 0) {
            keyArray = @[hexPubStr, hexPriStr];
        }
        OPENSSL_free(hex_pub);
        OPENSSL_free(hex_pri);
    } while (NO);
    
    EC_KEY_free(key);
    if (group != NULL){
        EC_GROUP_free(group);
    }
    
    return keyArray;
}

///MARK: - SM2 加密

+ (nullable NSData *)enData:(NSData *)plainData hexPubKey:(NSString *)hexPubKey{
    uint8_t *plain_bytes = (uint8_t *)plainData.bytes; // 明文
    const char *public_key = hexPubKey.UTF8String; // 公钥
    size_t msg_len = plainData.length; // 明文长度
    
    const EVP_MD *digest = EVP_sm3(); // 摘要算法
    EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_sm2); // 椭圆曲线
    EC_KEY *key = NULL; // 密钥对
    EC_POINT *pub_point = NULL; // 坐标
    uint8_t *ctext = NULL; // 密文
    NSData *cipherData = nil; // 密文
    do {
        key = EC_KEY_new();
        if (!EC_KEY_set_group(key, group)) {
             break;
        }
        
        pub_point = EC_POINT_new(group);
        EC_POINT_hex2point(group, public_key, pub_point, NULL);
        if (!EC_KEY_set_public_key(key, pub_point)) {
            break;
        }
        
        size_t ctext_len = 0;
        if (!sm2_ciphertext_size(key, digest, msg_len, &ctext_len)) {
            break;
        }
        
        ctext = (uint8_t *)OPENSSL_zalloc(ctext_len);
        if (!sm2_encrypt(key, digest, plain_bytes, msg_len, ctext, &ctext_len)) {
            break;
        }
        cipherData = [NSData dataWithBytes:ctext length:ctext_len];
    } while (NO);
    
    if (group != NULL) EC_GROUP_free(group);
    EC_POINT_free(pub_point);
    OPENSSL_free(ctext);
    EC_KEY_free(key);
    
    return cipherData;
}

// 加密普通格式明文字符串
+ (nullable NSString *)encryptText:(NSString *)plaintext publicKey:(NSString *)publicKey{
    if (!plaintext || plaintext.length == 0 || !publicKey || publicKey.length == 0) {
        return nil;
    }
    NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherData = [self enData:plainData hexPubKey:publicKey];
    
    NSString *encryptedStr = [GMUtils dataToHex:cipherData];
    return encryptedStr;
}

// 加密 Hex 编码格式明文字符串
+ (nullable NSString *)encryptHex:(NSString *)plainHex publicKey:(NSString *)publicKey{
    if (!plainHex || plainHex.length == 0 || !publicKey || publicKey.length == 0) {
        return nil;
    }
    NSData *plainData = [GMUtils hexToData:plainHex];
    NSData *cipherData = [self enData:plainData hexPubKey:publicKey];
    
    NSString *encryptedStr = [GMUtils dataToHex:cipherData];
    return encryptedStr;
}

// 加密 NSData 格式明文
+ (nullable NSData *)encryptData:(NSData *)plainData publicKey:(NSString *)publicKey{
    if (!plainData || plainData.length == 0 || !publicKey || publicKey.length == 0) {
        return nil;
    }
    NSData *cipherData = [self enData:plainData hexPubKey:publicKey];
    return cipherData;
}

///MARK: - SM2 解密
+ (nullable NSData *)deData:(NSData *)cipherData hexPriKey:(NSString *)hexPriKey{
    uint8_t *cipher_bytes = (uint8_t *)cipherData.bytes; // 明文
    const char *private_key = hexPriKey.UTF8String; // 私钥
    size_t ctext_len = cipherData.length;
    
    const EVP_MD *digest = EVP_sm3(); // 摘要算法
    EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_sm2); // 椭圆曲线
    BIGNUM *pri_big_num = NULL; // 私钥
    EC_KEY *key = NULL; // 密钥对
    EC_POINT *pub_point = NULL; // 坐标
    uint8_t *plaintext = NULL; // 明文
    NSData *plainData = nil; // 明文
    
    do {
        if (!BN_hex2bn(&pri_big_num, private_key)) {
            break;
        }
        key = EC_KEY_new();
        if (!EC_KEY_set_group(key, group)) {
            break;
        }
        if (!EC_KEY_set_private_key(key, pri_big_num)) {
            break;
        }
        
        size_t ptext_len = 0;
        if (!sm2_plaintext_size(key, digest, ctext_len, &ptext_len)) {
            break;
        }
        
        plaintext = (uint8_t *)OPENSSL_zalloc(ptext_len);
        if (!sm2_decrypt(key, digest, cipher_bytes, ctext_len, plaintext, &ptext_len)) {
            break;
        }
        plainData = [NSData dataWithBytes:plaintext length:ptext_len];
    } while (NO);
    
    if (group != NULL) EC_GROUP_free(group);
    EC_POINT_free(pub_point);
    OPENSSL_free(plaintext);
    BN_free(pri_big_num);
    EC_KEY_free(key);
    
    return plainData;
}

// 解密密文，返回普通字符串
+ (nullable NSString *)decryptToText:(NSString *)ciphertext privateKey:(NSString *)privateKey{
    if (ciphertext.length == 0 || privateKey.length == 0) {
        return nil;
    }
    
    NSData *cipherData = [GMUtils hexToData:ciphertext];
    NSData *plainData = [self deData:cipherData hexPriKey:privateKey];
    
    NSString *decryptedStr = [[NSString alloc]initWithData:plainData encoding:NSUTF8StringEncoding];
    return decryptedStr;
}

// 解密密文，返回 Hex 编码格式明文
+ (nullable NSString *)decryptToHex:(NSString *)ciphertext privateKey:(NSString *)privateKey{
    if (!ciphertext || ciphertext.length == 0 || !privateKey || privateKey.length == 0) {
        return nil;
    }
    
    NSData *cipherData = [GMUtils hexToData:ciphertext];
    NSData *plainData = [self deData:cipherData hexPriKey:privateKey];
    
    NSString *plainHex = [GMUtils dataToHex:plainData];
    return plainHex;
}

// 解密密文，返回 NSData 编码格式明文
+ (nullable NSData *)decryptToData:(NSData *)cipherData privateKey:(NSString *)privateKey{
    if (!cipherData || cipherData.length == 0 || !privateKey || privateKey.length == 0) {
        return nil;
    }
    
    NSData *plainData = [self deData:cipherData hexPriKey:privateKey];
    return plainData;
}

///MARK: - ASN1 编码

+ (NSData *)asn1EnC1Hex:(NSString *)c1 c3Data:(NSData *)c3 c2Data:(NSData *)c2{
    if (c1.length == 0 || c3.length == 0 || c2.length == 0) {
        return nil;
    }

    NSUInteger c1_len = c1.length;
    const char *c1_x_hex = [c1 substringWithRange:NSMakeRange(0, c1_len/2)].UTF8String;
    const char *c1_y_hex = [c1 substringWithRange:NSMakeRange(c1_len/2, c1_len/2)].UTF8String;
    uint8_t *c3_text = (uint8_t *)c3.bytes;
    size_t c3_len = c3.length;
    uint8_t *c2_text = (uint8_t *)c2.bytes;
    size_t c2_len = c2.length;
    
    // ASN1 编码后存储数据的结构体
    struct SM2_Ciphertext_st_1 ctext_st;
    ctext_st.C2 = NULL;
    ctext_st.C3 = NULL;
    BIGNUM *x1 = NULL;
    BIGNUM *y1 = NULL;
    NSData *asn1Data = nil;
    do {
        if (!BN_hex2bn(&x1, c1_x_hex)) {
            break;
        }
        if (!BN_hex2bn(&y1, c1_y_hex)) {
            break;
        }
        ctext_st.C1x = x1;
        ctext_st.C1y = y1;
        ctext_st.C3 = ASN1_OCTET_STRING_new();
        ctext_st.C2 = ASN1_OCTET_STRING_new();
        if (ctext_st.C3 == NULL || ctext_st.C2 == NULL) {
            break;
        }
        if (!ASN1_OCTET_STRING_set(ctext_st.C3, (uint8_t *)c3_text, (int)c3_len)
            || !ASN1_OCTET_STRING_set(ctext_st.C2, (uint8_t *)c2_text, (int)c2_len)) {
            break;
        }
        uint8_t *asn1_buf = NULL; // 编码
        int asn1_len = i2d_SM2_Ciphertext_1(&ctext_st, &asn1_buf);
        /* Ensure cast to size_t is safe */
        if (asn1_len < 0 || !asn1_buf) {
            break;
        }
        asn1Data = [NSData dataWithBytes:asn1_buf length:asn1_len];
        free(asn1_buf); // 释放 buf
    } while (NO);
    
    ASN1_OCTET_STRING_free(ctext_st.C2);
    ASN1_OCTET_STRING_free(ctext_st.C3);
//    SM2_Ciphertext_1_free(ctext_st);
    BN_free(x1);
    BN_free(y1);
    
    return asn1Data;
}

+ (nullable NSString *)asn1EncodeWithC1C3C2:(NSString *)c1c3c2Hex{
    if (c1c3c2Hex.length <= 192) {
        return nil;
    }
    NSString *upperEnText = c1c3c2Hex.uppercaseString;
    NSString *c1Hex = [upperEnText substringWithRange:NSMakeRange(0, 128)];
    NSString *c3Hex = [upperEnText substringWithRange:NSMakeRange(128, 64)];
    NSString *c2Hex = [upperEnText substringFromIndex:192];
    
    NSData *c3Data = [GMUtils hexToData:c3Hex];
    NSData *c2Data = [GMUtils hexToData:c2Hex];
    if (c3Data.length == 0 || c2Data.length == 0) {
        return nil;
    }
    
    NSData *asn1Data = [self asn1EnC1Hex:c1Hex c3Data:c3Data c2Data:c2Data];
    if (asn1Data.length == 0) {
        return nil;
    }
    
    NSString *asn1Str = [GMUtils dataToHex:asn1Data];

    return asn1Str;
}

+ (nullable NSString *)asn1EncodeWithC1C3C2Array:(NSArray<NSString *> *)c1c3c2Array{
    if (c1c3c2Array.count != 3) {
        return nil;
    }
    
    NSArray<NSString *> *c1c3c2 =c1c3c2Array;
    NSString *c1c3c2Hex = [NSString stringWithFormat:@"%@%@%@", c1c3c2[0], c1c3c2[1], c1c3c2[2]];
    
    NSString *asn1Hex = [self asn1EncodeWithC1C3C2:c1c3c2Hex];
    return asn1Hex;
}

+ (nullable NSData *)asn1EncodeWithC1C3C2Data:(NSData *)c1c3c2Data{
    if (c1c3c2Data.length <= 96) {
        return nil;
    }
    NSData *c1Data = [c1c3c2Data subdataWithRange:NSMakeRange(0, 64)];
    NSData *c3Data = [c1c3c2Data subdataWithRange:NSMakeRange(64, 32)];
    NSData *c2Data = [c1c3c2Data subdataWithRange:NSMakeRange(96, c1c3c2Data.length - 96)];
    
    NSString *c1Hex = [GMUtils dataToHex:c1Data];
    NSData *asn1Data = [self asn1EnC1Hex:c1Hex c3Data:c3Data c2Data:c2Data];
    
    return asn1Data;
}

///MARK: - ASN1 解码

+ (NSArray<NSData *> *)asn1DeToC1C3C2Data:(NSData *)asn1Data{
    long asn1_ctext_len = asn1Data.length; // ASN1格式密文原文长度
    const uint8_t *asn1_ctext = (uint8_t *)asn1Data.bytes;
    
    const EVP_MD *digest = EVP_sm3(); // 摘要算法
    struct SM2_Ciphertext_st_1 *sm2_st = NULL;
    sm2_st = d2i_SM2_Ciphertext_1(NULL, &asn1_ctext, asn1_ctext_len);
    // C1
    char *c1x_text = BN_bn2hex(sm2_st->C1x);
    char *c1y_text = BN_bn2hex(sm2_st->C1y);
    NSString *c1xStr = [NSString stringWithCString:c1x_text encoding:NSUTF8StringEncoding];
    NSString *c1yStr = [NSString stringWithCString:c1y_text encoding:NSUTF8StringEncoding];
    NSString *c1Hex = [NSString stringWithFormat:@"%@%@", c1xStr, c1yStr];
    NSData *c1Data = [GMUtils hexToData:c1Hex];
    // C3
    const int c3_len = EVP_MD_size(digest);
    NSData *c3Data = [NSData dataWithBytes:sm2_st->C3->data length:c3_len];
    // C2
    int c2_len = sm2_st->C2->length;
    NSData *c2Data = [NSData dataWithBytes:sm2_st->C2->data length:c2_len];
    
    OPENSSL_free(c1x_text);
    OPENSSL_free(c1y_text);
    SM2_Ciphertext_1_free(sm2_st);
    
    if (!c1Data || !c3Data || !c2Data) {
        return nil;
    }

    return @[c1Data, c3Data, c2Data];
}

+ (nullable NSString *)asn1DecodeToC1C3C2:(NSString *)asn1Hex{
    NSArray<NSString *> *c1c3c2 = [self asn1DecodeToC1C3C2Array:asn1Hex];
    if (c1c3c2.count != 3) {
        return nil;
    }
    
    NSString *c1c3c2Hex = [NSString stringWithFormat:@"%@%@%@", c1c3c2[0], c1c3c2[1], c1c3c2[2]];
    return c1c3c2Hex;
}

+ (nullable NSArray<NSString *> *)asn1DecodeToC1C3C2Array:(NSString *)asn1Hex{
    if (asn1Hex.length == 0) {
        return nil;
    }
    NSData *asn1Data = [GMUtils hexToData:asn1Hex];
    if (asn1Data.length == 0) {
        return nil;
    }
    NSArray<NSData *> *decodedArray = [self asn1DeToC1C3C2Data:asn1Data];
    if (decodedArray.count != 3) {
        return nil;
    }
    NSString *c1Hex = [GMUtils dataToHex:decodedArray[0]];
    NSString *c3Hex = [GMUtils dataToHex:decodedArray[1]];
    NSString *c2Hex = [GMUtils dataToHex:decodedArray[2]];
    
    if (c1Hex.length == 0 || c3Hex.length == 0 || c2Hex.length == 0) {
        return nil;
    }
    
    return @[c1Hex, c3Hex, c2Hex];
}

+ (nullable NSData *)asn1DecodeToC1C3C2Data:(NSData *)asn1Data{
    if (asn1Data.length == 0) {
        return nil;
    }
    
    NSArray<NSData *> *c1c3c2Array = [self asn1DeToC1C3C2Data:asn1Data];
    if (c1c3c2Array.count != 3) {
        return nil;
    }
    
    NSMutableData *c1c3c2Data = [NSMutableData dataWithData:c1c3c2Array[0]];
    [c1c3c2Data appendData:c1c3c2Array[1]];
    [c1c3c2Data appendData:c1c3c2Array[2]];
    
    return c1c3c2Data;
}

///MARK: - SM2 签名

+ (nullable NSString *)signData:(NSData *)plainData priKey:(NSString *)priKey userID:(nullable NSData *)userID{
    if (plainData.length == 0 || priKey.length == 0) {
        return nil;
    }
    
    NSData *userData = userID;
    if (userID.length == 0) {
        userData = [NSData dataWithBytes:SM2_DEFAULT_USERID length:strlen(SM2_DEFAULT_USERID)];
    }
    const char *private_key = priKey.UTF8String;
    uint8_t *plain_bytes = (uint8_t *)plainData.bytes;
    size_t plain_len = plainData.length;
    uint8_t *user_id = (uint8_t *)userData.bytes;
    size_t user_len = userData.length;
    
    ECDSA_SIG *sig = NULL;  // 签名结果
    const BIGNUM *sig_r = NULL;
    const BIGNUM *sig_s = NULL;
    const EVP_MD *digest = EVP_sm3();  // 摘要算法
    EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_sm2);
    BIGNUM *pri_num = NULL;  // 私钥
    EC_KEY *key = NULL; // 密钥对
    EC_POINT *pub_point = NULL; // 公钥坐标
    NSString *sigStr = nil;  // 签名结果
    do {
        if (!BN_hex2bn(&pri_num, private_key)) {
            break; // 私钥转 BIGNUM
        }
        key = EC_KEY_new();
        if (!EC_KEY_set_group(key, group)) {
            break;
        }
        if (!EC_KEY_set_private_key(key, pri_num)) {
            break; // 设置私钥
        }
        pub_point = EC_POINT_new(group);
        if (!EC_POINT_mul(group, pub_point, pri_num, NULL, NULL, NULL)) {
            break; // 私钥算出公钥
        }
        if (!EC_KEY_set_public_key(key, pub_point)) {
            break; // 设置公钥
        }
        // 计算签名
        sig = sm2_do_sign(key, digest, user_id, user_len, plain_bytes, plain_len);
        if (!sig) {
            break;
        }
        ECDSA_SIG_get0(sig, &sig_r, &sig_s);
        char *r_hex = BN_bn2hex(sig_r);
        char *s_hex = BN_bn2hex(sig_s);
        NSString *rStr = [NSString stringWithCString:r_hex encoding:NSUTF8StringEncoding];
        NSString *sStr = [NSString stringWithCString:s_hex encoding:NSUTF8StringEncoding];
        
        OPENSSL_free(r_hex);
        OPENSSL_free(s_hex);
        if (rStr.length == 0 || sStr.length == 0) {
            break;
        }
        sigStr = [NSString stringWithFormat:@"%@,%@", rStr, sStr];
    } while (NO);
    
    if (group != NULL) EC_GROUP_free(group);
    EC_POINT_free(pub_point);
    ECDSA_SIG_free(sig);
    EC_KEY_free(key);
    BN_free(pri_num);
    
    return sigStr;
}

// 16进制字符串签名
+ (nullable NSString *)signHex:(NSString *)hexPlaintext privateKey:(NSString *)priKey userID:(nullable NSString *)hexUserID{
    if (hexPlaintext.length == 0 || priKey.length == 0) {
        return nil;
    }
    
    NSData *plainData = [GMUtils hexToData:hexPlaintext];
    NSData *userData = [GMUtils hexToData:hexUserID];
    NSString *signRS = [self signData:plainData priKey:priKey userID:userData];
    
    return signRS;
}

// 普通字符串签名
+ (nullable NSString *)signText:(NSString *)plaintext privateKey:(NSString *)priKey userID:(nullable NSString *)userID{
    if (plaintext.length == 0 || priKey.length == 0) {
        return nil;
    }
    
    NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
    NSData *userData = [userID dataUsingEncoding:NSUTF8StringEncoding];
    NSString *signRS = [self signData:plainData priKey:priKey userID:userData];
    
    return signRS;
}

///MARK: - SM2 验签

+ (BOOL)verifyData:(NSData *)plainData signRS:(NSString *)signRS pubKey:(NSString *)pubKey userID:(nullable NSData *)userID{
    if (plainData.length == 0 || signRS.length == 0 || pubKey.length == 0) {
        return nil;
    }
    
    NSData *userData = userID;
    if (userID.length == 0) {
        userData = [NSData dataWithBytes:SM2_DEFAULT_USERID length:strlen(SM2_DEFAULT_USERID)];
    }
    const char *pub_key = pubKey.UTF8String;
    uint8_t *plain_bytes = (uint8_t *)plainData.bytes;
    size_t plain_len = plainData.length;
    uint8_t *user_id = (uint8_t *)userData.bytes;
    size_t user_len = userData.length;
    
    NSArray<NSString *> *rsArray = [signRS componentsSeparatedByString:@","];
    if (rsArray.count < 2) return NO;
    
    NSString *r_hex = rsArray[0];
    NSString *s_hex = rsArray[1];
    
    ECDSA_SIG *sig = NULL;  // 签名结果
    BIGNUM *sig_r = NULL;
    BIGNUM *sig_s = NULL;
    const EVP_MD *digest = EVP_sm3();  // 摘要算法
    EC_POINT *pub_point = NULL;  // 公钥坐标
    EC_KEY *key = NULL;  // 密钥key
    EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_sm2);
    BOOL isOK = NO;  // 验签结果
    
    do {
        if (!BN_hex2bn(&sig_r, r_hex.UTF8String)) {
            break;
        }
        if (!BN_hex2bn(&sig_s, s_hex.UTF8String)) {
            break;
        }
        sig = ECDSA_SIG_new();
        if (sig == NULL) {
            BN_free(sig_r);
            BN_free(sig_s);
            break;
        }
        if (!ECDSA_SIG_set0(sig, sig_r, sig_s)) {
            break;
        }
        key = EC_KEY_new();
        if (!EC_KEY_set_group(key, group)) {
            break;
        }
        pub_point = EC_POINT_new(group);
        EC_POINT_hex2point(group, pub_key, pub_point, NULL);
        if (!EC_KEY_set_public_key(key, pub_point)) {
            break;
        }
        int ok = sm2_do_verify(key, digest, sig, user_id, user_len, plain_bytes, plain_len);
        isOK = ok > 0 ? YES : NO;
    } while (NO);
    
    EC_POINT_free(pub_point);
    EC_KEY_free(key);
    ECDSA_SIG_free(sig);
    if (group != NULL){
        EC_GROUP_free(group);
    }
    
    return isOK;
}

// 16 进制明文和 UserID 验签
+ (BOOL)verifyHex:(NSString *)hexPlaintext signRS:(NSString *)signRS publicKey:(NSString *)pubKey userID:(nullable NSString *)hexUserID{
    if (hexPlaintext.length == 0 || signRS.length == 0 || pubKey.length == 0) {
        return nil;
    }
    
    NSData *plainData = [GMUtils hexToData:hexPlaintext];
    NSData *userData = [GMUtils hexToData:hexUserID];
    
    BOOL isOK = [self verifyData:plainData signRS:signRS pubKey:pubKey userID:userData];
    return isOK;
}

+ (BOOL)verifyText:(NSString *)plaintext signRS:(NSString *)signRS publicKey:(NSString *)pubKey userID:(nullable NSString *)userID{
    if (plaintext.length == 0 || signRS.length == 0 || pubKey.length == 0) {
        return NO;
    }
    
    NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
    NSData *userData = [userID dataUsingEncoding:NSUTF8StringEncoding];
    
    BOOL isOK = [self verifyData:plainData signRS:signRS pubKey:pubKey userID:userData];
    return isOK;
}

///MARK: - SM2签名 Der 编码

+ (nullable NSString *)derEncode:(NSString *)signRS{
    if (signRS.length == 0) {
        return nil;
    }
    NSArray<NSString *> *rsArray = [signRS componentsSeparatedByString:@","];
    if (rsArray.count < 2) {
        return nil;
    }
    NSString *r_hex = rsArray[0];
    NSString *s_hex = rsArray[1];
    
    ECDSA_SIG *sig = NULL;  // 签名结果
    BIGNUM *sig_r = NULL;
    BIGNUM *sig_s = NULL;
    NSString *derEncode = nil;
    do {
        if (!BN_hex2bn(&sig_r, r_hex.UTF8String)) {
            break;
        }
        if (!BN_hex2bn(&sig_s, s_hex.UTF8String)) {
            break;
        }
        sig = ECDSA_SIG_new();
        if (sig == NULL) {
            BN_free(sig_r);
            BN_free(sig_s);
            break;
        }
        if (!ECDSA_SIG_set0(sig, sig_r, sig_s)) {
            break;
        }
        unsigned char *der_sig = NULL;
        int der_sig_len = i2d_ECDSA_SIG(sig, &der_sig);
        if (der_sig_len < 0) {
            break;
        }
        char *der_sig_hex = OPENSSL_buf2hexstr((uint8_t *)der_sig, der_sig_len);
        derEncode = [NSString stringWithCString:der_sig_hex encoding:NSUTF8StringEncoding];
        
        OPENSSL_free(der_sig);
        OPENSSL_free(der_sig_hex);
    } while (NO);
    
    ECDSA_SIG_free(sig);
    
    return derEncode;
}

///MARK: - SM2签名 Der 解码

+ (nullable NSString *)derDecode:(NSString *)derSign{
    if (derSign.length == 0) {
        return nil;
    }
    const char *sign_hex = derSign.UTF8String;
    long sign_len = 0;
    uint8_t *sign_buffer = OPENSSL_hexstr2buf(sign_hex, &sign_len);
    const uint8_t *sign_char = sign_buffer;
    // 复制一份，对比验证
    long sign_copy_len = 0;
    uint8_t *sign_copy = OPENSSL_hexstr2buf(sign_hex, &sign_copy_len);
    
    ECDSA_SIG *sig = NULL;
    const BIGNUM *sig_r = NULL;
    const BIGNUM *sig_s = NULL;
    unsigned char *der = NULL;
    int derlen = -1;
    
    NSString *originSign = nil;
    
    do {
        sig = ECDSA_SIG_new();
        if (sig == NULL) {
            break;
        }
        if (d2i_ECDSA_SIG(&sig, &sign_char, sign_len) == NULL) {
            break;
        }
        /* Ensure signature uses DER and doesn't have trailing garbage */
        derlen = i2d_ECDSA_SIG(sig, &der);
        if (derlen != sign_len || memcmp(sign_copy, der, derlen) != 0) {
            break;
        }
        // 取出 r, s
        ECDSA_SIG_get0(sig, &sig_r, &sig_s);
        char *r_hex = BN_bn2hex(sig_r);
        char *s_hex = BN_bn2hex(sig_s);
        NSString *rStr = [NSString stringWithCString:r_hex encoding:NSUTF8StringEncoding];
        NSString *sStr = [NSString stringWithCString:s_hex encoding:NSUTF8StringEncoding];
        OPENSSL_free(r_hex);
        OPENSSL_free(s_hex);
        if (rStr.length == 0 || sStr.length == 0) {
            break;
        }
        originSign = [NSString stringWithFormat:@"%@,%@", rStr, sStr];
    } while (NO);
    
    ECDSA_SIG_free(sig);
    OPENSSL_free(der);
    OPENSSL_free(sign_buffer);
    OPENSSL_free(sign_copy);
    
    return originSign;
}

///MARK: - ECDH 密钥协商

+ (nullable NSString *)computeECDH:(NSString *)publicKey privateKey:(NSString *)privateKey{
    if (!publicKey || publicKey.length == 0 || !privateKey || privateKey.length == 0) {
        return nil;
    }
    
    const char *public_key = publicKey.UTF8String;
    const char *private_key = privateKey.UTF8String; // 私钥
    EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_sm2); // 椭圆曲线
    
    EC_POINT *pub_point = NULL;  // 公钥
    BIGNUM *pri_big_num = NULL; // 私钥
    EC_KEY *key = NULL;  // 密钥结构体
    NSString *ecdhStr = nil; // 协商出的密钥字符

    do {
        // 公钥转换为 EC_POINT
        pub_point = EC_POINT_new(group);
        EC_POINT_hex2point(group, public_key, pub_point, NULL);
        // 私钥转换为 BIGNUM 并存储在 EC_KEY 中
        if (!BN_hex2bn(&pri_big_num, private_key)) {
            break;
        }
        key = EC_KEY_new();
        if (!EC_KEY_set_group(key, group)) {
            break;
        }
        if (!EC_KEY_set_private_key(key, pri_big_num)) {
            break;
        }
        
        size_t outlen = 32;
        uint8_t *ecdh_text = (uint8_t *)OPENSSL_zalloc(outlen + 1);
        int ret = ECDH_compute_key(ecdh_text, outlen, pub_point, key, 0);
        if (ret <= 0) {
            break;
        }
        char *hex_ctext = OPENSSL_buf2hexstr((const uint8_t *)ecdh_text, outlen);
        NSString *hexCtext = [NSString stringWithCString:hex_ctext encoding:NSUTF8StringEncoding];
        ecdhStr = [hexCtext stringByReplacingOccurrencesOfString:@":" withString:@""];
        
        OPENSSL_free(ecdh_text);
        OPENSSL_free(hex_ctext);
        
    } while (NO);
    
    EC_POINT_free(pub_point);
    BN_free(pri_big_num);
    EC_KEY_free(key);
    if (group != NULL){
        EC_GROUP_free(group);
    }
    
    return ecdhStr;
}

@end
