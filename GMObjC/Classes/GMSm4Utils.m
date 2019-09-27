//
//  GMSm4Utils.m
//
//  Created by lifei on 2019/7/30.
//  Copyright © 2019 lifei. All rights reserved.
//

#import "GMSm4Utils.h"
#import <openssl/sm4.h>
#import <openssl/evp.h>
#import <openssl/modes.h>
#import "GMUtils.h"

@implementation GMSm4Utils

///MARK: - 生成 sm4 密钥
+ (nullable NSString *)createSm4Key{
    NSInteger len = SM4_BLOCK_SIZE;
    NSString *keyStr = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    // 密钥
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:len];
    for (int i = 0; i < len; i++){
        uint32_t index = arc4random_uniform((uint32_t)keyStr.length);
        NSString *subChar = [keyStr substringWithRange:NSMakeRange(index, 1)];
        [result appendString:subChar];
    }
    return result.copy;
}

///MARK: - sm4 字符串加密

// ECB 模式加密字符串
+ (nullable NSString *)ecbEncrypt:(NSString *)plaintext Key:(NSString *)key{
    if (plaintext.length == 0 || key.length != SM4_BLOCK_SIZE) {
        // 明文、密钥不能为空
        return nil;
    }
    // 计算填充长度
    size_t pTextLen = strlen(plaintext.UTF8String);
    int padLen = SM4_BLOCK_SIZE - pTextLen % SM4_BLOCK_SIZE;
    
    size_t resultLen = pTextLen + padLen;
    // 填充
    uint8_t pText[resultLen];
    memcpy(pText, (uint8_t *)plaintext.UTF8String, pTextLen);
    for (int i = 0; i < padLen; i++) {
        pText[pTextLen + i] = padLen;
    }
    
    uint8_t *result = (uint8_t *)OPENSSL_zalloc((int)(resultLen + 1));
    int groupNum = (int)(resultLen / SM4_BLOCK_SIZE);
    // 密钥
    uint8_t *kText = (uint8_t *)key.UTF8String;
    SM4_KEY sm4Key;
    SM4_set_key(kText, &sm4Key);
    // 循环加密
    for (NSInteger i = 0; i < groupNum; i++) {
        uint8_t block[SM4_BLOCK_SIZE];
        memcpy(block, pText + i * SM4_BLOCK_SIZE, SM4_BLOCK_SIZE);
        
        SM4_encrypt(block, block, &sm4Key);
        memcpy(result + i * SM4_BLOCK_SIZE, block, SM4_BLOCK_SIZE);
    }
    
    char *hexCiphertext = OPENSSL_buf2hexstr(result, resultLen);
    NSString *encryptedStr = [NSString stringWithCString:hexCiphertext encoding:NSUTF8StringEncoding];
    // 移除冒号
    if (encryptedStr) {
        encryptedStr = [encryptedStr stringByReplacingOccurrencesOfString:@":" withString:@""];
    }
    OPENSSL_free(hexCiphertext);
    OPENSSL_free(result);
    
    return encryptedStr;
}

