//
//  Sm2Utils.h
//  TestPro
//
//  Created by lifei on 2019/7/9.
//  Copyright © 2019 PacteraLF. All rights reserved.
/**
 * Sm2 加解密 OC 封装
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GMSm2Utils : NSObject

/**
 * -------公私钥-------
 * 创建 SM2 公私钥(基于 NID_sm2 推荐曲线)
 @return 数组元素 1 为公钥，2 为私钥
 */
+ (NSArray<NSString *> *)createPublicAndPrivateKey;

/**
 * -------加密-------
 * 使用 SM2 公钥加密字符串，加密失败返回 nil
 @param plainText 待加密的原始字符串
 @param publicKey 04 开头的公钥
 @return 加密后的字符串(ASN1编码格式)
 */
+ (nullable NSString *)encrypt:(NSString *)plainText PublicKey:(NSString *)publicKey;

/**
 * -------解密-------
 * 使用 SM2 私钥解密，解密失败返回 nil
 @param encryptText 密文(ASN1编码格式)
 @param privateKey 私钥
 @return 解密后的明文
 */
+ (nullable NSString *)decrypt:(NSString *)encryptText PrivateKey:(NSString *)privateKey;

/**
 * -------ASN1 编码-------
 * 对 C1C3C2 拼接的原始密文进行 ASN1 编码
 @param encryptText 原始密文(C1C3C2 直接拼接)
 @return 编码后的密文
 */
+ (nullable NSString *)encodeWithASN1:(NSString *)encryptText;

/**
 * -------ASN1 解码-------
 * 对 ASN1 格式的密文解码
 @param encryptText ASN1 编码格式的密文
 @return 解码后的密文(C1C3C2 直接拼接)
 */
+ (nullable NSString *)decodeWithASN1:(NSString *)encryptText;

/**
 * -------SM2 数字签名-------
 @param plainText 明文
 @param priKey SM2 私钥
 @param userID 用户ID，可为空；不为空时，签名和验签需要相同 ID
 @return 数字签名，格式为(r, s)拼接的 16 进制字符串
 */
+ (nullable NSString *)sign:(NSString *)plainText PrivateKey:(NSString *)priKey UserID:(NSString *)userID;

/**
 * -------SM2 验证数字签名-------
 @param plainText 明文
 @param sign 数字签名，格式为(r, s)拼接的 16 进制字符串
 @param pubKey SM2 公钥
 @param userID 用户ID，可为空；不为空时，签名和验签需要相同 ID
 @return 验签结果，YES 为通过，NO 为不通过
 */
+ (BOOL)verify:(NSString *)plainText Sign:(NSString *)sign PublicKey:(NSString *)pubKey UserID:(NSString *)userID;

/**
 * -------SM2 数字签名 Der 编码-------
 @param originSign 格式为(r, s)拼接的 16 进制字符串
 @return 数字签名，Der 编码格式
 */
+ (NSString *)encodeWithDer:(NSString *)originSign;

/**
 * -------SM2 数字签名 Der 解码-------
 @param derSign Der 编码格式的数字签名
 @return 数字签名，(r, s)拼接 16 进制字符串格式
 */
+ (NSString *)decodeWithDer:(NSString *)derSign;

@end

NS_ASSUME_NONNULL_END
