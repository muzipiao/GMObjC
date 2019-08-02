//
//  GMSm4Utils.m
//
//  Created by lifei on 2019/7/30.
//  Copyright © 2019 lifei. All rights reserved.
//

#import "GMSm4Utils.h"
#import <openssl/sm4.h>
#import <openssl/evp.h>
#import "GMCodecUtils.h"

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

///MARK: - sm4 加密
+ (nullable NSString *)encrypt:(NSString *)plainText Key:(NSString *)key{
    if (!plainText || plainText.length == 0 || !key || key.length != SM4_BLOCK_SIZE) {
        return nil;
    }
    // 计算填充长度
    size_t pTextLen = strlen(plainText.UTF8String);
    int padLen = SM4_BLOCK_SIZE - pTextLen % SM4_BLOCK_SIZE;
    
    size_t resultLen = pTextLen + padLen;
    // 填充
    uint8_t pText[resultLen];
    memcpy(pText, (uint8_t *)plainText.UTF8String, pTextLen);
    for (int i = 0; i < padLen; i++) {
        pText[pTextLen + i] = padLen;
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
    
    char *hex_ctext = OPENSSL_buf2hexstr(result, resultLen);
    NSString *encryptedStr = [NSString stringWithCString:hex_ctext encoding:NSUTF8StringEncoding];
    // 移除冒号
    if (encryptedStr) {
        encryptedStr = [encryptedStr stringByReplacingOccurrencesOfString:@":" withString:@""];
    }
    OPENSSL_free(hex_ctext);
    OPENSSL_free(result);
    
    return encryptedStr;
}

///MARK: - sm4 解密
+ (nullable NSString *)decrypt:(NSString *)encryptText Key:(NSString *)key{
    if (!encryptText || encryptText.length < 2 || !key || key.length != SM4_BLOCK_SIZE) {
        return nil;
    }
    // 全大写，加上冒号标准化
    NSString *cStr = encryptText.uppercaseString;
    cStr = [GMCodecUtils addColon:cStr];
    
    long ctext_len = 0;
    uint8_t *ctext = OPENSSL_hexstr2buf(cStr.UTF8String, &ctext_len);
    
    // 分组解密
    uint8_t *result = (uint8_t *)OPENSSL_zalloc((int)(ctext_len + 1));
    int groupNum = (int)(ctext_len / SM4_BLOCK_SIZE);
    // 密钥
    uint8_t *ktext = (uint8_t *)key.UTF8String;
    SM4_KEY sm4key;
    SM4_set_key(ktext, &sm4key);
    // 循环解密
    for (NSInteger i = 0; i < groupNum; i++) {
        uint8_t block[SM4_BLOCK_SIZE];
        memcpy(block, ctext + i * SM4_BLOCK_SIZE, SM4_BLOCK_SIZE);
        
        SM4_decrypt(block, block, &sm4key);
        memcpy(result + i * SM4_BLOCK_SIZE, block, SM4_BLOCK_SIZE);
    }
    // 移除填充
    int padLen = (int)result[ctext_len - 1];
    int end_len = (int)(ctext_len - padLen);
    uint8_t *end_result = (uint8_t *)OPENSSL_zalloc((int)(end_len + 1));
    memcpy(end_result, result, end_len);
    
    NSString *plainText = [NSString stringWithCString:(const char *)end_result encoding:NSUTF8StringEncoding];
    
    OPENSSL_free(result);
    OPENSSL_free(end_result);
    
    return plainText;
}


@end
