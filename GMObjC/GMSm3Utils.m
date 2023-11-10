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
            NSAssert1(NO, @"OpenSSL 版本低于 1.1.1，不支持国密，OpenSSL 当前版本：%s", OPENSSL_VERSION_TEXT);
        }
    }
}

//MARK: - 文件的摘要值
+ (nullable NSData *)hashWithData:(NSData *)data {
    if (data.length == 0) {
        return nil;
    }
    // 原文
    uint8_t *pData = (uint8_t *)[data bytes];
    // 摘要结果
    SM3_CTX ctx;
    unsigned char output[SM3_DIGEST_LENGTH];
    memset(output, 0, SM3_DIGEST_LENGTH);
    // 计算 Hash 值
    if (!sm3_init(&ctx)) {
        return nil;
    }
    if (!sm3_update(&ctx, pData, (size_t)[data length])) {
        return nil;
    }
    if (!sm3_final(output, &ctx)) {
        return nil;
    }
    memset(&ctx, 0, sizeof(SM3_CTX));
    
    NSData *digestData = [NSData dataWithBytes:output length:SM3_DIGEST_LENGTH];
    return digestData;
}

//MARK: - HMAC
+ (nullable NSData *)hmacWithData:(NSData *)data keyData:(NSData *)keyData {
    NSData *resultData = [self hmacWithData:data keyData:keyData keyType:GMHashType_SM3];
    return resultData;
}

+ (nullable NSData *)hmacWithData:(NSData *)data keyData:(NSData *)keyData keyType:(GMHashType)keyType{
    if (data.length == 0 || keyData.length == 0) {
        return nil;
    }
    int keyLen = (int)[keyData length];
    int txtLen = (int)[data length];
    uint8_t *keyBytes = (uint8_t *)[keyData bytes];
    uint8_t *txtBytes = (uint8_t *)[data bytes];
    
    unsigned int mdLen = 0;
    uint8_t *md = (uint8_t *)OPENSSL_zalloc(EVP_MAX_MD_SIZE);
    const EVP_MD *evpMD = [self evpMDType:keyType];
    HMAC(evpMD, keyBytes, keyLen, txtBytes, txtLen, md, &mdLen);
    
    NSData *resultData = [NSData dataWithBytes:md length:mdLen];
    // 释放资源
    if (md) {
        OPENSSL_free(md);
    }
    return resultData;
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
