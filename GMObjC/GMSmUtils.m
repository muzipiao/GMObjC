#import "GMSmUtils.h"
#import <openssl/crypto.h>

@implementation GMSmUtils

//MARK: - Hex 编码
/// 字符串 16 进制编码。返回值：16 进制编码的字符串
/// @param text 待编码的字符串
+ (nullable NSString *)hexStringFromString:(NSString *)text{
    if (!text || text.length == 0) {
        return nil;
    }
    NSData *strData = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSString *tmpHex = [self hexStringFromData:strData];
    return tmpHex;
}

/// NSData 16 进制编码。返回值：16 进制编码的字符串
/// @param data 原数据（NSData 格式）
+ (nullable NSString *)hexStringFromData:(NSData *)data{
    if (!data || data.length == 0) {
        return nil;
    }
    char *tmp = OPENSSL_buf2hexstr((uint8_t *)data.bytes, data.length);
    if (!tmp) {
        return nil;
    }
    NSString *tmpHex = [NSString stringWithCString:tmp encoding:NSUTF8StringEncoding];
    tmpHex = [tmpHex stringByReplacingOccurrencesOfString:@":" withString:@""];
    OPENSSL_free(tmp);
    return tmpHex;
}

//MARK: - Hex 解码
/// 16 进制字符串解码。返回值：解码后的原文
/// @param hexStr 16 编码进制字符串
+ (nullable NSString *)stringFromHexString:(NSString *)hexStr{
    if (!hexStr || hexStr.length < 2) {
        return nil;
    }
    NSData *bufData = [self dataFromHexString:hexStr];
    NSString *bufStr = [[NSString alloc]initWithData:bufData encoding:NSUTF8StringEncoding];
    return bufStr;
}

/// 16 进制字符串解码为 NSData。返回值：解码后的 NSData 对象
/// @param hexStr 16 编码进制字符串
+ (nullable NSData *)dataFromHexString:(NSString *)hexStr{
    if (!hexStr || hexStr.length < 2) {
        return nil;
    }
    long buf_len = 0;
    uint8_t *tmp_buf = OPENSSL_hexstr2buf(hexStr.UTF8String, &buf_len);
    if (!tmp_buf) {
        return nil;
    }
    NSData *tmpData = [NSData dataWithBytes:tmp_buf length:buf_len];
    OPENSSL_free(tmp_buf);
    return tmpData;
}

//MARK: - Base64
/// base64 编码。返回值：编码后的 base64 字符串
/// @param data 待编码的数据
+ (nullable NSString *)base64EncodedStringWithData:(NSData *)data {
    NSData *baseData = [data base64EncodedDataWithOptions:0];
    NSString *baseStr = [[NSString alloc] initWithData:baseData encoding:NSUTF8StringEncoding];
    return baseStr;
}

/// base64 解码。返回值：解码后的 NSData 对象
/// @param base64Str base64 编码格式字符串
+ (nullable NSData *)dataFromBase64EncodedString:(NSString *)base64Str {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return data;
}

/// HEX字符串前面补0，解决 BIGNUM 转 HEX 时，长度不统一问题
/// @param originHex 原 Hex 字符串
/// @param maxLen 补0后长度
+ (NSString *)prefixPaddingZero:(NSString *)originHex maxLen:(NSUInteger)maxLen {
    if (originHex.length == 0 || originHex.length >= maxLen) {
        return originHex;
    }
    NSMutableString *padding = [NSMutableString stringWithString:originHex];
    while (padding.length < maxLen) {
        [padding insertString:@"0" atIndex:0];
    }
    return padding.copy;
}

@end
