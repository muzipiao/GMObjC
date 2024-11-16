/**
 * GMObjC 加解密可能用到的工具
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GMSmUtils : NSObject

// MARK: - HEX 编码
/// 字符串 16 进制编码。返回值：16 进制编码的字符串
/// @param text 待编码的字符串
+ (nullable NSString *)hexStringFromString:(NSString *)text;

/// NSData 16 进制编码。返回值：16 进制编码的字符串
/// @param data 原数据（NSData 格式）
+ (nullable NSString *)hexStringFromData:(NSData *)data;

// MARK: - Hex 解码
/// 16 进制字符串解码。返回值：解码后的原文
/// @param hexStr 16 编码进制字符串
+ (nullable NSString *)stringFromHexString:(NSString *)hexStr;

/// 16 进制字符串解码为 NSData。返回值：解码后的 NSData 对象
/// @param hexStr 16 编码进制字符串
+ (nullable NSData *)dataFromHexString:(NSString *)hexStr;

// MARK: - Base64
/// base64 编码。返回值：编码后的 base64 字符串
/// @param data 待编码的数据
+ (nullable NSString *)base64EncodedStringWithData:(NSData *)data;

/// base64 解码。返回值：解码后的 NSData 对象
/// @param base64Str base64 编码格式字符串
+ (nullable NSData *)dataFromBase64EncodedString:(NSString *)base64Str;

// MARK: - Convert
/// 检查是否为字符串类型 Data，将字符串转为 Data
/// - Parameter data: 待检查的字符串
+ (nullable NSData *)checkStringData:(NSData *)data;

/// 检查是否为有效的 16 进制编码
/// @param hexStr 16 进制编码格式字符串
+ (BOOL)isValidHexString:(NSString *)hexStr;

/// 检查是否为有效的 base64 编码
/// @param base64Str base64 编码格式字符串
+ (BOOL)isValidBase64String:(NSString *)base64Str;

// MARK: - Padding
/// HEX字符串前面补0，解决 BIGNUM 转 HEX 时，长度不统一问题
/// @param originHex 原 HEX 字符串
/// @param maxLen 补0后长度
+ (NSString *)prefixPaddingZero:(NSString *)originHex maxLen:(NSUInteger)maxLen;

@end

NS_ASSUME_NONNULL_END
