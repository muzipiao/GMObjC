//
//  GMSm4Utils.m
//
//  Created by lifei on 2019/7/30.
//  Copyright © 2019 lifei. All rights reserved.
//

#import "GMSm4Utils.h"
#import "GMUtils.h"
#import <openssl/sm4.h>
#import <openssl/evp.h>
#import <openssl/modes.h>

@implementation GMSm4Utils

// OpenSSL 1.1.1 以上版本支持国密
+ (void)initialize
{
    if (self == [GMSm4Utils class]) {
        if (OPENSSL_VERSION_NUMBER < 0x1010100fL) {
            GMLog(@"OpenSSL 当前版本：%s",OPENSSL_VERSION_TEXT);
            NSAssert(NO, @"OpenSSL 版本低于 1.1.1，不支持国密");
        }
    }
}

///MARK: - 生成 SM4 密钥
+ (nullable NSString *)createSm4Key{
    NSInteger len = SM4_BLOCK_SIZE;
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:(len * 2)];
    
    uint8_t bytes[len];
    int status = SecRandomCopyBytes(kSecRandomDefault, (sizeof bytes)/(sizeof bytes[0]), &bytes);
    if (status == errSecSuccess) {
        for (int i = 0; i < (sizeof bytes)/(sizeof bytes[0]); i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%X",bytes[i]&0xff];///16进制数
            if (hexStr.length == 1) {
                [result appendFormat:@"0%@", hexStr];
            }else{
                [result appendString:hexStr];
            }
        }
        return result.copy;
    }
    // 容错，若 SecRandomCopyBytes 失败
    NSString *keyStr = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    for (int i = 0; i < len; i++){
        uint32_t index = arc4random_uniform((uint32_t)keyStr.length);
        NSString *subChar = [keyStr substringWithRange:NSMakeRange(index, 1)];
        [result appendString:subChar];
    }
    NSString *hexResult = [GMUtils stringToHex:result];
    return hexResult;
}

///MARK: - ECB 加密

+ (nullable NSData *)ecbEncryptData:(NSData *)plainData key:(NSString *)key{
    if (plainData.length == 0 || key.length != SM4_BLOCK_SIZE * 2) {
        return nil;
    }
    
    uint8_t *plain_obj = (uint8_t *)plainData.bytes;
    size_t plain_obj_len = plainData.length;
    
    // 计算填充长度
    int pad_en = SM4_BLOCK_SIZE - plain_obj_len % SM4_BLOCK_SIZE;
    size_t result_len = plain_obj_len + pad_en;
    // 填充
    uint8_t p_text[result_len];
    memcpy(p_text, plain_obj, plain_obj_len);
    for (int i = 0; i < pad_en; i++) {
        p_text[plain_obj_len + i] = pad_en;
    }
    
    uint8_t *result = (uint8_t *)OPENSSL_zalloc((int)(result_len + 1));
    int group_num = (int)(result_len / SM4_BLOCK_SIZE);
    // 密钥 key Hex 转 uint8_t
    NSData *kData = [GMUtils hexToData:key];
    uint8_t *k_text = (uint8_t *)kData.bytes;
    SM4_KEY sm4Key;
    SM4_set_key(k_text, &sm4Key);
    // 循环加密
    for (NSInteger i = 0; i < group_num; i++) {
        uint8_t block[SM4_BLOCK_SIZE];
        memcpy(block, p_text + i * SM4_BLOCK_SIZE, SM4_BLOCK_SIZE);
        
        SM4_encrypt(block, block, &sm4Key);
        memcpy(result + i * SM4_BLOCK_SIZE, block, SM4_BLOCK_SIZE);
    }
    
    NSData *cipherData = [NSData dataWithBytes:result length:result_len];
    
    OPENSSL_free(result);
    
    return cipherData;
}

