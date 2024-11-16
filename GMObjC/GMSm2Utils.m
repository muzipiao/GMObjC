#import "GMSm2Utils.h"
#import "GMSmUtils.h"
#import <openssl/sm2.h>
#import <openssl/bn.h>
#import <openssl/evp.h>
#import <openssl/asn1t.h>

//SM2 加密后密文为 ASN1 编码，此处定义 ASN1 编解码存储数据的结构体
#ifndef GMSM2_CIPHERTEXT_ST_1
#define GMSM2_CIPHERTEXT_ST_1

typedef struct SM2_Ciphertext_st_1 SM2_Ciphertext_1;
DECLARE_ASN1_FUNCTIONS(SM2_Ciphertext_1)

struct SM2_Ciphertext_st_1 {
    BIGNUM *C1x;
    BIGNUM *C1y;
    ASN1_OCTET_STRING *C3;
    ASN1_OCTET_STRING *C2;
};

ASN1_SEQUENCE(SM2_Ciphertext_1) = {
    ASN1_SIMPLE(SM2_Ciphertext_1, C1x, BIGNUM),
    ASN1_SIMPLE(SM2_Ciphertext_1, C1y, BIGNUM),
    ASN1_SIMPLE(SM2_Ciphertext_1, C3, ASN1_OCTET_STRING),
    ASN1_SIMPLE(SM2_Ciphertext_1, C2, ASN1_OCTET_STRING),
} ASN1_SEQUENCE_END(SM2_Ciphertext_1)

IMPLEMENT_ASN1_FUNCTIONS(SM2_Ciphertext_1)

#endif /* GMSM2_CIPHERTEXT_ST_1 */

@implementation GMSm2Key
// SM2 公私钥对，结果为 HEX 编码格式
- (NSString *)description {
    return [NSString stringWithFormat:@"%@,%@", self.publicKey, self.privateKey];
}
@end

// MARK: - GMSm2Utils
@interface GMSm2Utils ()
// SM2 椭圆曲线类型，默认 NID_sm2，无特殊情况无需更改
@property (nonatomic, assign) int curveType;
@end

@implementation GMSm2Utils

static GMSm2Utils *_instance;
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[GMSm2Utils alloc] init];
        _instance.curveType = NID_sm2;
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _instance;
}

// OpenSSL 1.1.1 以上版本支持国密
+ (void)initialize {
    if (self == [GMSm2Utils class]) {
        if (OPENSSL_VERSION_NUMBER < 0x1010100fL) {
            NSAssert1(NO, @"OpenSSL 版本低于 1.1.1，不支持国密，OpenSSL 当前版本：%s", OPENSSL_VERSION_TEXT);
        }
    }
}

// MARK: - 椭圆曲线类型
- (int)curveType {
    if (_curveType == 0) {
        return NID_sm2;
    }
    return _curveType;
}

/// 常见椭圆曲线为 NID_sm2、NID_secp256k1、NID_X9_62_prime256v1
/// 默认 NID_sm2，参考文件头注释中说明，一般不需更改
/// 若需要更改，传入枚举 GMCurveType 枚举值即可
/// 若需要其他曲线，在 OpenSSL 源码 crypto/ec/ec_curve.c 查找
+ (int)curveType {
    return [GMSm2Utils shared].curveType;
}

+ (void)setCurveType:(int)type {
    switch (type) {
        case GMSm2CurveSm2p256v1:
            [GMSm2Utils shared].curveType = NID_sm2;
            break;
        case GMSm2CurveSecp256k1:
            [GMSm2Utils shared].curveType = NID_secp256k1;
            break;
        case GMSm2CurveSecp256r1:
            [GMSm2Utils shared].curveType = NID_X9_62_prime256v1;
            break;
        default:
            [GMSm2Utils shared].curveType = type;
            break;
    }
}

// MARK: - 创建公私钥对
+ (GMSm2Key *)generateKey {
    GMSm2Key *keyObj = [[GMSm2Key alloc] init];
    EC_GROUP *group = EC_GROUP_new_by_curve_name([self curveType]); // 椭圆曲线
    EC_KEY *key = NULL; // 密钥对
    do {
        key = EC_KEY_new();
        if (!EC_KEY_set_group(key, group)) {
            break;
        }
        if (!EC_KEY_generate_key(key)) {
            break;
        }
        const EC_POINT *pub_key = EC_KEY_get0_public_key(key);
        const BIGNUM *pri_key = EC_KEY_get0_private_key(key);
        
        char *hex_pub = EC_POINT_point2hex(group, pub_key, EC_KEY_get_conv_form(key), NULL);
        char *hex_pri = BN_bn2hex(pri_key);
        
        keyObj.publicKey = [NSString stringWithCString:hex_pub encoding:NSUTF8StringEncoding];
        keyObj.privateKey = [NSString stringWithCString:hex_pri encoding:NSUTF8StringEncoding];
        // 根据椭圆曲线的类型，依据椭圆曲线上的点获取私钥长度，不足前面补0
        size_t maxLen = ((EC_GROUP_get_degree(group) + 7) / 8) * 2;
        NSString *privateKey = [NSString stringWithCString:hex_pri encoding:NSUTF8StringEncoding];
        keyObj.privateKey = [GMSmUtils prefixPaddingZero:privateKey maxLen:maxLen];
        
        OPENSSL_free(hex_pub);
        OPENSSL_free(hex_pri);
    } while (NO);
    // Free
    if (group) { EC_GROUP_free(group); }
    if (key) { EC_KEY_free(key); }
    
    return keyObj;
}

