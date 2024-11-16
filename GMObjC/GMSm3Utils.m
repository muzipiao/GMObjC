#import "GMSm3Utils.h"
#import "GMSmUtils.h"
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

// MARK: - 文件的摘要值
/// 提取数据摘要值。返回值 SM3 摘要值（HEX 编码格式）
/// @param text 待提取摘要的数据
+ (nullable NSString *)hashWithText:(NSString *)text {
    if (text.length == 0) {
        return nil;
    }
    NSData *plainData = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSData *hashData = [GMSm3Utils hashWithData:plainData];
    NSString *hashHex = [GMSmUtils hexStringFromData:hashData];
    return hashHex;
}

/// 提取数据或文件的摘要值。返回 SM3 摘要值
/// @param data 待提取摘要的数据
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

// MARK: - HMAC
/// HMAC 算法计算 SM3 摘要。返回 hmac 摘要值（HEX 编码格式）
/// @param text 待提取摘要的数据
/// @param keyText 密钥，任意不为空字符
+ (nullable NSString *)hmacWithText:(NSString *)text keyText:(NSString *)keyText {
    NSString *hmacHex = [GMSm3Utils hmacWithText:text keyText:keyText keyType:GMHashType_SM3];
    return hmacHex;
}

/// HMAC 算法计算 SM3 摘要。返回 hmac 摘要值
/// @param data NSData 格式的数据明文
/// @param keyData 密钥，任意不为空字符
+ (nullable NSData *)hmacWithData:(NSData *)data keyData:(NSData *)keyData {
    NSData *hmacData = [GMSm3Utils hmacWithData:data keyData:keyData keyType:GMHashType_SM3];
    return hmacData;
}

/// HMAC 算法计算其他类型摘要。返回 hmac 摘要值（HEX 编码格式）
/// @param text 待提取摘要的数据
/// @param keyText 密钥，任意不为空字符
/// @param keyType 选取的摘要算法，详见 GMHashType 枚举
+ (nullable NSString *)hmacWithText:(NSString *)text keyText:(NSString *)keyText keyType:(GMHashType)keyType {
    if (text.length == 0 || keyText.length == 0) {
        return nil;
    }
    NSData *plainData = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [keyText dataUsingEncoding:NSUTF8StringEncoding];
    NSData *hmacData = [GMSm3Utils hmacWithData:plainData keyData:keyData keyType:keyType];
    NSString *hmacHex = [GMSmUtils hexStringFromData:hmacData];
    return hmacHex;
}

/// HMAC 算法计算其他类型摘要。返回 hmac 摘要值（HEX 编码格式）
/// @param data NSData 格式的数据明文
/// @param keyData NSData 格式的密钥，任意字符
/// @param keyType 选取的摘要算法，详见 GMHashType 枚举
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

// HMAC 算法主要类型
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
