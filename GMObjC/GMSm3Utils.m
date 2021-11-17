//
//  GMSm3Utils.m
//  BaseDemo
//
//  Created by lifei on 2019/8/2.
//  Copyright © 2019 lifei. All rights reserved.
//

#import "GMSm3Utils.h"
#import <openssl/sm3.h>
#import <openssl/evp.h>
#import <openssl/hmac.h>

@implementation GMSm3Utils

// OpenSSL 1.1.1 以上版本支持国密
+ (void)initialize
{
    if (self == [GMSm3Utils class]) {
        if (OPENSSL_VERSION_NUMBER < 0x1010100fL) {
            GMLog(@"OpenSSL 当前版本：%s",OPENSSL_VERSION_TEXT);
            NSAssert(NO, @"OpenSSL 版本低于 1.1.1，不支持国密");
        }
    }
}

///MARK: - 字符串的摘要值
+ (nullable NSString *)hashWithString:(NSString *)plaintext{
    if (plaintext.length == 0) {
        return nil;
    }
    NSData *strData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
    NSString *digStr = [self hashWithData:strData];
    return digStr;
}

///MARK: - 文件的摘要值
+ (nullable NSString *)hashWithData:(NSData *)plainData{
    if (plainData.length == 0) {
        return nil;
    }
    // 原文
    uint8_t *pData = (uint8_t *)plainData.bytes;
    // 摘要结果
    SM3_CTX ctx;
    unsigned char output[SM3_DIGEST_LENGTH];
    memset(output, 0, SM3_DIGEST_LENGTH);
    do {
        if (!sm3_init(&ctx)) {
            break;
        }
        size_t pDataLen = plainData.length;
        if (!sm3_update(&ctx, pData, pDataLen)) {
            break;
        }
        if (!sm3_final(output, &ctx)) {
            break;
        }
        memset(&ctx, 0, sizeof(SM3_CTX));
    } while (NO);
    // 转为 16 进制
    NSMutableString *digestStr = [NSMutableString stringWithCapacity:SM3_DIGEST_LENGTH];
    for (NSInteger i = 0; i < SM3_DIGEST_LENGTH; i++) {
        NSString *subStr = [NSString stringWithFormat:@"%X",output[i]&0xff];
        if (subStr.length == 1) {
            [digestStr appendFormat:@"0%@", subStr];
        }else{
            [digestStr appendString:subStr];
        }
    }
    return digestStr;
}

//MARK: - HMAC
+ (nullable NSString *)hmacWithSm3:(NSString *)key plaintext:(NSString *)plaintext {
    NSString *resultHex = [self hmac:GMHashType_SM3 key:key plaintext:plaintext];
    return resultHex;
}

+ (nullable NSString *)hmacWithSm3:(NSData *)keyData plainData:(NSData *)plainData {
    NSString *resultHex = [self hmac:GMHashType_SM3 keyData:keyData plainData:plainData];
    return resultHex;
}

+ (nullable NSString *)hmac:(GMHashType)type key:(NSString *)key plaintext:(NSString *)plaintext {
    if (key.length == 0 || plaintext.length == 0) {
        return nil;
    }
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
    NSString *resultHex = [self hmac:type keyData:keyData plainData:plainData];
    return resultHex;
}

+ (nullable NSString *)hmac:(GMHashType)type keyData:(NSData *)keyData plainData:(NSData *)plainData {
    if (keyData.length == 0 || plainData.length == 0) {
        return nil;
    }
    int keyLen = (int)keyData.length;
    int txtLen = (int)plainData.length;
    uint8_t *keyBytes = (uint8_t *)keyData.bytes;
    uint8_t *txtBytes = (uint8_t *)plainData.bytes;
    
    unsigned int mdLen = 0;
    uint8_t *md = (uint8_t *)OPENSSL_zalloc(EVP_MAX_MD_SIZE);
    const EVP_MD *evpMD = [self evpMDType:type];
    HMAC(evpMD, keyBytes, keyLen, txtBytes, txtLen, md, &mdLen);
    
    NSData *resultData = [NSData dataWithBytes:md length:mdLen];
    OPENSSL_free(md);
    
    NSString *mdHex = [GMUtils dataToHex:resultData];
    return mdHex;
}

+ (const EVP_MD *)evpMDType:(GMHashType)type {
    const EVP_MD *md = NULL;
    switch (type) {
        case GMHashType_SM3:
            md = EVP_sm3();
            break;
        case GMHashType_MD5:
            md = EVP_md5();
            break;
        case GMHashType_SHA1:
            md = EVP_sha1();
            break;
        case GMHashType_SHA224:
            md = EVP_sha224();
            break;
        case GMHashType_SHA256:
            md = EVP_sha256();
            break;
        case GMHashType_SHA384:
            md = EVP_sha384();
            break;
        case GMHashType_SHA512:
            md = EVP_sha512();
            break;
            
        default:
            md = EVP_sm3();
            break;
    }
    return md;
}

@end
