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
    // 33 至 126
    char ch[len];
    for (NSInteger index=0; index<len; index++) {
        int num = arc4random_uniform(93)+33;
        ch[index] = num;
    }
    return [[NSString alloc] initWithBytes:ch length:len encoding:NSUTF8StringEncoding];
}

///MARK: - sm4 加密
+ (nullable NSString *)encrypt:(NSString *)plainText Key:(NSString *)key{
    if (!plainText || plainText.length == 0 || !key || key.length != SM4_BLOCK_SIZE) {
        return nil;
    }
    // 填充 0
    NSInteger padLen = 0;
    size_t pTextLen = strlen(plainText.UTF8String);
    if (pTextLen % SM4_BLOCK_SIZE != 0) {
        padLen = SM4_BLOCK_SIZE - pTextLen % SM4_BLOCK_SIZE;
    }
    NSMutableString *mStr = [NSMutableString stringWithString:plainText];
    for (NSInteger i = 0; i < padLen; i++) {
        [mStr appendString:@"0"];
    }
    // 分组加密
    size_t resultLen = strlen(mStr.UTF8String);
    uint8_t *result = (uint8_t *)OPENSSL_zalloc((int)(resultLen + 1));
    int groupNum = (int)(resultLen / SM4_BLOCK_SIZE);
    // 密钥
    uint8_t *ktext = (uint8_t *)key.UTF8String;
    SM4_KEY sm4key;
    SM4_set_key(ktext, &sm4key);
    // 循环加密
    const char *pText = mStr.UTF8String;
    for (NSInteger i = 0; i < groupNum; i++) {
        uint8_t block[SM4_BLOCK_SIZE];
        memcpy(block, pText + i * SM4_BLOCK_SIZE, SM4_BLOCK_SIZE);
        
        SM4_encrypt(block, block, &sm4key);
        memcpy(result + i * SM4_BLOCK_SIZE, block, SM4_BLOCK_SIZE);
    }
    
    char *hex_ctext = OPENSSL_buf2hexstr(result, resultLen);
    NSString *encryptedStr = [NSString stringWithCString:hex_ctext encoding:NSUTF8StringEncoding];
    // 末尾加上长度
    if (encryptedStr) {
        encryptedStr = [encryptedStr stringByReplacingOccurrencesOfString:@":" withString:@""];
        encryptedStr = [NSString stringWithFormat:@"%@%02d",encryptedStr,(int)padLen];
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
    // 补码长度
    NSInteger hexLen = encryptText.length - 2;
    NSString *padStr = [encryptText substringFromIndex:hexLen];
    NSInteger padLen = padStr.integerValue;
    
    encryptText = [encryptText substringToIndex:hexLen].uppercaseString;
    encryptText = [GMCodecUtils addColon:encryptText];
    
    long ctext_len = 0;
    uint8_t *ctext = OPENSSL_hexstr2buf(encryptText.UTF8String, &ctext_len);
    
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
    
    NSString *plainText = [NSString stringWithCString:(const char *)result encoding:NSUTF8StringEncoding];
    if (plainText.length > padLen) {
        NSInteger plainTextLen = plainText.length - padLen;
        plainText = [plainText substringToIndex:plainTextLen];
    }
    
    OPENSSL_free(result);
    
    return plainText;
}


@end
