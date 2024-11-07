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

/// 生成 SM4 密钥（Hex 编码格式）。返回值：长度为 SM4_BLOCK_SIZE(16) 字节密钥
+ (nullable NSString *)generateKey;

/// SM4 ECB 模式加密。返回值：加密后的 NSData 类型密文
/// @param plainData 明文（NSData 类型）
/// @param keyData SM4 密钥，长度  SM4_BLOCK_SIZE(16) 字节任意数据
+ (nullable NSData *)encryptDataWithECB:(NSData *)plainData keyData:(NSData *)keyData;
+ (nullable NSString *)encryptTextWithECB:(NSString *)plaintext keyData:(NSString *)keyData;

/// SM4 ECB 模式解密。返回值：解密后的 NSData 类型明文
/// @param cipherData 密文（NSData 类型）
/// @param keyData SM4 密钥，长度  SM4_BLOCK_SIZE(16) 字节任意数据
+ (nullable NSData *)decryptDataWithECB:(NSData *)cipherData keyData:(NSData *)keyData;

/// SM4 CBC 模式加密。返回值：加密后的 NSData 类型密文
/// @param plainData 明文（NSData 类型）
/// @param keyData SM4 密钥，长度  SM4_BLOCK_SIZE(16) 字节任意数据
/// @param ivecData CBC 模式需传入长度  SM4_BLOCK_SIZE(16) 字节任意字符，确保加解密相同即可
+ (nullable NSData *)encryptDataWithCBC:(NSData *)plainData keyData:(NSData *)keyData ivecData:(NSData *)ivecData;

/// SM4 CBC 模式解密。返回值：解密后的 NSData 类型明文
/// @param cipherData 密文（NSData 类型）
/// @param keyData SM4 密钥，长度 SM4_BLOCK_SIZE(16) 字节任意数据
/// @param ivecData CBC 模式需传入长度  SM4_BLOCK_SIZE(16) 字节任意字符，确保加解密相同即可
+ (nullable NSData *)decryptDataWithCBC:(NSData *)cipherData keyData:(NSData *)keyData ivecData:(NSData *)ivecData;


// MARK: - DEPRECATED
//+ (nullable NSString *)createSm4Key API_DEPRECATED_WITH_REPLACEMENT("generateKey", macos(10.10, API_TO_BE_DEPRECATED), ios(8.0, API_TO_BE_DEPRECATED));
//
//+ (nullable NSString *)ecbEncryptText:(NSString *)plaintext key:(NSString *)key API_DEPRECATED_WITH_REPLACEMENT("encryptDataWithECB:keyData:", macos(10.10, API_TO_BE_DEPRECATED), ios(8.0, API_TO_BE_DEPRECATED));
//+ (nullable NSString *)cbcEncryptText:(NSString *)plaintext key:(NSString *)key IV:(NSString *)ivec API_DEPRECATED_WITH_REPLACEMENT("encryptDataWithCBC:keyData:", macos(10.10, API_TO_BE_DEPRECATED), ios(8.0, API_TO_BE_DEPRECATED));
//
//+ (nullable NSString *)ecbDecryptText:(NSString *)ciphertext key:(NSString *)key API_DEPRECATED_WITH_REPLACEMENT("decryptDataWithECB:keyData:", macos(10.10, API_TO_BE_DEPRECATED), ios(8.0, API_TO_BE_DEPRECATED));
//+ (nullable NSString *)cbcDecryptText:(NSString *)ciphertext key:(NSString *)key IV:(NSString *)ivec API_DEPRECATED_WITH_REPLACEMENT("decryptDataWithCBC:keyData:", macos(10.10, API_TO_BE_DEPRECATED), ios(8.0, API_TO_BE_DEPRECATED));
//
//+ (nullable NSData *)ecbEncryptData:(NSData *)plainData key:(NSString *)key API_DEPRECATED_WITH_REPLACEMENT("encryptDataWithECB:keyData:", macos(10.10, API_TO_BE_DEPRECATED), ios(8.0, API_TO_BE_DEPRECATED));
//+ (nullable NSData *)cbcEncryptData:(NSData *)plainData key:(NSString *)key IV:(NSString *)ivec API_DEPRECATED_WITH_REPLACEMENT("encryptDataWithCBC:keyData:", macos(10.10, API_TO_BE_DEPRECATED), ios(8.0, API_TO_BE_DEPRECATED));
//
//+ (nullable NSData *)ecbDecryptData:(NSData *)cipherData key:(NSString *)key API_DEPRECATED_WITH_REPLACEMENT("decryptDataWithECB:keyData:", macos(10.10, API_TO_BE_DEPRECATED), ios(8.0, API_TO_BE_DEPRECATED));
//+ (nullable NSData *)cbcDecryptData:(NSData *)cipherData key:(NSString *)key IV:(NSString *)ivec API_DEPRECATED_WITH_REPLACEMENT("decryptDataWithCBC:keyData:", macos(10.10, API_TO_BE_DEPRECATED), ios(8.0, API_TO_BE_DEPRECATED));

@end

NS_ASSUME_NONNULL_END
