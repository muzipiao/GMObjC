//
//  GMSm4Utils.h
//
//  Created by lifei on 2019/7/30.
//  Copyright © 2019 lifei. All rights reserved.
/**
 * ECB 电子密码本模式，密文分割成长度相等的块（不足补齐），逐个块加密。
 * CBC 密文分组链接模式，前一个分组的密文和当前分组的明文异或或操作后再加密。
 * sm4 加密需要 16 位对齐，若原文长度不是 16 的倍数，则需补齐 Padding。
 * Padding 规则：采用 PKCS7Padding 补码方式，末位肯定是填充的长度。
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

///MARK: - sm4 字符串加解密

/**
 * sm4 字符串加密，cbc模式需传入 16 字节的向量字符串。
 @param plaintext 待加密的字符串
 @param key sm4 密钥，长度 16 字节
 @return 加密后的字符串，16进制编码格式
 */
+ (nullable NSString *)ecbEncrypt:(NSString *)plaintext Key:(NSString *)key;
+ (nullable NSString *)cbcEncrypt:(NSString *)plaintext Key:(NSString *)key IV:(NSString *)ivec;

/**
 * sm4 字符串解密，cbc模式需传入 16 字节的向量字符串。
 @param ciphertext 密文
 @param key sm4 密钥，长度 16 字节
 @return 解密后的明文
 */
+ (nullable NSString *)ecbDecrypt:(NSString *)ciphertext Key:(NSString *)key;
+ (nullable NSString *)cbcDecrypt:(NSString *)ciphertext Key:(NSString *)key IV:(NSString *)ivec;

///MARK: - sm4 Data 加解密

/**
 * sm4 文件加密，cbc模式需传入 16 字节的向量字符串。
 @param plainData 从文件读取 NSData
 @param key sm4 密钥，长度 16 字节
 @return 加密后的 NSData
 */
+ (nullable NSData *)ecbEncryptData:(NSData *)plainData Key:(NSString *)key;
+ (nullable NSData *)cbcEncryptData:(NSData *)plainData Key:(NSString *)key IV:(NSString *)ivec;

/**
 * sm4 文件解密，cbc模式需传入 16 字节的向量字符串。
 @param cipherData 加密的 NSData
 @param key sm4 密钥，长度 16 字节
 @return 解密后的 NSData 原文
 */
+ (nullable NSData *)ecbDecryptData:(NSData *)cipherData Key:(NSString *)key;
+ (nullable NSData *)cbcDecryptData:(NSData *)cipherData Key:(NSString *)key IV:(NSString *)ivec;

@end

NS_ASSUME_NONNULL_END
