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

NS_ASSUME_NONNULL_BEGIN

@interface GMSm3Utils : NSObject

/// 提取文本字符串的摘要值。返回值：摘要值，16进制编码格式
/// @param plaintext 待提取摘要的字符串
+ (nullable NSString *)hashWithString:(NSString *)plaintext;

/// 提取数据或文件的摘要值。返回值：摘要值，16进制编码格式
/// @param plainData 待提取摘要的数据
+ (nullable NSString *)hashWithData:(NSData *)plainData;

@end

NS_ASSUME_NONNULL_END