+ (nullable NSString *)ecbEncryptText:(NSString *)plaintext key:(NSString *)key{
    if (plaintext.length == 0 || key.length != SM4_BLOCK_SIZE * 2) {
        return nil;
    }
    
    NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherData = [self ecbEncryptData:plainData key:key];
    NSString *result = [GMUtils dataToHex:cipherData];
    
    return result;
}

///MARK: - ECB 解密

+ (nullable NSData *)ecbDecryptData:(NSData *)cipherData key:(NSString *)key{
    if (cipherData.length == 0 || key.length != SM4_BLOCK_SIZE * 2) {
        return nil;
    }
    
    uint8_t *c_obj = (uint8_t *)cipherData.bytes;
    size_t c_obj_len = cipherData.length;
    
    uint8_t *result = (uint8_t *)OPENSSL_zalloc((int)(c_obj_len + 1));
    int group_num = (int)(c_obj_len / SM4_BLOCK_SIZE);
    // 密钥 key Hex 转 uint8_t
    NSData *kData = [GMUtils hexToData:key];
    uint8_t *k_text = (uint8_t *)kData.bytes;
    SM4_KEY sm4Key;
    SM4_set_key(k_text, &sm4Key);
    // 循环解密
    for (NSInteger i = 0; i < group_num; i++) {
        uint8_t block[SM4_BLOCK_SIZE];
        memcpy(block, c_obj + i * SM4_BLOCK_SIZE, SM4_BLOCK_SIZE);
        
        SM4_decrypt(block, block, &sm4Key);
        memcpy(result + i * SM4_BLOCK_SIZE, block, SM4_BLOCK_SIZE);
    }
    // 移除填充
    int pad_len = (int)result[c_obj_len - 1];
    int end_len = (int)(c_obj_len - pad_len);
    
    NSData *plainData = nil;
    if (pad_len > 0 && pad_len < SM4_BLOCK_SIZE + 1) {
        uint8_t *no_pad_result = (uint8_t *)OPENSSL_zalloc((int)(end_len + 1));
        memcpy(no_pad_result, result, end_len);
        plainData = [NSData dataWithBytes:no_pad_result length:end_len];
        
        OPENSSL_free(no_pad_result);
    }
    
    OPENSSL_free(result);
    
    return plainData;
}

+ (nullable NSString *)ecbDecryptText:(NSString *)ciphertext key:(NSString *)key{
    if (ciphertext.length == 0 || key.length != SM4_BLOCK_SIZE * 2) {
        return nil;
    }
    
    NSData *cipherData = [GMUtils hexToData:ciphertext];
    NSData *plainData = [self ecbDecryptData:cipherData key:key];
    NSString *plaintext = [[NSString alloc]initWithData:plainData encoding:NSUTF8StringEncoding];
    
    return plaintext;
}

///MARK: - CBC 加密

+ (nullable NSData *)cbcEncryptData:(NSData *)plainData key:(NSString *)key IV:(NSString *)ivec{
    if (plainData.length == 0 || key.length != SM4_BLOCK_SIZE * 2 || ivec.length != SM4_BLOCK_SIZE * 2) {
        return nil;
    }
    
    // 明文
    uint8_t *p_obj = (uint8_t *)plainData.bytes;
    size_t p_obj_len = plainData.length;
    
    int pad_len = SM4_BLOCK_SIZE - p_obj_len % SM4_BLOCK_SIZE;
    size_t result_len = p_obj_len + pad_len;
    // PKCS7 填充
    uint8_t p_text[result_len];
    memcpy(p_text, p_obj, p_obj_len);
    for (int i = 0; i < pad_len; i++) {
        p_text[p_obj_len + i] = pad_len;
    }
    uint8_t *result = (uint8_t *)OPENSSL_zalloc((int)(result_len + 1));
    // 密钥 key Hex 转 uint8_t
    NSData *kData = [GMUtils hexToData:key];
    uint8_t *k_text = (uint8_t *)kData.bytes;
    SM4_KEY sm4Key;
    SM4_set_key(k_text, &sm4Key);
    // 初始化向量
    NSData *ivecData = [GMUtils hexToData:ivec];
    uint8_t *iv_text = (uint8_t *)ivecData.bytes;
    uint8_t ivec_block[SM4_BLOCK_SIZE] = {0};
    if (iv_text != NULL) {
        memcpy(ivec_block, iv_text, SM4_BLOCK_SIZE);
    }
    // cbc 加密
    CRYPTO_cbc128_encrypt(p_text, result, result_len, &sm4Key, ivec_block,
                          (block128_f)SM4_encrypt);
    
    NSData *cipherData = [NSData dataWithBytes:result length:result_len];
    
    OPENSSL_free(result);
    
    return cipherData;
}

