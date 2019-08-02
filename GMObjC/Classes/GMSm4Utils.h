//
//  GMSm4Utils.h
//
//  Created by lifei on 2019/7/30.
//  Copyright © 2019 lifei. All rights reserved.
/**
 * ECB 加密方式，密文分割成长度相等的块（不足补齐），逐个块加密。
 * sm4 加密需要 16 位对齐，若原文长度不是 16 的倍数，则需补齐 Padding。
 * Padding 规则：采用类似 PKCS7Padding 的方式，末位肯定是填充的长度。
 * 填充长度为 1-16 位，加密字符长度 len，填充长度 = 16 - len % 16。
 * 加密密文为 16 进制字符串格式。
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GMSm4Utils : NSObject


/**
 * 生成 sm4 密钥，有随机数字字母构成
 @return 长度为 16 的字符串密钥
 */
+ (nullable NSString *)createSm4Key;

/**
 * sm4 加密
 @param plainText 待加密的字符串
 @param key sm4 密钥，长度 16 字节
 @return 加密后的字符串，16进制编码格式
 */
+ (nullable NSString *)encrypt:(NSString *)plainText Key:(NSString *)key;

/**
 * sm4 解密
 @param encryptText 密文
 @param key sm4 密钥，长度 16 字节
 @return 解密后的明文
 */
+ (nullable NSString *)decrypt:(NSString *)encryptText Key:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
