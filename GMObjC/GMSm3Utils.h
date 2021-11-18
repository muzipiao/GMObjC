//
//  GMSm3Utils.h
//  BaseDemo
//
//  Created by lifei on 2019/8/2.
//  Copyright © 2019 lifei. All rights reserved.
/**
 * SM3 摘要算法，提取数据摘要
 * 摘要长度为 32 字节，转为 16 进制字符串为 64 个字符
 */

#import <Foundation/Foundation.h>
#import "GMUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface GMSm3Utils : NSObject

/// 提取文本字符串的摘要值。返回值：摘要值，16进制编码格式
/// @param plaintext 待提取摘要的字符串
+ (nullable NSString *)hashWithString:(NSString *)plaintext;

/// 提取数据或文件的摘要值。返回值：摘要值，16进制编码格式
/// @param plainData 待提取摘要的数据
+ (nullable NSString *)hashWithData:(NSData *)plainData;


/// HMAC 算法计算摘要。返回值：计算的摘要长度和原摘要算法长度相同，16进制编码格式
/// @param key  密钥字符串，keyData:：NSData 格式的 密钥
/// @param plaintext 待计算的消息明文，plainData：NSData 格式的消息明文
+ (nullable NSString *)hmacWithSm3:(NSString *)key plaintext:(NSString *)plaintext;
+ (nullable NSString *)hmacWithSm3:(NSData *)keyData plainData:(NSData *)plainData;

/// HMAC 算法计算摘要。返回值：计算的摘要长度和原摘要算法长度相同，16进制编码格式
/// @param type 选取的摘要算法，详见 GMObjCDef.h 中 GMHashType 枚举
/// @param key 密钥字符串，keyData: NSData 格式的 密钥
/// @param plaintext 待计算的消息明文，plainData：NSData 格式的消息明文
+ (nullable NSString *)hmac:(GMHashType)type key:(NSString *)key plaintext:(NSString *)plaintext;
+ (nullable NSString *)hmac:(GMHashType)type keyData:(NSData *)keyData plainData:(NSData *)plainData;

@end

NS_ASSUME_NONNULL_END
