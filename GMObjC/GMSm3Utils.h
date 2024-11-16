/**
 * SM3 摘要算法，提取数据摘要
 * 摘要长度为 32 字节，转为 16 进制字符串为 64 个字符
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// HMAC 算法主要类型
typedef NS_ENUM(int, GMHashType) {
    GMHashType_SM3 = 0,     // EVP_sm3(void)(默认)
    GMHashType_MD5,         // EVP_md5(void)
    GMHashType_SHA1,        // EVP_sha1(void)
    GMHashType_SHA224,      // EVP_sha224(void)
    GMHashType_SHA256,      // EVP_sha256(void)
    GMHashType_SHA384,      // EVP_sha384(void)
    GMHashType_SHA512       // EVP_sha512(void)
};

@interface GMSm3Utils : NSObject

/// 提取数据或文件的摘要值。返回 SM3 摘要值
/// @param data 待提取摘要的数据
+ (nullable NSData *)hashWithData:(NSData *)data;

/// 提取数据摘要值。返回值 SM3 摘要值（HEX 编码格式）
/// @param text 待提取摘要的数据
+ (nullable NSString *)hashWithText:(NSString *)text;

/// HMAC 算法计算 SM3 摘要。返回 hmac 摘要值
/// @param data NSData 格式的数据明文
/// @param keyData 密钥，任意不为空字符
+ (nullable NSData *)hmacWithData:(NSData *)data keyData:(NSData *)keyData;

/// HMAC 算法计算 SM3 摘要。返回 hmac 摘要值（HEX 编码格式）
/// @param text 待提取摘要的数据
/// @param keyText 密钥，任意不为空字符
+ (nullable NSString *)hmacWithText:(NSString *)text keyText:(NSString *)keyText;

/// HMAC 算法计算其他类型摘要。返回 hmac 摘要值（HEX 编码格式）
/// @param data NSData 格式的数据明文
/// @param keyData NSData 格式的密钥，任意字符
/// @param keyType 选取的摘要算法，详见 GMHashType 枚举
+ (nullable NSData *)hmacWithData:(NSData *)data keyData:(NSData *)keyData keyType:(GMHashType)keyType;

/// HMAC 算法计算其他类型摘要。返回 hmac 摘要值（HEX 编码格式）
/// @param text 待提取摘要的数据
/// @param keyText 密钥，任意不为空字符
/// @param keyType 选取的摘要算法，详见 GMHashType 枚举
+ (nullable NSString *)hmacWithText:(NSString *)text keyText:(NSString *)keyText keyType:(GMHashType)keyType;

@end

NS_ASSUME_NONNULL_END
