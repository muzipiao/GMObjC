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

///MARK: - NSObject to Bytes
+ (uint8_t *)plainObjToBytes:(id)plainObj Len:(size_t *)p_len{
    uint8_t *p_obj = NULL;
    if ([plainObj isKindOfClass:[NSString class]]) {
        p_obj = (uint8_t *)((NSString *)plainObj).UTF8String;
        *p_len = strlen(((NSString *)plainObj).UTF8String);
    }else if ([plainObj isKindOfClass:[NSData class]]){
        p_obj = (uint8_t *)((NSData *)plainObj).bytes;
        *p_len = ((NSData *)plainObj).length;
    }
    return p_obj;
}

// 加密对象类型并转为 bytes
+ (uint8_t *)cipherObjToBytes:(id)cipherObj Len:(size_t *)c_len{
    uint8_t *c_obj = NULL;
    if ([cipherObj isKindOfClass:[NSString class]]) {
        NSString *cStr = ((NSString *)cipherObj).uppercaseString;
        cStr = [GMUtils addColon:cStr];
        long c_obj_len = 0;
        c_obj = OPENSSL_hexstr2buf(cStr.UTF8String, &c_obj_len);
        *c_len = c_obj_len;
    }else if ([cipherObj isKindOfClass:[NSData class]]){
        c_obj = (uint8_t *)((NSData *)cipherObj).bytes;
        *c_len = ((NSData *)cipherObj).length;
    }
    return c_obj;
}

///MARK: - ECB & CBC 加密
+ (id)enWithECB:(id)plainObj Key:(NSString *)key{
    size_t plain_obj_len = 0;
    uint8_t *plain_obj = [self plainObjToBytes:plainObj Len:&plain_obj_len];
    
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
    uint8_t *k_text = [GMUtils hexToBytes:key];
    SM4_KEY sm4Key;
    SM4_set_key(k_text, &sm4Key);
    // 循环加密
    for (NSInteger i = 0; i < group_num; i++) {
        uint8_t block[SM4_BLOCK_SIZE];
        memcpy(block, p_text + i * SM4_BLOCK_SIZE, SM4_BLOCK_SIZE);
        
        SM4_encrypt(block, block, &sm4Key);
        memcpy(result + i * SM4_BLOCK_SIZE, block, SM4_BLOCK_SIZE);
    }
    id resultObj = nil; // 结果
    if ([plainObj isKindOfClass:[NSString class]]) {
        char *hex_ciphertext = OPENSSL_buf2hexstr(result, result_len);
        NSString *encryptedStr = [NSString stringWithCString:hex_ciphertext encoding:NSUTF8StringEncoding];
        if (encryptedStr) {
            resultObj = [encryptedStr stringByReplacingOccurrencesOfString:@":" withString:@""];
        }
        OPENSSL_free(hex_ciphertext);
    }else{
        NSData *cipherData = [NSData dataWithBytes:result length:result_len];
        resultObj = cipherData;
    }
    
    OPENSSL_free(result);
    free(k_text);
    
    return resultObj;
}

// CBC 加密
+ (id)enWithCBC:(id)plainObj Key:(NSString *)key IV:(NSString *)ivec{
    size_t p_obj_len = 0;
    uint8_t *p_obj = [self plainObjToBytes:plainObj Len:&p_obj_len];
    
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
    uint8_t *k_text = [GMUtils hexToBytes:key];
    SM4_KEY sm4Key;
    SM4_set_key(k_text, &sm4Key);
    // 初始化向量
    uint8_t *iv_text = [GMUtils hexToBytes:ivec];
    uint8_t ivec_block[SM4_BLOCK_SIZE] = {0};
    memcpy(ivec_block, iv_text, SM4_BLOCK_SIZE);
    // cbc 加密
    CRYPTO_cbc128_encrypt(p_text, result, result_len, &sm4Key, ivec_block,
                          (block128_f)SM4_encrypt);
    id resultObj = nil; // 结果
    if ([plainObj isKindOfClass:[NSString class]]) {
        char *hex_ciphertext = OPENSSL_buf2hexstr(result, result_len);
        NSString *encryptedStr = [NSString stringWithCString:hex_ciphertext encoding:NSUTF8StringEncoding];
        if (encryptedStr) {
            resultObj = [encryptedStr stringByReplacingOccurrencesOfString:@":" withString:@""];
        }
        OPENSSL_free(hex_ciphertext);
    }else{
        NSData *cipherData = [NSData dataWithBytes:result length:result_len];
        resultObj = cipherData;
    }
    
    OPENSSL_free(result);
    free(iv_text);
    free(k_text);
    
    return resultObj;
}

///MARK: - ECB & CBC 解密
// ECB 解密
+ (id)deWithECB:(id)cipherObj Key:(NSString *)key{
    size_t c_obj_len = 0;
    uint8_t *c_obj = [self cipherObjToBytes:cipherObj Len:&c_obj_len];

    // 分组解密
    uint8_t *result = (uint8_t *)OPENSSL_zalloc((int)(c_obj_len + 1));
    int group_num = (int)(c_obj_len / SM4_BLOCK_SIZE);
    // 密钥 key Hex 转 uint8_t
    uint8_t *k_text = [GMUtils hexToBytes:key];
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
    uint8_t *no_pad_result = (uint8_t *)OPENSSL_zalloc((int)(end_len + 1));
    memcpy(no_pad_result, result, end_len);
    
   id resultObj = nil; // 结果
    if ([cipherObj isKindOfClass:[NSString class]]) {
        resultObj = [NSString stringWithCString:(const char *)no_pad_result encoding:NSUTF8StringEncoding];
        OPENSSL_free(c_obj);
    }else{
        resultObj = [NSData dataWithBytes:no_pad_result length:end_len];
    }
    
    OPENSSL_free(result);
    OPENSSL_free(no_pad_result);
    free(k_text);
    
    return resultObj;
}

