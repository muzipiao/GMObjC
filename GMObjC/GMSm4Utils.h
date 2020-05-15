//
//  GMSm4Utils.h
//
//  Created by lifei on 2019/7/30.
//  Copyright © 2019 lifei. All rights reserved.
/**
 * ECB 电子密码本模式，密文分割成长度相等的块（不足补齐），逐个块加密。
 * CBC 密文分组链接模式，前一个分组的密文和当前分组的明文异或或操作后再加密。
 * SM4 加密需要 16 位对齐，若原文长度不是 16 的倍数，则需补齐 Padding。
 * Padding 规则：采用 PKCS7Padding 补码方式，末位肯定是填充的长度。
 * 填充长度为 1-16 位，加密字符长度 len，填充长度 = 16 - len % 16。
 * Hex 代表 16 进制，加密密文为 Hex 编码字符串格式。
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GMSm4Utils : NSObject

/// 生成 SM4 密钥。返回值：长度为 32 字节 Hex 编码格式字符串密钥
+ (nullable NSString *)createSm4Key;

///MARK: - SM4 字符串加解密

/// SM4 字符串加密。返回值：加密后的字符串，Hex 编码格式
/// CBC 模式需传入 32 字节 Hex 编码格式 ivec 字符串
/// @param plaintext 待加密的字符串
/// @param key SM4 密钥，长度  32 字节 Hex 编码格式字符串
+ (nullable NSString *)ecbEncryptText:(NSString *)plaintext key:(NSString *)key;
+ (nullable NSString *)cbcEncryptText:(NSString *)plaintext key:(NSString *)key IV:(NSString *)ivec;

/// SM4 字符串解密。返回值：解密后的明文
/// CBC 模式需传入  32 字节 Hex 编码格式 ivec 字符串
/// @param ciphertext 密文（Hex 编码格式）
/// @param key SM4 密钥，长度  32 字节 Hex 编码格式字符串
+ (nullable NSString *)ecbDecryptText:(NSString *)ciphertext key:(NSString *)key;
+ (nullable NSString *)cbcDecryptText:(NSString *)ciphertext key:(NSString *)key IV:(NSString *)ivec;

///MARK: - SM4 Data 加解密

/// SM4 文件加密。返回值：加密后的 NSData 类型密文
/// CBC 模式需传入  32 字节 Hex 编码格式 ivec 字符串
/// @param plainData  明文（NSData 类型）
/// @param key SM4 密钥，长度  32 字节 Hex 编码格式字符串
+ (nullable NSData *)ecbEncryptData:(NSData *)plainData key:(NSString *)key;
+ (nullable NSData *)cbcEncryptData:(NSData *)plainData key:(NSString *)key IV:(NSString *)ivec;

/// SM4 文件解密。返回值：解密后的 NSData 类型原文
/// CBC 模式需传入  32 字节 Hex 编码格式 ivec 字符串
/// @param cipherData 密文（NSData 类型）
/// @param key SM4 密钥，长度  32 字节 Hex 编码格式字符串
+ (nullable NSData *)ecbDecryptData:(NSData *)cipherData key:(NSString *)key;
+ (nullable NSData *)cbcDecryptData:(NSData *)cipherData key:(NSString *)key IV:(NSString *)ivec;

@end

NS_ASSUME_NONNULL_END