// MARK: - SM2 加密
+ (nullable NSData *)enData:(NSData *)plainData hexPubKey:(NSString *)hexPubKey {
    uint8_t *plain_bytes = (uint8_t *)[plainData bytes]; // 明文
    const char *public_key = hexPubKey.UTF8String; // 公钥
    size_t msg_len = plainData.length; // 明文长度
    
    const EVP_MD *digest = EVP_sm3(); // 摘要算法
    EC_GROUP *group = EC_GROUP_new_by_curve_name([self curveType]); // 椭圆曲线
    EC_KEY *key = NULL; // 密钥对
    EC_POINT *pub_point = NULL; // 坐标
    uint8_t *ciphertext = NULL; // 密文
    NSData *cipherData = nil; // 密文
    do {
        key = EC_KEY_new();
        if (!EC_KEY_set_group(key, group)) {
            break;
        }
        pub_point = EC_POINT_new(group);
        EC_POINT_hex2point(group, public_key, pub_point, NULL);
        if (!EC_KEY_set_public_key(key, pub_point)) {
            break;
        }
        size_t ciphertext_len = 0;
        if (!sm2_ciphertext_size(key, digest, msg_len, &ciphertext_len)) {
            break;
        }
        ciphertext = (uint8_t *)OPENSSL_zalloc(ciphertext_len);
        if (!sm2_encrypt(key, digest, plain_bytes, msg_len, ciphertext, &ciphertext_len)) {
            break;
        }
        cipherData = [NSData dataWithBytes:ciphertext length:ciphertext_len];
    } while (NO);
    // Free
    if (group) { EC_GROUP_free(group); }
    if (pub_point) { EC_POINT_free(pub_point); }
    if (key) { EC_KEY_free(key); }
    if (ciphertext) { OPENSSL_free(ciphertext); }
    
    return cipherData;
}

/// SM2 加密。返回 ASN1 编码密文（ASN1 编码可使用 asn1DecodeToC1C3C2Data 解码为非 ASN1 编码），失败返回 nil
/// @param plainData 明文（NSData 格式）
/// @param publicHex 04 开头的公钥（ HEX 编码格式）
+ (nullable NSData *)encryptData:(NSData *)plainData publicKey:(NSString *)publicHex {
    if (plainData.length == 0 || publicHex.length == 0) {
        return nil;
    }
    NSData *cipherData = [self enData:plainData hexPubKey:publicHex];
    return cipherData;
}

/// SM2 加密。返回 ASN1 编码 HEX 格式密文（ASN1 编码可使用 asn1DecodeToC1C3C2Hex 解码为非 ASN1 编码），失败返回 nil
/// @param plaintext 明文（NSString 原文格式）
/// @param publicHex 04 开头的公钥（ HEX 编码格式）
+ (nullable NSString *)encryptText:(NSString *)plaintext publicKey:(NSString *)publicHex {
    if (plaintext.length == 0 || publicHex.length == 0) {
        return nil;
    }
    NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherData = [self encryptData:plainData publicKey:publicHex];
    NSString *ciphertext = [GMSmUtils hexStringFromData:cipherData];
    return ciphertext;
}

// MARK: - SM2 解密
+ (nullable NSData *)deData:(NSData *)cipherData hexPriKey:(NSString *)privateHex {
    uint8_t *cipher_bytes = (uint8_t *)[cipherData bytes]; // 明文
    const char *private_key = privateHex.UTF8String; // 私钥
    size_t ctext_len = cipherData.length;
    
    const EVP_MD *digest = EVP_sm3(); // 摘要算法
    EC_GROUP *group = EC_GROUP_new_by_curve_name([self curveType]); // 椭圆曲线
    BIGNUM *pri_big_num = NULL; // 私钥
    EC_KEY *key = NULL; // 密钥对
    EC_POINT *pub_point = NULL; // 坐标
    uint8_t *plaintext = NULL; // 明文
    NSData *plainData = nil; // 明文
    
    do {
        if (!BN_hex2bn(&pri_big_num, private_key)) {
            break;
        }
        key = EC_KEY_new();
        if (!EC_KEY_set_group(key, group)) {
            break;
        }
        if (!EC_KEY_set_private_key(key, pri_big_num)) {
            break;
        }
        size_t ptext_len = 0;
        if (!sm2_plaintext_size(cipher_bytes, ctext_len, &ptext_len)) {
            break;
        }
        plaintext = (uint8_t *)OPENSSL_zalloc(ptext_len);
        if (!sm2_decrypt(key, digest, cipher_bytes, ctext_len, plaintext, &ptext_len)) {
            break;
        }
        plainData = [NSData dataWithBytes:plaintext length:ptext_len];
    } while (NO);
    // Free
    if (group) { EC_GROUP_free(group); }
    if (pub_point) { EC_POINT_free(pub_point); }
    if (pri_big_num) { BN_free(pri_big_num); }
    if (key) { EC_KEY_free(key); }
    if (plaintext) { OPENSSL_free(plaintext); }
    
    return plainData;
}

/// SM2 解密。返回 NSData 格式明文，解密失败返回 nil
/// @param asn1Data NSData 格式密文（ASN1 编码，若非 ASN1 编码，需要先使用 asn1EncodeWithC1C3C2Data 进行编码）
/// @param privateHex 私钥（ HEX 编码格式）
+ (nullable NSData *)decryptData:(NSData *)asn1Data privateKey:(NSString *)privateHex {
    if (!asn1Data || asn1Data.length == 0 || !privateHex || privateHex.length == 0) {
        return nil;
    }
    NSData *plainData = [self deData:asn1Data hexPriKey:privateHex];
    return plainData;
}

