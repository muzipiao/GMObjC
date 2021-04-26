//
//  Sm2Utils.h
//  TestPro
//
//  Created by lifei on 2019/7/9.
//  Copyright © 2019 PacteraLF. All rights reserved.
/**
 * SM2 加解密及签名的 OC 封装
 * Hex 编码格式代表 16 进制编码格式
 */

#import <Foundation/Foundation.h>
#import "GMUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface GMSm2Utils : NSObject

///MARK: - 创建秘钥对
/// 创建 SM2 公私钥（基于官方文档 NID_sm2 推荐曲线）。返回值：数组元素 1 为公钥，2 为私钥
+ (NSArray<NSString *> *)createKeyPair;

///MARK: - SM2 加密
/// SM2 加密。返回值：加密后的字符串或 NSData（密文都为 ASN1 编码格式，可解码为 C1C3C2 格式），失败返回 nil
/// @param plaintext 明文（普通字符串格式）；plainHex 明文（ Hex 编码格式）；plainData 明文（NSData 格式）
/// @param publicKey 04 开头的公钥（ Hex 编码格式）
+ (nullable NSString *)encryptText:(NSString *)plaintext publicKey:(NSString *)publicKey;
+ (nullable NSString *)encryptHex:(NSString *)plainHex publicKey:(NSString *)publicKey;
+ (nullable NSData *)encryptData:(NSData *)plainData publicKey:(NSString *)publicKey;

///MARK: - SM2 解密
/// SM2 解密。返回值：decryptToText 返回普通明文；decryptToHex 返回 Hex 格式明文；decryptToData 返回 NSData 格式明文，解密失败返回 nil
/// @param ciphertext 密文（ASN1 编码格式）；cipherData 密文（NSData 格式）
/// @param privateKey 私钥（ Hex 编码格式）
+ (nullable NSString *)decryptToText:(NSString *)ciphertext privateKey:(NSString *)privateKey;
+ (nullable NSString *)decryptToHex:(NSString *)ciphertext privateKey:(NSString *)privateKey;
+ (nullable NSData *)decryptToData:(NSData *)cipherData privateKey:(NSString *)privateKey;

///MARK: - ASN1 编码解码
/// ASN1  编码。对 c1c3c2 格式密文进行 ASN1 编码，返回值：ASN1 编码后的密文。
/// 参数：c1c3c2Hex 密文（字符串拼接 c1c3c2）；c1c3c2Array 密文数组（@[c1,c3,c2]）；c1c3c2Data 密文 Data（NSData 类型拼接的 c1c3c2）
/// @param c1c3c2Hex 原始密文（c1c3c2 直接拼接的密文字符串， Hex 格式）
+ (nullable NSString *)asn1EncodeWithC1C3C2:(NSString *)c1c3c2Hex;
+ (nullable NSString *)asn1EncodeWithC1C3C2Array:(NSArray<NSString *> *)c1c3c2Array;
+ (nullable NSData *)asn1EncodeWithC1C3C2Data:(NSData *)c1c3c2Data;

/// ASN1  解码。对 ASN1 格式的密文解码，返回值：解码后的密文
/// 返回值样式：c1c3c2 直接拼接；数组依次存放 @[c1,c3,c2]；NSData 类型拼接的c1c3c2
/// @param asn1Hex ASN1 编码格式的密文（Hex 格式）；asn1Data ASN1 编码格式的密文（NSData 格式）
+ (nullable NSString *)asn1DecodeToC1C3C2:(NSString *)asn1Hex;
+ (nullable NSArray<NSString *> *)asn1DecodeToC1C3C2Array:(NSString *)asn1Hex;
+ (nullable NSData *)asn1DecodeToC1C3C2Data:(NSData *)asn1Data;

///MARK: - 签名验签
/// SM2 数字签名。返回值：数字签名，RS 拼接的 128 字节 Hex 格式字符串，前 64 字节是 R，后 64 字节是 S
/// userID 或 userHex，用户ID 可传空值，为空时默认 1234567812345678；不为空时，签名和验签需要相同 ID
/// @param plaintext 明文（普通字符串）；plainHex 明文（Hex 编码格式）；plainData 明文（NSData 格式）
/// @param priKey SM2 私钥（Hex 编码格式）
/// @param userID 用户 ID（普通字符串）；userHex 用户 ID（Hex 编码格式）；userID 用户 ID（NSData 格式）
+ (nullable NSString *)signText:(NSString *)plaintext privateKey:(NSString *)priKey userID:(nullable NSString *)userID;
+ (nullable NSString *)signHex:(NSString *)plainHex privateKey:(NSString *)priKey userHex:(nullable NSString *)userHex;
+ (nullable NSString *)signData:(NSData *)plainData priKey:(NSString *)priKey userData:(nullable NSData *)userData;

/// SM2 验证数字签名。返回值：验签结果，YES 为通过，NO 为不通过
/// userID 或 userHex，用户ID 可传空值，为空时默认 1234567812345678；不为空时，签名和验签需要相同 ID
/// @param plaintext 明文（普通字符串）；plainHex 明文（Hex 编码格式）；plainData 明文（NSData 格式）
/// @param signRS 数字签名，RS 拼接的 128 字节 Hex 格式字符串，前 64 字节是 R，后 64 字节是 S
/// @param pubKey SM2 公钥（Hex 编码格式）
/// @param userID 用户 ID（普通字符串）；userHex 用户 ID（Hex 编码格式）；userID 用户 ID（NSData 格式）
+ (BOOL)verifyText:(NSString *)plaintext signRS:(NSString *)signRS publicKey:(NSString *)pubKey userID:(nullable NSString *)userID;
+ (BOOL)verifyHex:(NSString *)plainHex signRS:(NSString *)signRS publicKey:(NSString *)pubKey userHex:(nullable NSString *)userHex;
+ (BOOL)verifyData:(NSData *)plainData signRS:(NSString *)signRS pubKey:(NSString *)pubKey userData:(nullable NSData *)userData;

///MARK: - Der 编码解码
/// Der 编码。返回值：SM2 数字签名， Der 编码格式
/// @param signRS RS 拼接的 128 字节 Hex 格式字符串，前 64 字节是 R，后 64 字节是 S
+ (nullable NSString *)derEncode:(NSString *)signRS;

/// Der 解码。SM2 数字签名 Der 解码，返回值：数字签名，RS 拼接的 128 字节 Hex 格式字符串，前 64 字节是 R，后 64 字节是 S
/// @param derSign Der 编码格式的数字签名
+ (nullable NSString *)derDecode:(NSString *)derSign;

///MARK: - ECDH 密钥协商
/// 椭圆曲线 Diffie-Hellman 密钥协商（ECDH），返回 64 字节 16 进制编码格式密钥
/// @param publicKey 临时公钥（其他端传入的公钥）
/// @param privateKey 临时私钥（当前端生成的私钥）
+ (nullable NSString *)computeECDH:(NSString *)publicKey privateKey:(NSString *)privateKey;

///MARK: - 椭圆曲线类型
/// 常见椭圆曲线为 NID_sm2、NID_secp256k1、NID_X9_62_prime256v1
/// 默认 NID_sm2，参考 GMObjCDef.h 中说明，一般不需更改
/// 若需要更改，传入枚举 GMCurveType 枚举值即可
/// 若需要其他曲线，在 OpenSSL 源码 crypto/ec/ec_curve.c 查找
+ (int)ellipticCurveType;
+ (void)setEllipticCurveType:(int)curveType;

@end

NS_ASSUME_NONNULL_END
