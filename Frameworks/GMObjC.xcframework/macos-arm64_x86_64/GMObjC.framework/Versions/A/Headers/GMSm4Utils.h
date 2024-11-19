/**
 * ECB 电子密码本模式，密文分割成长度相等的块（不足补齐），逐个块加密。
 * CBC 密文分组链接模式，前一个分组的密文和当前分组的明文异或或操作后再加密。
 * SM4 加密需要 16 位对齐，若原文长度不是 16 的倍数，则需补齐 Padding。
 * Padding 规则：采用 PKCS7Padding 补码方式，末位肯定是填充的长度。
 * 填充长度为 1-16 位，加密字符长度 len，填充长度 = 16 - len % 16。
 * HEX 代表 16 进制，加密密文为 HEX 编码字符串格式。
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GMSm4Utils : NSObject

/// 生成 SM4 密钥（HEX 编码格式）。返回值：长度为 SM4_BLOCK_SIZE(16) 字节密钥
+ (nullable NSString *)generateKey;

/// SM4 ECB 模式加密。返回值：加密后的密文
/// @param plainData 明文（NSData 类型）
/// @param keyData SM4 密钥，长度  SM4_BLOCK_SIZE(16) 字节任意数据
+ (nullable NSData *)encryptDataWithECB:(NSData *)plainData keyData:(NSData *)keyData;

/// SM4 ECB 模式加密。返回值：加密后的密文（HEX 编码格式）
/// @param plaintext 明文（字符串类型）
/// @param keyHex  密钥（HEX 编码格式）
+ (nullable NSString *)encryptTextWithECB:(NSString *)plaintext keyHex:(NSString *)keyHex;

/// SM4 ECB 模式解密。返回值：解密后的明文
/// @param cipherData 密文（NSData 类型）
/// @param keyData SM4 密钥，长度  SM4_BLOCK_SIZE(16) 字节任意数据
+ (nullable NSData *)decryptDataWithECB:(NSData *)cipherData keyData:(NSData *)keyData;

/// SM4 ECB 模式解密。返回值：解密后的明文（HEX 编码格式）
/// @param ciphertext 密文（HEX 编码格式）
/// @param keyHex 密钥（HEX 编码格式）
+ (nullable NSString *)decryptTextWithECB:(NSString *)ciphertext keyHex:(NSString *)keyHex;

/// SM4 CBC 模式加密。返回值：加密后的密文
/// @param plainData 明文（NSData 类型）
/// @param keyData SM4 密钥，长度  SM4_BLOCK_SIZE(16) 字节任意数据
/// @param ivecData CBC 模式需传入长度  SM4_BLOCK_SIZE(16) 字节任意字符，确保加解密相同即可
+ (nullable NSData *)encryptDataWithCBC:(NSData *)plainData keyData:(NSData *)keyData ivecData:(NSData *)ivecData;

/// SM4 CBC 模式加密。返回值：加密后的密文（HEX 编码格式）
/// @param plaintext 明文（字符串类型）
/// @param keyHex 密钥（HEX 编码格式）
/// @param ivecHex 密钥（HEX 编码格式），确保加解密相同即可
+ (nullable NSString *)encryptTextWithCBC:(NSString *)plaintext keyHex:(NSString *)keyHex ivecHex:(NSString *)ivecHex;

/// SM4 CBC 模式解密。返回值：解密后的明文
/// @param cipherData 密文（NSData 类型）
/// @param keyData SM4 密钥，长度 SM4_BLOCK_SIZE(16) 字节任意数据
/// @param ivecData CBC 模式需传入长度  SM4_BLOCK_SIZE(16) 字节任意字符，确保加解密相同即可
+ (nullable NSData *)decryptDataWithCBC:(NSData *)cipherData keyData:(NSData *)keyData ivecData:(NSData *)ivecData;

/// SM4 CBC 模式解密。返回值：解密后的明文
/// @param ciphertext 密文（字符串类型）
/// @param keyHex 密钥（HEX 编码格式）
/// @param ivecHex 密钥（HEX 编码格式），确保加解密相同即可
+ (nullable NSString *)decryptTextWithCBC:(NSString *)ciphertext keyHex:(NSString *)keyHex ivecHex:(NSString *)ivecHex;

@end

NS_ASSUME_NONNULL_END