/// SM2 解密。返回字符串格式明文，解密失败返回 nil
/// @param asn1Hex ASN1 编码 HEX 格式密文（ASN1 编码，若非 ASN1 编码，需要先使用 asn1EncodeWithC1C3C2Hex 进行编码）
/// @param privateHex 私钥（ HEX 编码格式）
+ (nullable NSString *)decryptHex:(NSString *)asn1Hex privateKey:(NSString *)privateHex {
    NSData *cipherData = [GMSmUtils dataFromHexString:asn1Hex];
    NSData *plainData = [self decryptData:cipherData privateKey:privateHex];
    if (plainData.length > 0) {
        NSString *plaintext = [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
        return plaintext;
    }
    return nil;
}

// MARK: - 密文格式转换
/// 将密文顺序由 C1C2C3 转为 C1C3C2，返回 C1C3C2 顺序排列的密文，失败返回 nil
/// @param c1c2c3Data 按照 C1C2C3 顺序排列的密文
/// @param hasPrefix 标记c1c2c3Data是否包含压缩标识，默认 NO 没有标识，e.g. Java 端 BouncyCastle 库密文可能会带 04 前缀标识
+ (nullable NSData *)convertC1C2C3DataToC1C3C2:(NSData *)c1c2c3Data hasPrefix:(BOOL)hasPrefix {
    if (c1c2c3Data.length < 32) {
        return nil;
    }
    NSData *prefixData = [NSData data];
    NSData *cipherData = c1c2c3Data;
    if (hasPrefix == YES && cipherData.length > 1) {
        prefixData = [cipherData subdataWithRange:NSMakeRange(0, 1)];
        cipherData = [cipherData subdataWithRange:NSMakeRange(1, cipherData.length - 1)];
    }
    // 根据椭圆曲线的类型，计算椭圆曲线上的点的长度，获取C1长度
    EC_GROUP *group = EC_GROUP_new_by_curve_name([self curveType]);
    size_t c1Len = ((EC_GROUP_get_degree(group) + 7) / 8) * 2;
    size_t c3Len = 32;
    size_t c2Len = cipherData.length - c1Len - c3Len;
    if (group) {
        EC_GROUP_free(group);
    }
    if (c1Len < 1 || c2Len < 1 || cipherData.length <= c1Len + c3Len) {
        return nil;
    }
    NSData *c1Data = [cipherData subdataWithRange:NSMakeRange(0, c1Len)];
    NSData *c3Data = [cipherData subdataWithRange:NSMakeRange(cipherData.length - c3Len, c3Len)];
    NSData *c2Data = [cipherData subdataWithRange:NSMakeRange(c1Len, c2Len)];
    NSMutableData *c1c3c2Data = [NSMutableData dataWithData:prefixData];
    [c1c3c2Data appendData:c1Data];
    [c1c3c2Data appendData:c3Data];
    [c1c3c2Data appendData:c2Data];
    return c1c3c2Data;
}

/// 将密文顺序由 C1C2C3 转为 C1C3C2，返回 C1C3C2 顺序排列的密文，失败返回 nil
/// @param c1c2c3Hex 按照 C1C2C3 顺序排列的密文
/// @param hasPrefix 标记c1c2c3Hex是否包含压缩标识，默认 NO 没有标识，e.g. Java 端 BouncyCastle 库密文可能会带 04 前缀标识
+ (nullable NSString *)convertC1C2C3HexToC1C3C2:(NSString *)c1c2c3Hex hasPrefix:(BOOL)hasPrefix {
    NSData *c1c2c3Data = [GMSmUtils dataFromHexString:c1c2c3Hex];
    NSData *c1c3c2Data = [self convertC1C2C3DataToC1C3C2:c1c2c3Data hasPrefix:hasPrefix];
    NSString *c1c3c2Hex = [GMSmUtils hexStringFromData:c1c3c2Data];
    return c1c3c2Hex;
}

/// C1C3C2 顺序的密文转为 C1C2C3 顺序，返回 C1C2C3 顺序排列的密文，失败返回 nil
/// @param c1c3c2Data 按照 C1C3C2 顺序排列的 NSData 格式密文
/// @param hasPrefix 标记c1c3c2Data是否包含压缩标识，默认 NO 没有标识，e.g. Java 端 BouncyCastle 库密文可能会带 04 前缀标识
+ (nullable NSData *)convertC1C3C2DataToC1C2C3:(NSData *)c1c3c2Data hasPrefix:(BOOL)hasPrefix {
    if (c1c3c2Data.length < 32) {
        return nil;
    }
    NSData *prefixData = [NSData data];
    NSData *cipherData = c1c3c2Data;
    if (hasPrefix == YES && cipherData.length > 1) {
        prefixData = [cipherData subdataWithRange:NSMakeRange(0, 1)];
        cipherData = [cipherData subdataWithRange:NSMakeRange(1, cipherData.length - 1)];
    }
    // 根据椭圆曲线的类型，计算椭圆曲线上的点的长度，获取C1长度
    EC_GROUP *group = EC_GROUP_new_by_curve_name([self curveType]);
    size_t c1Len = ((EC_GROUP_get_degree(group) + 7) / 8) * 2;
    size_t c3Len = 32;
    size_t c2Len = cipherData.length - c1Len - c3Len;
    if (group) {
        EC_GROUP_free(group);
    }
    if (c1Len < 1 || c2Len < 1 || cipherData.length <= c1Len + c3Len) {
        return nil;
    }
    NSData *c1Data = [cipherData subdataWithRange:NSMakeRange(0, c1Len)];
    NSData *c3Data = [cipherData subdataWithRange:NSMakeRange(c1Len, c3Len)];
    NSData *c2Data = [cipherData subdataWithRange:NSMakeRange(c1Len + c3Len, c2Len)];
    NSMutableData *c1c2c3Data = [NSMutableData dataWithData:prefixData];
    [c1c2c3Data appendData:c1Data];
    [c1c2c3Data appendData:c2Data];
    [c1c2c3Data appendData:c3Data];
    return c1c2c3Data;
}

/// C1C3C2 顺序的密文转为 C1C2C3 顺序，返回 C1C2C3 顺序排列的密文，失败返回 nil
/// @param c1c3c2Hex 按照 C1C3C2 顺序排列的 16 进制格式密文
/// @param hasPrefix 标记c1c3c2Hex是否包含压缩标识，默认 NO 没有标识，e.g. Java 端 BouncyCastle 库密文可能会带 04 前缀标识
+ (nullable NSString *)convertC1C3C2HexToC1C2C3:(NSString *)c1c3c2Hex hasPrefix:(BOOL)hasPrefix {
    NSData *c1c3c2Data = [GMSmUtils dataFromHexString:c1c3c2Hex];
    NSData *c1c2c3Data = [self convertC1C3C2DataToC1C2C3:c1c3c2Data hasPrefix:hasPrefix];
    NSString *c1c2c3Hex = [GMSmUtils hexStringFromData:c1c2c3Data];
    return c1c2c3Hex;
}

// MARK: - ASN1 编码
+ (NSData *)asn1EncodeC1Data:(NSData *)c1 c3Data:(NSData *)c3 c2Data:(NSData *)c2 {
    if (c1.length == 0 || c3.length == 0 || c2.length == 0) {
        return nil;
    }
    NSUInteger c1_len = c1.length;
    NSData *c1XData = [c1 subdataWithRange:NSMakeRange(0, c1_len/2)];
    NSData *c1YData = [c1 subdataWithRange:NSMakeRange(c1_len/2, c1_len/2)];
    const char *c1_x_hex = [GMSmUtils hexStringFromData:c1XData].UTF8String;
    const char *c1_y_hex = [GMSmUtils hexStringFromData:c1YData].UTF8String;
    uint8_t *c3_text = (uint8_t *)[c3 bytes];
    size_t c3_len = c3.length;
    uint8_t *c2_text = (uint8_t *)[c2 bytes];
    size_t c2_len = c2.length;
    
    // ASN1 编码后存储数据的结构体
    struct SM2_Ciphertext_st_1 ctext_st;
    ctext_st.C2 = NULL;
    ctext_st.C3 = NULL;
    BIGNUM *x1 = NULL;
    BIGNUM *y1 = NULL;
    NSData *asn1Data = nil;
    do {
        if (!BN_hex2bn(&x1, c1_x_hex)) {
            break;
        }
        if (!BN_hex2bn(&y1, c1_y_hex)) {
            break;
        }
        ctext_st.C1x = x1;
        ctext_st.C1y = y1;
        ctext_st.C3 = ASN1_OCTET_STRING_new();
        ctext_st.C2 = ASN1_OCTET_STRING_new();
        if (ctext_st.C3 == NULL || ctext_st.C2 == NULL) {
            break;
        }
        if (!ASN1_OCTET_STRING_set(ctext_st.C3, (uint8_t *)c3_text, (int)c3_len)
            || !ASN1_OCTET_STRING_set(ctext_st.C2, (uint8_t *)c2_text, (int)c2_len)) {
            break;
        }
        uint8_t *asn1_buf = NULL; // 编码
        int asn1_len = i2d_SM2_Ciphertext_1(&ctext_st, &asn1_buf);
        /* Ensure cast to size_t is safe */
        if (asn1_len < 0 || !asn1_buf) {
            break;
        }
        asn1Data = [NSData dataWithBytes:asn1_buf length:asn1_len];
        free(asn1_buf); // 释放 buf
    } while (NO);
    // Free
    if (ctext_st.C2) { ASN1_OCTET_STRING_free(ctext_st.C2); }
    if (ctext_st.C3) { ASN1_OCTET_STRING_free(ctext_st.C3); }
    if (x1) { BN_free(x1); }
    if (y1) { BN_free(y1); }
    
    return asn1Data;
}

/// ASN1  编码。返回 ASN1 编码的密文
/// @param c1c3c2Data 按照 C1C3C2 排序的 NSData 密文数据，若非此顺序需要先转换
/// @param hasPrefix 标记密文 c1c3c2Data 前面是否有前缀标识，例如 0x04 前缀标识，默认 NO
+ (nullable NSData *)asn1EncodeWithC1C3C2Data:(NSData *)c1c3c2Data hasPrefix:(BOOL)hasPrefix {
    if (c1c3c2Data.length <= 32) {
        return nil;
    }
    NSData *cipherData = c1c3c2Data;
    if (hasPrefix) {
        cipherData = [c1c3c2Data subdataWithRange:NSMakeRange(1, c1c3c2Data.length - 1)];
    }
    // 根据椭圆曲线的类型，依据椭圆曲线上的点获取C1长度
    EC_GROUP *group = EC_GROUP_new_by_curve_name([self curveType]);
    size_t c1Len = ((EC_GROUP_get_degree(group) + 7) / 8) * 2;
    size_t c3Len = 32;
    size_t c2Len = cipherData.length - c1Len - c3Len;
    if (group) {
        EC_GROUP_free(group);
    }
    if (c1Len < 1 || c2Len < 1 || cipherData.length <= c1Len + c3Len) {
        return nil;
    }
    NSData *c1Data = [cipherData subdataWithRange:NSMakeRange(0, c1Len)];
    NSData *c3Data = [cipherData subdataWithRange:NSMakeRange(c1Len, c3Len)];
    NSData *c2Data = [cipherData subdataWithRange:NSMakeRange(c1Len + c3Len, c2Len)];
    NSData *asn1Data = [self asn1EncodeC1Data:c1Data c3Data:c3Data c2Data:c2Data];
    return asn1Data;
}

/// ASN1  编码。返回 ASN1 编码的密文（ HEX 编码格式）
/// @param c1c3c2Hex 按照 C1C3C2 排序的 16 进制编码密文数据，若非此顺序需要先转换
/// @param hasPrefix 标记密文 c1c3c2Hex 前面是否有前缀标识，例如 04 前缀标识，默认 NO
+ (nullable NSString *)asn1EncodeWithC1C3C2Hex:(NSString *)c1c3c2Hex hasPrefix:(BOOL)hasPrefix {
    NSData *c1c3c2Data = [GMSmUtils dataFromHexString:c1c3c2Hex];
    NSData *asn1Data = [self asn1EncodeWithC1C3C2Data:c1c3c2Data hasPrefix:hasPrefix];
    NSString *asn1Hex = [GMSmUtils hexStringFromData:asn1Data];
    return asn1Hex;
}

// MARK: - ASN1 解码
+ (NSArray<NSData *> *)asn1DecodeToC1C3C2DataList:(NSData *)asn1Data {
    long asn1_ctext_len = asn1Data.length; // ASN1格式密文原文长度
    const uint8_t *asn1_ctext = (uint8_t *)[asn1Data bytes];
    
    const EVP_MD *digest = EVP_sm3(); // 摘要算法
    struct SM2_Ciphertext_st_1 *sm2_st = NULL;
    sm2_st = d2i_SM2_Ciphertext_1(NULL, &asn1_ctext, asn1_ctext_len);
    if (sm2_st == NULL) {
        return @[];
    }
    // C1
    char *c1x_text = BN_bn2hex(sm2_st->C1x);
    char *c1y_text = BN_bn2hex(sm2_st->C1y);
    NSString *c1xStr = [NSString stringWithCString:c1x_text encoding:NSUTF8StringEncoding];
    NSString *c1yStr = [NSString stringWithCString:c1y_text encoding:NSUTF8StringEncoding];
    // 根据椭圆曲线的类型，依据椭圆曲线上的点获取C1长度
    EC_GROUP *group = EC_GROUP_new_by_curve_name([self curveType]);
    size_t maxLen = ((EC_GROUP_get_degree(group) + 7) / 8) * 2;
    NSString *paddingC1X = [GMSmUtils prefixPaddingZero:c1xStr maxLen:maxLen];
    NSString *paddingC1Y = [GMSmUtils prefixPaddingZero:c1yStr maxLen:maxLen];
    NSString *c1Hex = [NSString stringWithFormat:@"%@%@", paddingC1X, paddingC1Y];
    NSData *c1Data = [GMSmUtils dataFromHexString:c1Hex];
    // C3
    const int c3_len = EVP_MD_size(digest);
    NSData *c3Data = [NSData dataWithBytes:sm2_st->C3->data length:c3_len];
    // C2
    int c2_len = sm2_st->C2->length;
    NSData *c2Data = [NSData dataWithBytes:sm2_st->C2->data length:c2_len];
    // Free
    if (c1x_text) { OPENSSL_free(c1x_text); }
    if (c1y_text) { OPENSSL_free(c1y_text); }
    if (sm2_st) { SM2_Ciphertext_1_free(sm2_st); }
    if (!c1Data || !c3Data || !c2Data) { return @[]; }
    
    return @[c1Data, c3Data, c2Data];
}

/// ASN1  解码。返回按照 C1C3C2 排序的密文，hasPrefix=YES时，返回结果前面会拼接上 0x04 前缀标识
/// @param asn1Data ASN1 编码的密文
/// @param hasPrefix 返回的密文结果前面是否增加 0x04 前缀标识，YES 时返回结果前面会拼接上 0x04，默认 NO
+ (nullable NSData *)asn1DecodeToC1C3C2Data:(NSData *)asn1Data hasPrefix:(BOOL)hasPrefix {
    if (asn1Data.length == 0) {
        return nil;
    }
    NSArray<NSData *> *c1c3c2Array = [self asn1DecodeToC1C3C2DataList:asn1Data];
    if (c1c3c2Array.count != 3) {
        return nil;
    }
    NSData *prefixData = [NSData data];
    if (hasPrefix) {
        prefixData = [GMSmUtils dataFromHexString:@"04"];
    }
    NSMutableData *c1c3c2Data = [NSMutableData dataWithData:prefixData];
    [c1c3c2Data appendData:c1c3c2Array[0]];
    [c1c3c2Data appendData:c1c3c2Array[1]];
    [c1c3c2Data appendData:c1c3c2Array[2]];
    
    return c1c3c2Data;
}

/// ASN1  解码。返回按照 C1C3C2 排序的密文(16 进制编码格式)，hasPrefix=YES时，返回结果前面会拼接上 04 前缀标识
/// @param asn1Hex ASN1 编码的密文 (HEX 编码格式)
/// @param hasPrefix 返回的密文结果前面是否增加 04 前缀标识，YES 时返回结果前面会拼接上 04，默认 NO
+ (nullable NSString *)asn1DecodeToC1C3C2Hex:(NSString *)asn1Hex hasPrefix:(BOOL)hasPrefix {
    NSData *asn1Data = [GMSmUtils dataFromHexString:asn1Hex];
    NSData *c1c3c2Data = [self asn1DecodeToC1C3C2Data:asn1Data hasPrefix:hasPrefix];
    NSString *c1c3c2Hex = [GMSmUtils hexStringFromData:c1c3c2Data];
    return c1c3c2Hex;
}

// MARK: - SM2 签名
/// SM2 数字签名。返回值：数字签名，RS 拼接的 HEX 格式字符串，前半部分是 R，后半部分是 S
/// @param plaintext 明文（字符串格式）
/// @param privateHex SM2 私钥（HEX 编码格式）
/// @param userText 用户 ID（字符串格式），当为 nil 时默认为 "1234567812345678"
+ (nullable NSString *)signText:(NSString *)plaintext privateKey:(NSString *)privateHex userText:(nullable NSString *)userText {
    if (plaintext.length == 0 || privateHex.length == 0) {
        return nil;
    }
    NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
    NSData *userData = userText.length > 0 ? [userText dataUsingEncoding:NSUTF8StringEncoding] : nil;
    return [self signData:plainData privateKey:privateHex userData:userData];
}

/// SM2 数字签名。返回值：数字签名，RS 拼接的 HEX 格式字符串，前半部分是 R，后半部分是 S
/// @param plainData 明文（NSData 格式）
/// @param privateHex SM2 私钥（HEX 编码格式）
/// @param userData 用户 ID（NSData 格式），当为 nil 时默认为 "1234567812345678" 的 NSData 格式
+ (nullable NSString *)signData:(NSData *)plainData privateKey:(NSString *)privateHex userData:(nullable NSData *)userData {
    if (plainData.length == 0 || privateHex.length == 0) {
        return nil;
    }
    if (userData.length == 0) {
        userData = [NSData dataWithBytes:SM2_DEFAULT_USERID length:strlen(SM2_DEFAULT_USERID)];
    }
    const char *private_key = privateHex.UTF8String;
    uint8_t *plain_bytes = (uint8_t *)[plainData bytes];
    size_t plain_len = plainData.length;
    uint8_t *user_id = (uint8_t *)[userData bytes];
    size_t user_len = userData.length;
    
    ECDSA_SIG *sig = NULL;  // 签名结果
    const BIGNUM *sig_r = NULL;
    const BIGNUM *sig_s = NULL;
    const EVP_MD *digest = EVP_sm3();  // 摘要算法
    EC_GROUP *group = EC_GROUP_new_by_curve_name([self curveType]);
    BIGNUM *pri_num = NULL;  // 私钥
    EC_KEY *key = NULL; // 密钥对
    EC_POINT *pub_point = NULL; // 公钥坐标
    NSString *sigStr = nil;  // 签名结果
    do {
        if (!BN_hex2bn(&pri_num, private_key)) {
            break; // 私钥转 BIGNUM
        }
        key = EC_KEY_new();
        if (!EC_KEY_set_group(key, group)) {
            break;
        }
        if (!EC_KEY_set_private_key(key, pri_num)) {
            break; // 设置私钥
        }
        pub_point = EC_POINT_new(group);
        if (!EC_POINT_mul(group, pub_point, pri_num, NULL, NULL, NULL)) {
            break; // 私钥算出公钥
        }
        if (!EC_KEY_set_public_key(key, pub_point)) {
            break; // 设置公钥
        }
        // 计算签名
        sig = sm2_do_sign(key, digest, user_id, user_len, plain_bytes, plain_len);
        if (!sig) {
            break;
        }
        ECDSA_SIG_get0(sig, &sig_r, &sig_s);
        char *r_hex = BN_bn2hex(sig_r);
        char *s_hex = BN_bn2hex(sig_s);
        NSString *rStr = [NSString stringWithCString:r_hex encoding:NSUTF8StringEncoding];
        NSString *sStr = [NSString stringWithCString:s_hex encoding:NSUTF8StringEncoding];
        
        OPENSSL_free(r_hex);
        OPENSSL_free(s_hex);
        if (rStr.length == 0 || sStr.length == 0) {
            break;
        }
        // 根据椭圆曲线的类型，依据椭圆曲线上的点获取签名长度
        size_t maxLen = ((EC_GROUP_get_degree(group) + 7) / 8) * 2;
        NSString *paddingR = [GMSmUtils prefixPaddingZero:rStr maxLen:maxLen];
        NSString *paddingS = [GMSmUtils prefixPaddingZero:sStr maxLen:maxLen];
        sigStr = [NSString stringWithFormat:@"%@%@", paddingR, paddingS];
    } while (NO);
    // Free
    if (group) { EC_GROUP_free(group); }
    if (pub_point) { EC_POINT_free(pub_point); }
    if (sig) { ECDSA_SIG_free(sig); }
    if (key) { EC_KEY_free(key); }
    if (pri_num) { BN_free(pri_num); }
    
    return sigStr;
}

// MARK: - SM2 验签
/// SM2 验证数字签名。返回值：验签结果，YES 为通过，NO 为不通过
/// @param plaintext 明文（字符串格式）
/// @param signRS 数字签名，RS 拼接的 HEX 格式字符串，前半部分是 R，后半部分是 S
/// @param publicHex SM2 公钥（HEX 编码格式）
/// @param userText 用户 ID（字符串格式），当为 nil 时默认为 "1234567812345678"
+ (BOOL)verifyText:(NSString *)plaintext signRS:(NSString *)signRS publicKey:(NSString *)publicHex userText:(nullable NSString *)userText {
    if (plaintext.length == 0 || signRS.length == 0 || publicHex.length == 0) {
        return NO;
    }
    NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
    NSData *userData = userText.length > 0 ? [userText dataUsingEncoding:NSUTF8StringEncoding] : nil;
    return [self verifyData:plainData signRS:signRS publicKey:publicHex userData:userData];
}

/// SM2 验证数字签名。返回值：验签结果，YES 为通过，NO 为不通过
/// @param plainData 明文（NSData 格式）
/// @param signRS 数字签名，RS 拼接的 HEX 格式字符串，前半部分是 R，后半部分是 S
/// @param publicHex SM2 公钥（HEX 编码格式）
/// @param userData 用户 ID（NSData 格式，任意值），当为 nil 时默认为 "1234567812345678" 的 NSData 格式
+ (BOOL)verifyData:(NSData *)plainData signRS:(NSString *)signRS publicKey:(NSString *)publicHex userData:(nullable NSData *)userData {
    if (plainData.length == 0 || signRS.length == 0 || publicHex.length == 0) {
        return NO;
    }
    if (userData.length == 0) {
        userData = [NSData dataWithBytes:SM2_DEFAULT_USERID length:strlen(SM2_DEFAULT_USERID)];
    }
    const char *pub_key = publicHex.UTF8String;
    uint8_t *plain_bytes = (uint8_t *)[plainData bytes];
    size_t plain_len = plainData.length;
    uint8_t *user_id = (uint8_t *)[userData bytes];
    size_t user_len = userData.length;
    
    NSInteger signLen = signRS.length;
    NSString *r_hex = [signRS substringToIndex:signLen/2];
    NSString *s_hex = [signRS substringFromIndex:signLen/2];
    
    ECDSA_SIG *sig = NULL;  // 签名结果
    BIGNUM *sig_r = NULL;
    BIGNUM *sig_s = NULL;
    const EVP_MD *digest = EVP_sm3();  // 摘要算法
    EC_POINT *pub_point = NULL;  // 公钥坐标
    EC_KEY *key = NULL;  // 密钥key
    EC_GROUP *group = EC_GROUP_new_by_curve_name([self curveType]);
    BOOL isOK = NO;  // 验签结果
    
    do {
        if (!BN_hex2bn(&sig_r, r_hex.UTF8String)) {
            break;
        }
        if (!BN_hex2bn(&sig_s, s_hex.UTF8String)) {
            break;
        }
        sig = ECDSA_SIG_new();
        if (sig == NULL) {
            BN_free(sig_r);
            BN_free(sig_s);
            break;
        }
        if (!ECDSA_SIG_set0(sig, sig_r, sig_s)) {
            break;
        }
        key = EC_KEY_new();
        if (!EC_KEY_set_group(key, group)) {
            break;
        }
        pub_point = EC_POINT_new(group);
        EC_POINT_hex2point(group, pub_key, pub_point, NULL);
        if (!EC_KEY_set_public_key(key, pub_point)) {
            break;
        }
        int ok = sm2_do_verify(key, digest, sig, user_id, user_len, plain_bytes, plain_len);
        isOK = ok > 0 ? YES : NO;
    } while (NO);
    // Free
    if (group) { EC_GROUP_free(group); }
    if (pub_point) { EC_POINT_free(pub_point); }
    if (key) { EC_KEY_free(key); }
    if (sig) { ECDSA_SIG_free(sig); }
    
    return isOK;
}

// MARK: - SM2签名 Der 编码
/// Der 编码。返回值：SM2 数字签名， Der 编码格式
/// @param signRS RS 拼接的 HEX 格式字符串，前半部分是 R，后半部分是 S
+ (nullable NSString *)encodeDerWithSignRS:(NSString *)signRS {
    if (signRS.length == 0) {
        return nil;
    }
    NSInteger signLen = signRS.length;
    NSString *r_hex = [signRS substringToIndex:signLen/2];
    NSString *s_hex = [signRS substringFromIndex:signLen/2];
    
    ECDSA_SIG *sig = NULL;  // 签名结果
    BIGNUM *sig_r = NULL;
    BIGNUM *sig_s = NULL;
    unsigned char *der = NULL;
    NSString *derEncode = nil;
    do {
        if (!BN_hex2bn(&sig_r, r_hex.UTF8String)) {
            break;
        }
        if (!BN_hex2bn(&sig_s, s_hex.UTF8String)) {
            break;
        }
        sig = ECDSA_SIG_new();
        if (sig == NULL) {
            break;
        }
        if (!ECDSA_SIG_set0(sig, sig_r, sig_s)) {
            break;
        }
        int der_len = i2d_ECDSA_SIG(sig, &der);
        if (der_len < 0) {
            break;
        }
        NSData *derData = [NSData dataWithBytes:der length:der_len];
        derEncode = [GMSmUtils hexStringFromData:derData];
    } while (NO);
    // Free，注意 ECDSA_SIG_free 会释放 sig_r & sig_s
    if (sig == NULL && sig_r) { BN_free(sig_r); }
    if (sig == NULL && sig_s) { BN_free(sig_s); }
    if (sig) { ECDSA_SIG_free(sig); }
    if (der) { OPENSSL_free(der); }
    
    return derEncode;
}

// MARK: - SM2签名 Der 解码
/// Der 解码。SM2 数字签名 Der 解码，返回值：数字签名，RS 拼接的HEX 格式字符串，前半部分是 R，后半部分是 S
/// @param derSign Der 编码格式的数字签名，通常以 30 开头
+ (nullable NSString *)decodeDerToSignRS:(NSString *)derSign {
    if (derSign.length == 0) {
        return nil;
    }
    NSData *derData = [GMSmUtils dataFromHexString:derSign];
    size_t sign_len = derData.length;
    const uint8_t *sign_char = (uint8_t *)[derData bytes]; // 明文
    // 复制一份，对比验证
    NSData *derCopy = derData.mutableCopy;
    uint8_t *sign_copy = (uint8_t *)[derCopy bytes];
    
    EC_GROUP *group = EC_GROUP_new_by_curve_name([self curveType]);
    ECDSA_SIG *sig = NULL;
    const BIGNUM *sig_r = NULL;
    const BIGNUM *sig_s = NULL;
    unsigned char *der = NULL;
    int derlen = -1;
    
    NSString *originSign = nil;
    
    do {
        sig = ECDSA_SIG_new();
        if (sig == NULL) {
            break;
        }
        if (d2i_ECDSA_SIG(&sig, &sign_char, sign_len) == NULL) {
            break;
        }
        /* Ensure signature uses DER and doesn't have trailing garbage */
        derlen = i2d_ECDSA_SIG(sig, &der);
        if (derlen != sign_len || memcmp(sign_copy, der, derlen) != 0) {
            break;
        }
        // 取出 r, s
        ECDSA_SIG_get0(sig, &sig_r, &sig_s);
        char *r_hex = BN_bn2hex(sig_r);
        char *s_hex = BN_bn2hex(sig_s);
        NSString *rStr = [NSString stringWithCString:r_hex encoding:NSUTF8StringEncoding];
        NSString *sStr = [NSString stringWithCString:s_hex encoding:NSUTF8StringEncoding];
        OPENSSL_free(r_hex);
        OPENSSL_free(s_hex);
        if (rStr.length == 0 || sStr.length == 0) {
            break;
        }
        // 根据椭圆曲线的类型，依据椭圆曲线上的点获取签名长度
        size_t maxLen = ((EC_GROUP_get_degree(group) + 7) / 8) * 2;
        NSString *paddingR = [GMSmUtils prefixPaddingZero:rStr maxLen:maxLen];
        NSString *paddingS = [GMSmUtils prefixPaddingZero:sStr maxLen:maxLen];
        originSign = [NSString stringWithFormat:@"%@%@", paddingR, paddingS];
    } while (NO);
    // Free
    if (group) { EC_GROUP_free(group); }
    if (sig) { ECDSA_SIG_free(sig); }
    if (der) { OPENSSL_free(der); }
    
    return originSign;
}

// MARK: - ECDH 密钥协商
/// 椭圆曲线 Diffie-Hellman 密钥协商（ECDH），返回 64 字节 16 进制编码格式密钥
/// @param publicHex 对方公钥（ HEX 编码格式）
/// @param privateHex 己方私钥（ HEX 编码格式）
+ (nullable NSString *)computeECDH:(NSString *)publicHex privateKey:(NSString *)privateHex {
    if (!publicHex || publicHex.length == 0 || !privateHex || privateHex.length == 0) {
        return nil;
    }
    const char *public_key = publicHex.UTF8String;
    const char *private_key = privateHex.UTF8String; // 私钥
    EC_GROUP *group = EC_GROUP_new_by_curve_name([self curveType]); // 椭圆曲线
    EC_POINT *pub_point = NULL;  // 公钥
    BIGNUM *pri_big_num = NULL; // 私钥
    EC_KEY *key = NULL;  // 密钥结构体
    NSString *ecdhStr = nil; // 协商出的密钥字符
    
    do {
        // 公钥转换为 EC_POINT
        pub_point = EC_POINT_new(group);
        EC_POINT_hex2point(group, public_key, pub_point, NULL);
        // 私钥转换为 BIGNUM 并存储在 EC_KEY 中
        if (!BN_hex2bn(&pri_big_num, private_key)) {
            break;
        }
        key = EC_KEY_new();
        if (!EC_KEY_set_group(key, group)) {
            break;
        }
        if (!EC_KEY_set_private_key(key, pri_big_num)) {
            break;
        }
        // 根据椭圆曲线的类型，依据椭圆曲线上的点获取ECDH结果
        size_t outlen = (EC_GROUP_get_degree(group) + 7) / 8;
        uint8_t *ecdh_text = (uint8_t *)OPENSSL_zalloc(outlen + 1);
        int ret = ECDH_compute_key(ecdh_text, outlen, pub_point, key, 0);
        if (ret <= 0) {
            break;
        }
        NSData *ecdhData = [NSData dataWithBytes:ecdh_text length:ret];
        ecdhStr = [GMSmUtils hexStringFromData:ecdhData];
        
        OPENSSL_free(ecdh_text);
    } while (NO);
    // Free
    if (group) { EC_GROUP_free(group); }
    if (pub_point) { EC_POINT_free(pub_point); }
    if (pri_big_num) { BN_free(pri_big_num); }
    if (key) { EC_KEY_free(key); }
    
    return ecdhStr;
}


// MARK: - SM2 公钥的压缩与解压缩
/// SM2 公钥压缩。返回值：02 或 03 开头的压缩公钥
/// @param publicHex 04 开头的非压缩公钥
+ (nullable NSString *)compressPublicKey:(NSString *)publicHex {
    NSString *compressedKey = [self compressOrDePublicKey:publicHex isCompress:YES];
    return compressedKey;
}

/// SM2 公钥解压缩。返回值：04 开头的非压缩公钥
/// @param publicHex 02 或 03 开头的压缩公钥
+ (nullable NSString *)decompressPublicKey:(NSString *)publicHex {
    NSString *uncompressedKey = [self compressOrDePublicKey:publicHex isCompress:NO];
    return uncompressedKey;
}

+ (nullable NSString *)compressOrDePublicKey:(nullable NSString *)publicKey isCompress:(BOOL)isCompress {
    // 非压缩前缀 04，压缩格式当坐标点 y 是偶数时，使用 02 作为前缀，否则使用 03 作为前缀
    if (![publicKey hasPrefix:@"02"] && ![publicKey hasPrefix:@"03"] && ![publicKey hasPrefix:@"04"]) {
        return nil;
    }
    const char *public_key = publicKey.UTF8String;
    EC_GROUP *group = EC_GROUP_new_by_curve_name([self curveType]); // 椭圆曲线
    EC_POINT *pub_point = NULL;  // 公钥
    NSString *result = nil; // 解压的公钥
    do {
        if (group == NULL) { break; }
        pub_point = EC_POINT_new(group);
        if (pub_point == NULL) { break; }
        EC_POINT_hex2point(group, public_key, pub_point, NULL);
        point_conversion_form_t form = isCompress ? POINT_CONVERSION_COMPRESSED : POINT_CONVERSION_UNCOMPRESSED;
        const char *compressOrDe = EC_POINT_point2hex(group, pub_point, form, NULL);
        if (compressOrDe == NULL) { break; }
        result = [NSString stringWithCString:compressOrDe encoding:NSUTF8StringEncoding];
    } while (NO);
    // Free
    if (group) { EC_GROUP_free(group); }
    if (pub_point) { EC_POINT_free(pub_point); }
    
    return result;
}

// MARK: - SM2 私钥计算公钥
/// SM2 私钥计算公钥。返回值：04 开头的非压缩公钥
/// @param privateHex  私钥（ HEX 编码格式）
+ (nullable NSString *)calcPublicKeyFromPrivateKey:(NSString *)privateHex {
    if (privateHex.length == 0) {
        return nil;
    }
    const char *private_key = privateHex.UTF8String;
    EC_GROUP *group = EC_GROUP_new_by_curve_name([self curveType]);
    BIGNUM *pri_num = NULL;  // 私钥
    EC_POINT *pub_point = NULL; // 公钥坐标
    EC_KEY *key = NULL; // 密钥对
    NSString *publicKey = nil;  // 计算出的公钥
    do {
        if (!BN_hex2bn(&pri_num, private_key)) {
            break; // 私钥转 BIGNUM
        }
        key = EC_KEY_new();
        if (!EC_KEY_set_group(key, group)) {
            break;
        }
        if (!EC_KEY_set_private_key(key, pri_num)) {
            break; // 设置私钥
        }
        pub_point = EC_POINT_new(group);
        if (!EC_POINT_mul(group, pub_point, pri_num, NULL, NULL, NULL)) {
            break; // 私钥算出公钥
        }
        if (!EC_KEY_set_public_key(key, pub_point)) {
            break; // 设置公钥
        }
        char *hex_pub = EC_POINT_point2hex(group, pub_point, EC_KEY_get_conv_form(key), NULL);
        publicKey = [NSString stringWithCString:hex_pub encoding:NSUTF8StringEncoding];
        
        OPENSSL_free(hex_pub);
    } while (NO);
    // Free
    if (group) { EC_GROUP_free(group); }
    if (pub_point) { EC_POINT_free(pub_point); }
    if (pri_num) { BN_free(pri_num); }
    if (key) { EC_KEY_free(key); }
    
    return publicKey;
}

@end
