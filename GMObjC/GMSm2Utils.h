/**
 SM2 加解密及签名的 OC 封装
 1. GM/T 0003-2012 标准推荐参数  sm2p256v1（NID_sm2）；
 2. 若需使用其他曲线，可在 OpenSSL 源码 crypto/ec/ec_curve.c 中查找。
 
 ECC推荐参数：sm2p256v1（对应 OpenSSL 中 NID_sm2）
 p   = FFFFFFFE FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF 00000000 FFFFFFFF FFFFFFFF
 a   = FFFFFFFE FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF 00000000 FFFFFFFF FFFFFFFC
 b   = 28E9FA9E 9D9F5E34 4D5A9E4B CF6509A7 F39789F5 15AB8F92 DDBCBD41 4D940E93
 n   = FFFFFFFE FFFFFFFF FFFFFFFF FFFFFFFF 7203DF6B 21C6052B 53BBF409 39D54123
 Gx =  32C4AE2C 1F198119 5F990446 6A39C994 8FE30BBF F2660BE1 715A4589 334C74C7
 Gy =  BC3736A2 F4F6779C 59BDCEE3 6B692153 D0A9877C C62A4740 02DF32E5 2139F0A0
 
 ECC推荐参数：secp256k1（对应 OpenSSL 中 NID_secp256k1）
 p   = FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE FFFFFC2F
 a   = 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
 b   = 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000007
 n   = FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE BAAEDCE6 AF48A03B BFD25E8C D0364141
 Gx =  79BE667E F9DCBBAC 55A06295 CE870B07 029BFCDB 2DCE28D9 59F2815B 16F81798
 Gy =  483ADA77 26A3C465 5DA4FBFC 0E1108A8 FD17B448 A6855419 9C47D08F FB10D4B8
 
 ECC推荐参数：secp256r1（对应 OpenSSL 中 NID_X9_62_prime256v1）
 p   = FFFFFFFF 00000001 00000000 00000000 00000000 FFFFFFFF FFFFFFFF FFFFFFFF
 a   = FFFFFFFF 00000001 00000000 00000000 00000000 FFFFFFFF FFFFFFFF FFFFFFFC
 b   = 5AC635D8 AA3A93E7 B3EBBD55 769886BC 651D06B0 CC53B0F6 3BCE3C3E 27D2604B
 n   = FFFFFFFF 00000000 FFFFFFFF FFFFFFFF BCE6FAAD A7179E84 F3B9CAC2 FC632551
 Gx  = 6B17D1F2 E12C4247 F8BCE6E5 63A440F2 77037D81 2DEB33A0 F4A13945 D898C296
 Gy  = 4FE342E2 FE1A7F9B 8EE7EB4A 7C0F9E16 2BCE3357 6B315ECE CBB64068 37BF51F5
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 常用标准椭圆曲线，默认 NID_sm2，无特殊情况，使用默认即可
typedef NS_ENUM(int, GMSm2CurveType) {
    GMSm2CurveSm2p256v1 = 1172,   // NID_sm2(默认)
    GMSm2CurveSecp256k1 = 714,    // NID_secp256k1
    GMSm2CurveSecp256r1 = 415     // NID_X9_62_prime256v1
};

// SM2 公私钥（默认基于官方文档 NID_sm2 推荐曲线）
@interface GMSm2Key : NSObject

@property (nullable, nonatomic, copy) NSString *publicKey;  // SM2 公钥(HEX 编码格式)
@property (nullable, nonatomic, copy) NSString *privateKey; // SM2 私钥(HEX 编码格式)

@end

@interface GMSm2Utils : NSObject

// MARK: - 创建秘钥对
/// 创建 SM2 公私钥（基于官方文档 NID_sm2 推荐曲线）。返回值：公钥和私钥 HEX 编码字符串
+ (GMSm2Key *)generateKey;

// MARK: - SM2 加解密
/// SM2 加密。返回 ASN1 编码密文（ASN1 编码可使用 asn1DecodeToC1C3C2Data 解码为非 ASN1 编码），失败返回 nil
/// @param plainData 明文（NSData 格式）
/// @param publicHex 04 开头的公钥（ HEX 编码格式）
+ (nullable NSData *)encryptData:(NSData *)plainData publicKey:(NSString *)publicHex;

/// SM2 加密。返回 ASN1 编码密文（ASN1 编码可使用 asn1DecodeToC1C3C2Hex 解码为非 ASN1 编码），失败返回 nil
/// @param plaintext 明文（NSString 原文格式）
/// @param publicHex 04 开头的公钥（ HEX 编码格式）
+ (nullable NSString *)encryptText:(NSString *)plaintext publicKey:(NSString *)publicHex;

/// SM2 解密。返回 NSData 格式明文，解密失败返回 nil
/// @param asn1Data NSData 格式密文（ASN1 编码，若非 ASN1 编码，需要先使用 asn1EncodeWithC1C3C2Data 进行编码）
/// @param privateHex 私钥（ HEX 编码格式）
+ (nullable NSData *)decryptData:(NSData *)asn1Data privateKey:(NSString *)privateHex;

/// SM2 解密。返回字符串格式明文，解密失败返回 nil
/// @param asn1Hex ASN1 编码密文（ASN1 编码，若非 ASN1 编码，需要先使用 asn1EncodeWithC1C3C2Hex 进行编码）
/// @param privateHex 私钥（ HEX 编码格式）
+ (nullable NSString *)decryptHex:(NSString *)asn1Hex privateKey:(NSString *)privateHex;

// MARK: - ASN1 编码解码
/// ASN1  编码。返回 ASN1 编码的密文
/// @param c1c3c2Data 按照 C1C3C2 排序的 NSData 密文数据，若非此顺序需要先转换
/// @param hasPrefix 标记密文 c1c3c2Data 前面是否有前缀标识，例如 0x04 前缀标识，默认 NO
+ (nullable NSData *)asn1EncodeWithC1C3C2Data:(NSData *)c1c3c2Data hasPrefix:(BOOL)hasPrefix;

/// ASN1  编码。返回 ASN1 编码的密文（ HEX 编码格式）
/// @param c1c3c2Hex 按照 C1C3C2 排序的 16 进制编码密文数据，若非此顺序需要先转换
/// @param hasPrefix 标记密文 c1c3c2Hex 前面是否有前缀标识，例如 04 前缀标识，默认 NO
+ (nullable NSString *)asn1EncodeWithC1C3C2Hex:(NSString *)c1c3c2Hex hasPrefix:(BOOL)hasPrefix;

/// ASN1  解码。返回按照 C1C3C2 排序的密文，hasPrefix=YES时，返回结果前面会拼接上 0x04 前缀标识
/// @param asn1Data ASN1 编码的密文
/// @param hasPrefix 返回的密文结果前面是否增加 0x04 前缀标识，YES 时返回结果前面会拼接上 0x04，默认 NO
+ (nullable NSData *)asn1DecodeToC1C3C2Data:(NSData *)asn1Data hasPrefix:(BOOL)hasPrefix;

/// ASN1  解码。返回按照 C1C3C2 排序的密文(HEX 编码格式)，hasPrefix=YES时，返回结果前面会拼接上 04 前缀标识
/// @param asn1Hex ASN1 编码的密文 (HEX 编码格式)
/// @param hasPrefix 返回的密文结果前面是否增加 04 前缀标识，YES 时返回结果前面会拼接上 04，默认 NO
+ (nullable NSString *)asn1DecodeToC1C3C2Hex:(NSString *)asn1Hex hasPrefix:(BOOL)hasPrefix;

// MARK: - 密文顺序转换
/// 将密文顺序由 C1C2C3 转为 C1C3C2，返回 C1C3C2 顺序排列的密文，失败返回 nil
/// @param c1c2c3Data 按照 C1C2C3 顺序排列的密文
/// @param hasPrefix 标记c1c2c3Data是否包含压缩标识，默认 NO 没有标识，e.g. Java 端 BouncyCastle 库密文可能会带 04 前缀标识
+ (nullable NSData *)convertC1C2C3DataToC1C3C2:(NSData *)c1c2c3Data hasPrefix:(BOOL)hasPrefix;

/// 将密文顺序由 C1C2C3 转为 C1C3C2，返回 C1C3C2 顺序排列的密文，失败返回 nil
/// @param c1c2c3Hex 按照 C1C2C3 顺序排列的密文
/// @param hasPrefix 标记c1c2c3Hex是否包含压缩标识，默认 NO 没有标识，e.g. Java 端 BouncyCastle 库密文可能会带 04 前缀标识
+ (nullable NSString *)convertC1C2C3HexToC1C3C2:(NSString *)c1c2c3Hex hasPrefix:(BOOL)hasPrefix;

/// C1C3C2 顺序的密文转为 C1C2C3 顺序，返回 C1C2C3 顺序排列的密文，失败返回 nil
/// @param c1c3c2Data 按照 C1C3C2 顺序排列的 NSData 格式密文
/// @param hasPrefix 标记c1c3c2Data是否包含压缩标识，默认 NO 没有标识，e.g. Java 端 BouncyCastle 库密文可能会带 04 前缀标识
+ (nullable NSData *)convertC1C3C2DataToC1C2C3:(NSData *)c1c3c2Data hasPrefix:(BOOL)hasPrefix;

/// C1C3C2 顺序的密文转为 C1C2C3 顺序，返回 C1C2C3 顺序排列的密文，失败返回 nil
/// @param c1c3c2Hex 按照 C1C3C2 顺序排列的 16 进制格式密文
/// @param hasPrefix 标记c1c3c2Hex是否包含压缩标识，默认 NO 没有标识，e.g. Java 端 BouncyCastle 库密文可能会带 04 前缀标识
+ (nullable NSString *)convertC1C3C2HexToC1C2C3:(NSString *)c1c3c2Hex hasPrefix:(BOOL)hasPrefix;

// MARK: - 签名验签
/// SM2 数字签名。返回值：数字签名，RS 拼接的 HEX 编码格式字符串，前半部分是 R，后半部分是 S
/// @param plainData 明文（NSData 格式）
/// @param privateHex SM2 私钥（HEX 编码格式）
/// @param userData 用户 ID（NSData 格式），当为 nil 时默认为 "1234567812345678" 的 NSData 格式
+ (nullable NSString *)signData:(NSData *)plainData privateKey:(NSString *)privateHex userData:(nullable NSData *)userData;

/// SM2 数字签名。返回值：数字签名，RS 拼接的 HEX 编码格式字符串，前半部分是 R，后半部分是 S
/// @param plaintext 明文（字符串格式）
/// @param privateHex SM2 私钥（HEX 编码格式）
/// @param userText 用户 ID（字符串格式），当为 nil 时默认为 "1234567812345678"
+ (nullable NSString *)signText:(NSString *)plaintext privateKey:(NSString *)privateHex userText:(nullable NSString *)userText;

/// SM2 验证数字签名。返回值：验签结果，YES 为通过，NO 为不通过
/// @param plainData 明文（NSData 格式）
/// @param signRS 数字签名，RS 拼接的 HEX 编码格式字符串，前半部分是 R，后半部分是 S
/// @param publicHex SM2 公钥（HEX 编码格式）
/// @param userData 用户 ID（NSData 格式，任意值），当为 nil 时默认为 "1234567812345678" 的 NSData 格式
+ (BOOL)verifyData:(NSData *)plainData signRS:(NSString *)signRS publicKey:(NSString *)publicHex userData:(nullable NSData *)userData;

/// SM2 验证数字签名。返回值：验签结果，YES 为通过，NO 为不通过
/// @param plaintext 明文（字符串格式）
/// @param signRS 数字签名，RS 拼接的 HEX 编码格式字符串，前半部分是 R，后半部分是 S
/// @param publicHex SM2 公钥（HEX 编码格式）
/// @param userText 用户 ID（字符串格式），当为 nil 时默认为 "1234567812345678"
+ (BOOL)verifyText:(NSString *)plaintext signRS:(NSString *)signRS publicKey:(NSString *)publicHex userText:(nullable NSString *)userText;

// MARK: - SM2 签名 Der 编码解码
/// Der 编码。返回值：SM2 数字签名， Der 编码格式
/// @param signRS RS 拼接的 HEX 编码格式字符串，前半部分是 R，后半部分是 S
+ (nullable NSString *)encodeDerWithSignRS:(NSString *)signRS;

/// Der 解码。SM2 数字签名 Der 解码，返回值：数字签名，RS 拼接的HEX 编码格式字符串，前半部分是 R，后半部分是 S
/// @param derSign Der 编码格式的数字签名，通常以 30 开头
+ (nullable NSString *)decodeDerToSignRS:(NSString *)derSign;

// MARK: - SM2 公钥的压缩与解压缩
/// SM2 公钥压缩。返回值：02 或 03 开头的压缩公钥
/// @param publicHex 04 开头的非压缩公钥
+ (nullable NSString *)compressPublicKey:(NSString *)publicHex;

/// SM2 公钥解压缩。返回值：04 开头的非压缩公钥
/// @param publicHex 02 或 03 开头的压缩公钥
+ (nullable NSString *)decompressPublicKey:(NSString *)publicHex;

// MARK: - SM2 私钥计算公钥
/// SM2 私钥计算公钥。返回值：04 开头的非压缩公钥
/// @param privateHex  私钥（ HEX 编码格式）
+ (nullable NSString *)calcPublicKeyFromPrivateKey:(NSString *)privateHex;

// MARK: - ECDH 密钥协商
/// 椭圆曲线 Diffie-Hellman 密钥协商（ECDH），返回 64 字节 HEX 编码格式密钥
/// @param publicHex 对方公钥（ HEX 编码格式）
/// @param privateHex 己方私钥（ HEX 编码格式）
+ (nullable NSString *)computeECDH:(NSString *)publicHex privateKey:(NSString *)privateHex;

// MARK: - 椭圆曲线类型
/// 常见椭圆曲线为 NID_sm2、NID_secp256k1、NID_X9_62_prime256v1
/// 默认 NID_sm2，参考文件头注释中说明，一般不需更改
/// 若需要更改，传入枚举 GMCurveType 枚举值即可
/// 若需要其他曲线，在 OpenSSL 源码 crypto/ec/ec_curve.c 查找
+ (int)curveType;
+ (void)setCurveType:(int)type;

@end

NS_ASSUME_NONNULL_END