// CBC 模式加密字符串
+ (nullable NSString *)cbcEncrypt:(NSString *)plaintext Key:(NSString *)key IV:(NSString *)ivec{
    if (plaintext.length == 0 || key.length != SM4_BLOCK_SIZE || ivec.length != SM4_BLOCK_SIZE) {
        // 加密字符、密钥、偏移向量不能为空
        return nil;
    }
    // 计算填充长度
    size_t pTextLen = strlen(plaintext.UTF8String);
    int padLen = SM4_BLOCK_SIZE - pTextLen % SM4_BLOCK_SIZE;
    
    size_t resultLen = pTextLen + padLen;
    // 填充
    uint8_t pText[resultLen];
    memcpy(pText, (uint8_t *)plaintext.UTF8String, pTextLen);
    for (int i = 0; i < padLen; i++) {
        pText[pTextLen + i] = padLen;
    }
    // 加密结果
    uint8_t *result = (uint8_t *)OPENSSL_zalloc((int)(resultLen + 1));
    // 密钥
    uint8_t *kText = (uint8_t *)key.UTF8String;
    SM4_KEY sm4Key;
    SM4_set_key(kText, &sm4Key);
    // 初始化向量
    uint8_t *ivText = (uint8_t *)ivec.UTF8String;
    uint8_t ivecBlock[SM4_BLOCK_SIZE] = {0};
    memcpy(ivecBlock, ivText, SM4_BLOCK_SIZE);
    // cbc 加密
    CRYPTO_cbc128_encrypt(pText, result, resultLen, &sm4Key, ivecBlock,
                          (block128_f)SM4_encrypt);
    char *hexCiphertext = OPENSSL_buf2hexstr(result, resultLen);
    NSString *encryptedStr = [NSString stringWithCString:hexCiphertext encoding:NSUTF8StringEncoding];
    // 移除冒号
    if (encryptedStr) {
        encryptedStr = [encryptedStr stringByReplacingOccurrencesOfString:@":" withString:@""];
    }
    OPENSSL_free(hexCiphertext);
    OPENSSL_free(result);
    
    return encryptedStr;
}

///MARK: - sm4 字符串解密

// ECB 模式解密字符串
+ (nullable NSString *)ecbDecrypt:(NSString *)ciphertext Key:(NSString *)key{
    if (ciphertext.length == 0 || key.length != SM4_BLOCK_SIZE) {
        // 密文、密钥不能为空
        return nil;
    }
    // 全大写，加上冒号标准化
    NSString *cStr = ciphertext.uppercaseString;
    cStr = [GMUtils addColon:cStr];
    
    long ciphertextLen = 0;
    uint8_t *ctext = OPENSSL_hexstr2buf(cStr.UTF8String, &ciphertextLen);
    
    // 分组解密
    uint8_t *result = (uint8_t *)OPENSSL_zalloc((int)(ciphertextLen + 1));
    int groupNum = (int)(ciphertextLen / SM4_BLOCK_SIZE);
    // 密钥
    uint8_t *kText = (uint8_t *)key.UTF8String;
    SM4_KEY sm4Key;
    SM4_set_key(kText, &sm4Key);
    // 循环解密
    for (NSInteger i = 0; i < groupNum; i++) {
        uint8_t block[SM4_BLOCK_SIZE];
        memcpy(block, ctext + i * SM4_BLOCK_SIZE, SM4_BLOCK_SIZE);
        
        SM4_decrypt(block, block, &sm4Key);
        memcpy(result + i * SM4_BLOCK_SIZE, block, SM4_BLOCK_SIZE);
    }
    // 移除填充
    int padLen = (int)result[ciphertextLen - 1];
    int endLen = (int)(ciphertextLen - padLen);
    uint8_t *endResult = (uint8_t *)OPENSSL_zalloc((int)(endLen + 1));
    memcpy(endResult, result, endLen);
    
    NSString *plaintext = [NSString stringWithCString:(const char *)endResult encoding:NSUTF8StringEncoding];
    
    OPENSSL_free(ctext);
    OPENSSL_free(result);
    OPENSSL_free(endResult);
    
    return plaintext;
}