+ (nullable NSString *)cbcEncryptText:(NSString *)plaintext key:(NSString *)key IV:(NSString *)ivec{
    if (plaintext.length == 0 || key.length != SM4_BLOCK_SIZE * 2 || ivec.length != SM4_BLOCK_SIZE * 2) {
        return nil;
    }
    
    NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherData = [self cbcEncryptData:plainData key:key IV:ivec];
    NSString *result = [GMUtils dataToHex:cipherData];
    
    return result;
}

///MARK: - CBC 解密

+ (nullable NSData *)cbcDecryptData:(NSData *)cipherData key:(NSString *)key IV:(NSString *)ivec{
    if (cipherData.length == 0 || key.length != SM4_BLOCK_SIZE * 2 || ivec.length != SM4_BLOCK_SIZE * 2) {
        return nil;
    }
    
    uint8_t *c_obj = (uint8_t *)cipherData.bytes;
    size_t c_obj_len = cipherData.length;
    
    uint8_t *result = (uint8_t *)OPENSSL_zalloc((int)(c_obj_len + 1));
    // 密钥 key Hex 转 uint8_t
    NSData *kData = [GMUtils hexToData:key];
    uint8_t *k_text = (uint8_t *)kData.bytes;
    SM4_KEY sm4Key;
    SM4_set_key(k_text, &sm4Key);
    // 初始化向量
    NSData *ivecData = [GMUtils hexToData:ivec];
    uint8_t *iv_text = (uint8_t *)ivecData.bytes;
    uint8_t ivec_block[SM4_BLOCK_SIZE] = {0};
    if (iv_text != NULL) {
        memcpy(ivec_block, iv_text, SM4_BLOCK_SIZE);
    }
    // CBC 解密
    CRYPTO_cbc128_decrypt(c_obj, result, c_obj_len, &sm4Key, ivec_block,
                          (block128_f)SM4_decrypt);
    // 移除填充
    int pad_len = (int)result[c_obj_len - 1];
    int end_len = (int)(c_obj_len - pad_len);

    NSData *plainData = nil;
    if (pad_len > 0 && pad_len < SM4_BLOCK_SIZE + 1) {
        uint8_t *no_pad_result = (uint8_t *)OPENSSL_zalloc((int)(end_len + 1));
        memcpy(no_pad_result, result, end_len);
        plainData = [NSData dataWithBytes:no_pad_result length:end_len];
        
        OPENSSL_free(no_pad_result);
    }

    OPENSSL_free(result);
    
    return plainData;
}

+ (nullable NSString *)cbcDecryptText:(NSString *)ciphertext key:(NSString *)key IV:(NSString *)ivec{
    if (ciphertext.length == 0 || key.length != SM4_BLOCK_SIZE * 2 || ivec.length != SM4_BLOCK_SIZE * 2) {
        return nil;
    }
    
    NSData *cipherData = [GMUtils hexToData:ciphertext];
    NSData *plainData = [self cbcDecryptData:cipherData key:key IV:ivec];
    NSString *plaintext = [[NSString alloc]initWithData:plainData encoding:NSUTF8StringEncoding];
    
    return plaintext;
}

@end
