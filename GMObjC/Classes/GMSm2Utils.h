//
//  Sm2Utils.h
//  TestPro
//
//  Created by lifei on 2019/7/9.
//  Copyright © 2019 PacteraLF. All rights reserved.
/**
 * SM2 加解密及签名的 OC 封装
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GMSm2Utils : NSObject

/// 创建 SM2 公私钥(基于 NID_sm2 推荐曲线)。返回值：数组元素 1 为公钥，2 为私钥
+ (NSArray<NSString *> *)createKeyPair;

/// SM2 加密。使用 SM2 公钥加密字符串，返回值：加密后的字符串(ASN1编码格式)，失败返回 nil
/// @param plaintext 待加密的原始字符串
/// @param publicKey 04 开头的公钥
+ (nullable NSString *)encrypt:(NSString *)plaintext publicKey:(NSString *)publicKey;

/// SM2 解密。使用 SM2 私钥解密，返回值：解密后的明文，解密失败返回 nil
/// @param ciphertext 密文(ASN1编码格式)
/// @param privateKey 私钥
+ (nullable NSString *)decrypt:(NSString *)ciphertext privateKey:(NSString *)privateKey;

/// ASN1  编码。对 C1C3C2 拼接的原始密文进行 ASN1 编码，返回值：ASN1 编码后的密文
/// @param ciphertext 原始密文(C1C3C2 直接拼接)
+ (nullable NSString *)asn1Encode:(NSString *)ciphertext;

/// ASN1  解码。对 ASN1 格式的密文解码，返回值：解码后的密文(C1C3C2 直接拼接)
/// @param ciphertext ASN1 编码格式的密文
+ (nullable NSString *)asn1Decode:(NSString *)ciphertext;

/// SM2 数字签名。返回值：数字签名，格式为(r,s)逗号分隔的 16 进制字符串
/// @param plaintext 明文
/// @param priKey SM2 私钥
/// @param userID 用户ID，为空时默认 1234567812345678；不为空时，签名和验签需要相同 ID
+ (nullable NSString *)sign:(NSString *)plaintext privateKey:(NSString *)priKey userID:(nullable NSString *)userID;

/// SM2 验证数字签名。返回值：验签结果，YES 为通过，NO 为不通过
/// @param plaintext 明文
/// @param sign 数字签名，格式为(r,s)拼接的 16 进制字符串
/// @param pubKey SM2 公钥
/// @param userID 用户ID，为空时默认 1234567812345678；不为空时，签名和验签需要相同 ID
+ (BOOL)verify:(NSString *)plaintext sign:(NSString *)sign publicKey:(NSString *)pubKey userID:(nullable NSString *)userID;

/// Der 编码。返回值：SM2 数字签名， Der 编码格式
/// @param originSign 格式为(r,s)逗号分隔的 16 进制字符串
+ (nullable NSString *)derEncode:(NSString *)originSign;

/// Der 解码。SM2 数字签名 Der 解码，返回值：数字签名，(r,s)逗号分隔 16 进制字符串格式
/// @param derSign Der 编码格式的数字签名
+ (nullable NSString *)derDecode:(NSString *)derSign;

/// 椭圆曲线Diffie-Hellman密钥协商（ECDH），返回 64 字节 16 进制编码格式密钥
/// @param publicKey 临时公钥（其他端传入的公钥）
/// @param privateKey 临时私钥（当前端生成的私钥）
+ (nullable NSString *)computeECDH:(NSString *)publicKey privateKey:(NSString *)privateKey;

@end

NS_ASSUME_NONNULL_END