// CBC 模式解密字符串
+ (nullable NSString *)cbcDecrypt:(NSString *)ciphertext Key:(NSString *)key IV:(NSString *)ivec{
    if (ciphertext.length == 0 || key.length != SM4_BLOCK_SIZE || ivec.length != SM4_BLOCK_SIZE) {
        // 密文、密钥、偏移向量不能为空
        return nil;
    }
    // 全大写，加上冒号标准化
    NSString *cStr = ciphertext.uppercaseString;
    cStr = [GMUtils addColon:cStr];
    
    long ciphertextLen = 0;
    uint8_t *ctext = OPENSSL_hexstr2buf(cStr.UTF8String, &ciphertextLen);
    
    // 分组解密
    uint8_t *result = (uint8_t *)OPENSSL_zalloc((int)(ciphertextLen + 1));
    // 密钥
    uint8_t *kText = (uint8_t *)key.UTF8String;
    SM4_KEY sm4Key;
    SM4_set_key(kText, &sm4Key);
    // 初始化向量
    uint8_t *ivText = (uint8_t *)ivec.UTF8String;
    uint8_t ivecBlock[SM4_BLOCK_SIZE] = {0};
    memcpy(ivecBlock, ivText, SM4_BLOCK_SIZE);
    // CBC 解密
    CRYPTO_cbc128_decrypt(ctext, result, ciphertextLen, &sm4Key, ivecBlock,
                          (block128_f)SM4_decrypt);
    // 移除填充
    int padLen = (int)result[ciphertextLen - 1];
    int endLen = (int)(ciphertextLen - padLen);
    uint8_t *endResult = (uint8_t *)OPENSSL_zalloc((int)(endLen + 1));
    memcpy(endResult, result, endLen);
    
    NSString *plaintext = [NSString stringWithCString:(const char *)endResult encoding:NSUTF8StringEncoding];
    
    OPENSSL_free(ctext);
    OPENSSL_free(result);
    OPENSSL_free(endResult);
    
    return plaintext;
}

///MARK: - sm4 文件加密
+ (nullable NSData *)ecbEncryptData:(NSData *)plainData Key:(NSString *)key{
    if (plainData.length == 0 || key.length != SM4_BLOCK_SIZE) {
        // 密文、密钥不能为空
        return nil;
    }
    // 计算填充长度
    const uint8_t *pData = (uint8_t *)plainData.bytes;
    size_t pDataLen = plainData.length;
    int padLen = SM4_BLOCK_SIZE - pDataLen % SM4_BLOCK_SIZE;
    
    size_t resultLen = pDataLen + padLen;
    // 填充
    uint8_t pText[resultLen];
    memcpy(pText, pData, pDataLen);
    for (int i = 0; i < padLen; i++) {
        pText[pDataLen + i] = padLen;
    }
    
    uint8_t *result = (uint8_t *)OPENSSL_zalloc((int)(resultLen + 1));
    int groupNum = (int)(resultLen / SM4_BLOCK_SIZE);
    // 密钥
    uint8_t *ktext = (uint8_t *)key.UTF8String;
    SM4_KEY sm4key;
    SM4_set_key(ktext, &sm4key);
    // 循环加密
    for (NSInteger i = 0; i < groupNum; i++) {
        uint8_t block[SM4_BLOCK_SIZE];
        memcpy(block, pText + i * SM4_BLOCK_SIZE, SM4_BLOCK_SIZE);
        
        SM4_encrypt(block, block, &sm4key);
        memcpy(result + i * SM4_BLOCK_SIZE, block, SM4_BLOCK_SIZE);
    }
    // 转为 NSData
    NSData *cipherData = [NSData dataWithBytes:result length:resultLen];
    
    OPENSSL_free(result);
    
    return cipherData;
}

// CBC 模式Data加密
+ (nullable NSData *)cbcEncryptData:(NSData *)plainData Key:(NSString *)key IV:(NSString *)ivec{
    if (plainData.length == 0 || key.length != SM4_BLOCK_SIZE || ivec.length != SM4_BLOCK_SIZE) {
        // 密文、密钥不能为空
        return nil;
    }
    // 计算填充长度
    const uint8_t *pData = (uint8_t *)plainData.bytes;
    size_t pDataLen = plainData.length;
    int padLen = SM4_BLOCK_SIZE - pDataLen % SM4_BLOCK_SIZE;
    
    size_t resultLen = pDataLen + padLen;
    // 填充
    uint8_t pText[resultLen];
    memcpy(pText, pData, pDataLen);
    for (int i = 0; i < padLen; i++) {
        pText[pDataLen + i] = padLen;
    }
    // 加密结果
    uint8_t *result = (uint8_t *)OPENSSL_zalloc((int)(resultLen + 1));
    // 密钥
    uint8_t *kText = (uint8_t *)key.UTF8String;
    SM4_KEY sm4Key;
    SM4_set_key(kText, &sm4Key);
    // 初始化向量
    uint8_t *ivText = (uint8_t *)ivec.UTF8String;
    uint8_t ivecBlock[SM4_BLOCK_SIZE] = {0};
    memcpy(ivecBlock, ivText, SM4_BLOCK_SIZE);
    // cbc 加密
    CRYPTO_cbc128_encrypt(pText, result, resultLen, &sm4Key, ivecBlock,
                          (block128_f)SM4_encrypt);
    // 转为 NSData
    NSData *cipherData = [NSData dataWithBytes:result length:resultLen];
    
    OPENSSL_free(result);
    
    return cipherData;
}