// CBC 解密
+ (id)deWithCBC:(id)cipherObj Key:(NSString *)key IV:(NSString *)ivec{
    size_t c_obj_len = 0;
    uint8_t *c_obj = [self cipherObjToBytes:cipherObj Len:&c_obj_len];
    
    // 分组解密
    uint8_t *result = (uint8_t *)OPENSSL_zalloc((int)(c_obj_len + 1));
    // 密钥 key Hex 转 uint8_t
    uint8_t *k_text = [GMUtils hexToBytes:key];
    SM4_KEY sm4Key;
    SM4_set_key(k_text, &sm4Key);
    // 初始化向量
    uint8_t *iv_text = [GMUtils hexToBytes:ivec];
    uint8_t ivec_block[SM4_BLOCK_SIZE] = {0};
    memcpy(ivec_block, iv_text, SM4_BLOCK_SIZE);
    // CBC 解密
    CRYPTO_cbc128_decrypt(c_obj, result, c_obj_len, &sm4Key, ivec_block,
                          (block128_f)SM4_decrypt);
    // 移除填充
    int pad_len = (int)result[c_obj_len - 1];
    int end_len = (int)(c_obj_len - pad_len);
    uint8_t *no_pad_result = (uint8_t *)OPENSSL_zalloc((int)(end_len + 1));
    memcpy(no_pad_result, result, end_len);
    
    id resultObj = nil; // 结果
    if ([cipherObj isKindOfClass:[NSString class]]) {
        resultObj = [NSString stringWithCString:(const char *)no_pad_result encoding:NSUTF8StringEncoding];
        OPENSSL_free(c_obj);
    }else{
        resultObj = [NSData dataWithBytes:no_pad_result length:end_len];
    }

    OPENSSL_free(result);
    OPENSSL_free(no_pad_result);
    free(iv_text);
    free(k_text);
    
    return resultObj;
}

///MARK: - SM4 字符串加密

// ECB 模式加密字符串
+ (nullable NSString *)ecbEncrypt:(NSString *)plaintext Key:(NSString *)key{
    if (plaintext.length == 0 || key.length != SM4_BLOCK_SIZE * 2) {
        // 明文、密钥不能为空
        return nil;
    }
    NSString *result = (NSString *)[self enWithECB:plaintext Key:key];
    return result;
}

// CBC 模式加密字符串
+ (nullable NSString *)cbcEncrypt:(NSString *)plaintext Key:(NSString *)key IV:(NSString *)ivec{
    if (plaintext.length == 0 || key.length != SM4_BLOCK_SIZE * 2 || ivec.length != SM4_BLOCK_SIZE * 2) {
        // 加密字符、密钥、偏移向量不能为空
        return nil;
    }
    NSString *result = (NSString *)[self enWithCBC:plaintext Key:key IV:ivec];
    return result;
}

///MARK: - SM4 字符串解密

// ECB 模式解密字符串
+ (nullable NSString *)ecbDecrypt:(NSString *)ciphertext Key:(NSString *)key{
    if (ciphertext.length == 0 || key.length != SM4_BLOCK_SIZE * 2) {
        return nil;
    }
    NSString *plaintext = (NSString *)[self deWithECB:ciphertext Key:key];
    return plaintext;
}

// CBC 模式解密字符串
+ (nullable NSString *)cbcDecrypt:(NSString *)ciphertext Key:(NSString *)key IV:(NSString *)ivec{
    if (ciphertext.length == 0 || key.length != SM4_BLOCK_SIZE * 2 || ivec.length != SM4_BLOCK_SIZE * 2) {
        // 密文、密钥、偏移向量不能为空
        return nil;
    }
    NSString *plaintext = (NSString *)[self deWithCBC:ciphertext Key:key IV:ivec];
    return plaintext;
}

///MARK: - SM4 文件加密
+ (nullable NSData *)ecbEncryptData:(NSData *)plainData Key:(NSString *)key{
    if (plainData.length == 0 || key.length != SM4_BLOCK_SIZE * 2) {
        // 密文、密钥不能为空
        return nil;
    }
    NSData *result = (NSData *)[self enWithECB:plainData Key:key];
    return result;
}

// CBC 模式Data加密
+ (nullable NSData *)cbcEncryptData:(NSData *)plainData Key:(NSString *)key IV:(NSString *)ivec{
    if (plainData.length == 0 || key.length != SM4_BLOCK_SIZE * 2 || ivec.length != SM4_BLOCK_SIZE * 2) {
        // 密文、密钥不能为空
        return nil;
    }
    NSData *cipherData = [self enWithCBC:plainData Key:key IV:ivec];
    return cipherData;
}

///MARK: - SM4 文件加密

// ECB 模式解密 Data
+ (nullable NSData *)ecbDecryptData:(NSData *)cipherData Key:(NSString *)key{
    if (cipherData.length == 0 || key.length != SM4_BLOCK_SIZE * 2) {
        return nil;
    }
    NSData *plainData = (NSData *)[self deWithECB:cipherData Key:key];
    return plainData;
}

// CBC 模式解密 Data
+ (nullable NSData *)cbcDecryptData:(NSData *)cipherData Key:(NSString *)key IV:(NSString *)ivec{
    if (cipherData.length == 0 || key.length != SM4_BLOCK_SIZE * 2 || ivec.length != SM4_BLOCK_SIZE * 2) {
        return nil;
    }
    NSData *plainData = (NSData *)[self deWithCBC:cipherData Key:key IV:ivec];
    return plainData;
}

@end
