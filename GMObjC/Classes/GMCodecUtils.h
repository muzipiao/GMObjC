//
//  Sm2HexUtils.h
//  GMPro
//
//  Created by lifei on 2019/7/18.
//  Copyright © 2019 lifei. All rights reserved.
/**
 * 加解密可能用到的工具
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GMCodecUtils : NSObject

/**
 * 字符串每两位加一个冒号(:)
 @param str 原字符串
 @return 加冒号后的字符串
 */
+ (nullable NSString *)addColon:(NSString *)str;

/**
 * 字符串 16 进制编码
 @param str 待编码的字符串
 @return 16 进制编码的字符串
 */
+ (nullable NSString *)stringToHex:(NSString *)str;

/**
 * 16 进制字符串解码
 @param hexStr 16 编码进制字符串
 @return 解码后的原文
 */
+ (nullable NSString *)hexToString:(NSString *)hexStr;

@end

NS_ASSUME_NONNULL_END