///MARK: - sm4 文件加密

// ECB 模式解密 Data
+ (nullable NSData *)ecbDecryptData:(NSData *)cipherData Key:(NSString *)key{
    if (cipherData.length == 0 || key.length != SM4_BLOCK_SIZE) {
        return nil;
    }
    const uint8_t *cData = (uint8_t *)cipherData.bytes;
    size_t cTextLen = cipherData.length;
    
    // 分组解密
    uint8_t *result = (uint8_t *)OPENSSL_zalloc((int)(cTextLen + 1));
    int groupNum = (int)(cTextLen / SM4_BLOCK_SIZE);
    // 密钥
    uint8_t *ktext = (uint8_t *)key.UTF8String;
    SM4_KEY sm4key;
    SM4_set_key(ktext, &sm4key);
    // 循环解密
    for (NSInteger i = 0; i < groupNum; i++) {
        uint8_t block[SM4_BLOCK_SIZE];
        memcpy(block, cData + i * SM4_BLOCK_SIZE, SM4_BLOCK_SIZE);
        
        SM4_decrypt(block, block, &sm4key);
        memcpy(result + i * SM4_BLOCK_SIZE, block, SM4_BLOCK_SIZE);
    }
    // 移除填充
    int padLen = (int)result[cTextLen - 1];
    int endLen = (int)(cTextLen - padLen);
    uint8_t *endResult = (uint8_t *)OPENSSL_zalloc((int)(endLen + 1));
    memcpy(endResult, result, endLen);
    
    NSData *plainData = [NSData dataWithBytes:endResult length:endLen];
    
    OPENSSL_free(result);
    OPENSSL_free(endResult);
    
    return plainData;
}

// CBC 模式解密 Data
+ (nullable NSData *)cbcDecryptData:(NSData *)cipherData Key:(NSString *)key IV:(NSString *)ivec{
    if (cipherData.length == 0 || key.length != SM4_BLOCK_SIZE || ivec.length != SM4_BLOCK_SIZE) {
        return nil;
    }
    const uint8_t *cData = (uint8_t *)cipherData.bytes;
    size_t cTextLen = cipherData.length;
    // 解密结果
    uint8_t *result = (uint8_t *)OPENSSL_zalloc((int)(cTextLen + 1));
    // 密钥
    uint8_t *kText = (uint8_t *)key.UTF8String;
    SM4_KEY sm4Key;
    SM4_set_key(kText, &sm4Key);
    // 初始化向量
    uint8_t *ivText = (uint8_t *)ivec.UTF8String;
    uint8_t ivecBlock[SM4_BLOCK_SIZE] = {0};
    memcpy(ivecBlock, ivText, SM4_BLOCK_SIZE);
    // CBC 解密
    CRYPTO_cbc128_decrypt(cData, result, cTextLen, &sm4Key, ivecBlock,
                          (block128_f)SM4_decrypt);
    // 移除填充
    int padLen = (int)result[cTextLen - 1];
    int endLen = (int)(cTextLen - padLen);
    uint8_t *endResult = (uint8_t *)OPENSSL_zalloc((int)(endLen + 1));
    memcpy(endResult, result, endLen);
    
    NSData *plainData = [NSData dataWithBytes:endResult length:endLen];
    
    OPENSSL_free(result);
    OPENSSL_free(endResult);
    
    return plainData;
}

@end
