#import "GMSm4Utils.h"
#import "GMSmUtils.h"
#import <openssl/sm4.h>
#import <openssl/evp.h>
#import <openssl/modes.h>

@implementation GMSm4Utils

// OpenSSL 1.1.1 以上版本支持国密
+ (void)initialize {
    if (self == [GMSm4Utils class]) {
        if (OPENSSL_VERSION_NUMBER < 0x1010100fL) {
            NSAssert1(NO, @"OpenSSL 版本低于 1.1.1，不支持国密，OpenSSL 当前版本：%s", OPENSSL_VERSION_TEXT);
        }
    }
}

// MARK: - 生成 SM4 密钥
/// 生成 SM4 密钥（HEX 编码格式）。返回值：长度为 SM4_BLOCK_SIZE(16) 字节密钥
+ (nullable NSString *)generateKey {
    NSInteger len = SM4_BLOCK_SIZE;
    uint8_t bytes[len];
    int status = SecRandomCopyBytes(kSecRandomDefault, (sizeof bytes)/(sizeof bytes[0]), &bytes);
    if (status == errSecSuccess) {
        NSData *resultData = [NSData dataWithBytes:bytes length:len];
        return [GMSmUtils hexStringFromData:resultData];
    }
    // 容错，若 SecRandomCopyBytes 失败
    NSString *keyStr = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    NSMutableString *randomStr = [[NSMutableString alloc] initWithCapacity:len];
    for (int i = 0; i < len; i++){
        uint32_t index = arc4random_uniform((uint32_t)keyStr.length);
        NSString *subChar = [keyStr substringWithRange:NSMakeRange(index, 1)];
        [randomStr appendString:subChar];
    }
    NSData *randomData = [randomStr dataUsingEncoding:NSUTF8StringEncoding];
    return [GMSmUtils hexStringFromData:randomData];
}

// MARK: - ECB 加密
/// SM4 ECB 模式加密。返回值：加密后的密文（HEX 编码格式）
/// @param plaintext 明文（字符串类型）
/// @param keyHex  密钥（HEX 编码格式）
+ (nullable NSString *)encryptTextWithECB:(NSString *)plaintext keyHex:(NSString *)keyHex {
    if (plaintext.length == 0 || keyHex.length == 0) {
        return nil;
    }
    NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [GMSmUtils dataFromHexString:keyHex];
    NSData *cipherData = [self encryptDataWithECB:plainData keyData:keyData];
    NSString *cipherHex = [GMSmUtils hexStringFromData:cipherData];
    return cipherHex;
}

/// SM4 ECB 模式加密。返回值：加密后的密文
/// @param plainData 明文（NSData 类型）
/// @param keyData SM4 密钥，长度  SM4_BLOCK_SIZE(16) 字节任意数据
+ (nullable NSData *)encryptDataWithECB:(NSData *)plainData keyData:(NSData *)keyData {
    if (plainData.length == 0 || keyData.length != SM4_BLOCK_SIZE) {
        return nil;
    }
    uint8_t *plain_obj = (uint8_t *)[plainData bytes];
    size_t plain_obj_len = (size_t)[plainData length];
    
    // 计算填充长度
    int pad_en = SM4_BLOCK_SIZE - plain_obj_len % SM4_BLOCK_SIZE;
    size_t result_len = plain_obj_len + pad_en;
    // PKCS7 填充
    uint8_t *p_text = (uint8_t *)OPENSSL_zalloc((int)(result_len + 1));
    memcpy(p_text, plain_obj, plain_obj_len);
    memset(p_text + plain_obj_len, pad_en, pad_en);
    
    uint8_t *result = (uint8_t *)OPENSSL_zalloc((int)(result_len + 1));
    int group_num = (int)(result_len / SM4_BLOCK_SIZE);
    // 密钥 key Hex 转 uint8_t
    uint8_t *k_text = (uint8_t *)[keyData bytes];
    SM4_KEY sm4Key;
    SM4_set_key(k_text, &sm4Key);
    // 循环加密
    for (NSInteger i = 0; i < group_num; i++) {
        uint8_t block[SM4_BLOCK_SIZE];
        memcpy(block, p_text + i * SM4_BLOCK_SIZE, SM4_BLOCK_SIZE);
        
        SM4_encrypt(block, block, &sm4Key);
        memcpy(result + i * SM4_BLOCK_SIZE, block, SM4_BLOCK_SIZE);
    }
    NSData *cipherData = [NSData dataWithBytes:result length:result_len];
    // Free
    if (p_text) { OPENSSL_free(p_text); }
    if (result) { OPENSSL_free(result); }
    
    return cipherData;
}

// MARK: - ECB 解密
/// SM4 ECB 模式解密。返回值：解密后的明文（HEX 编码格式）
/// @param ciphertext 密文（HEX 编码格式）
/// @param keyHex 密钥（HEX 编码格式）
+ (nullable NSString *)decryptTextWithECB:(NSString *)ciphertext keyHex:(NSString *)keyHex {
    NSData *cipherData = [GMSmUtils dataFromHexString:ciphertext];
    NSData *keyData = [GMSmUtils dataFromHexString:keyHex];
    NSData *plainData = [self decryptDataWithECB:cipherData keyData:keyData];
    if (plainData.length > 0) {
        NSString *plaintext = [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
        return plaintext;
    }
    return nil;
}

/// SM4 ECB 模式解密。返回值：解密后的明文
/// @param cipherData 密文（NSData 类型）
/// @param keyData SM4 密钥，长度  SM4_BLOCK_SIZE(16) 字节任意数据
+ (nullable NSData *)decryptDataWithECB:(NSData *)cipherData keyData:(NSData *)keyData {
    if (cipherData.length == 0 || keyData.length != SM4_BLOCK_SIZE) {
        return nil;
    }
    uint8_t *c_obj = (uint8_t *)[cipherData bytes];
    size_t c_obj_len = (size_t)[cipherData length];
    
    uint8_t *result = (uint8_t *)OPENSSL_zalloc((int)(c_obj_len + 1));
    int group_num = (int)(c_obj_len / SM4_BLOCK_SIZE);
    // 密钥 key Hex 转 uint8_t
    uint8_t *k_text = (uint8_t *)[keyData bytes];
    SM4_KEY sm4Key;
    SM4_set_key(k_text, &sm4Key);
    // 循环解密
    for (NSInteger i = 0; i < group_num; i++) {
        uint8_t block[SM4_BLOCK_SIZE];
        memcpy(block, c_obj + i * SM4_BLOCK_SIZE, SM4_BLOCK_SIZE);
        
        SM4_decrypt(block, block, &sm4Key);
        memcpy(result + i * SM4_BLOCK_SIZE, block, SM4_BLOCK_SIZE);
    }
    // 移除填充
    int pad_len = (int)result[c_obj_len - 1];
    int end_len = (int)(c_obj_len - pad_len);
    NSData *plainData = [NSData dataWithBytes:result length:end_len];
    // Free
    if (result) { OPENSSL_free(result); }
    
    return plainData;
}

// MARK: - CBC 加密
/// SM4 CBC 模式加密。返回值：加密后的密文（HEX 编码格式）
/// @param plaintext 明文（字符串类型）
/// @param keyHex 密钥（HEX 编码格式）
/// @param ivecHex 密钥（HEX 编码格式），确保加解密相同即可
+ (nullable NSString *)encryptTextWithCBC:(NSString *)plaintext keyHex:(NSString *)keyHex ivecHex:(NSString *)ivecHex {
    if (plaintext.length == 0 || keyHex.length == 0) {
        return nil;
    }
    NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [GMSmUtils dataFromHexString:keyHex];
    NSData *ivecData = [GMSmUtils dataFromHexString:ivecHex];
    NSData *cipherData = [self encryptDataWithCBC:plainData keyData:keyData ivecData:ivecData];
    NSString *cipherHex = [GMSmUtils hexStringFromData:cipherData];
    return cipherHex;
}

/// SM4 CBC 模式加密。返回值：加密后的密文
/// @param plainData 明文（NSData 类型）
/// @param keyData SM4 密钥，长度  SM4_BLOCK_SIZE(16) 字节任意数据
/// @param ivecData CBC 模式需传入长度  SM4_BLOCK_SIZE(16) 字节任意字符，确保加解密相同即可
+ (nullable NSData *)encryptDataWithCBC:(NSData *)plainData keyData:(NSData *)keyData ivecData:(NSData *)ivecData {
    if (plainData.length == 0 || keyData.length != SM4_BLOCK_SIZE || ivecData.length != SM4_BLOCK_SIZE) {
        return nil;
    }
    // 明文
    uint8_t *p_obj = (uint8_t *)[plainData bytes];
    size_t p_obj_len = (size_t)[plainData length];
    
    int pad_len = SM4_BLOCK_SIZE - p_obj_len % SM4_BLOCK_SIZE;
    size_t result_len = p_obj_len + pad_len;
    // PKCS7 填充
    uint8_t *p_text = (uint8_t *)OPENSSL_zalloc((int)(result_len + 1));
    memcpy(p_text, p_obj, p_obj_len);
    memset(p_text + p_obj_len, pad_len, pad_len);
    
    uint8_t *result = (uint8_t *)OPENSSL_zalloc((int)(result_len + 1));
    // 密钥 key Hex 转 uint8_t
    uint8_t *k_text = (uint8_t *)[keyData bytes];
    SM4_KEY sm4Key;
    SM4_set_key(k_text, &sm4Key);
    // 初始化向量
    uint8_t *iv_text = (uint8_t *)[ivecData bytes];
    uint8_t ivec_block[SM4_BLOCK_SIZE] = {0};
    if (iv_text) {
        memcpy(ivec_block, iv_text, SM4_BLOCK_SIZE);
    }
    // cbc 加密
    CRYPTO_cbc128_encrypt(p_text, result, result_len, &sm4Key, ivec_block,
                          (block128_f)SM4_encrypt);
    
    NSData *cipherData = [NSData dataWithBytes:result length:result_len];
    // Free
    if (p_text) { OPENSSL_free(p_text); }
    if (result) { OPENSSL_free(result); }
    
    return cipherData;
}

// MARK: - CBC 解密
/// SM4 CBC 模式解密。返回值：解密后的明文
/// @param ciphertext 密文（字符串类型）
/// @param keyHex 密钥（HEX 编码格式）
/// @param ivecHex 密钥（HEX 编码格式），确保加解密相同即可
+ (nullable NSString *)decryptTextWithCBC:(NSString *)ciphertext keyHex:(NSString *)keyHex ivecHex:(NSString *)ivecHex {
    NSData *cipherData = [GMSmUtils dataFromHexString:ciphertext];
    NSData *keyData = [GMSmUtils dataFromHexString:keyHex];
    NSData *ivecData = [GMSmUtils dataFromHexString:ivecHex];
    NSData *plainData = [self decryptDataWithCBC:cipherData keyData:keyData ivecData:ivecData];
    if (plainData.length > 0) {
        NSString *plaintext = [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
        return plaintext;
    }
    return nil;
}

/// SM4 CBC 模式解密。返回值：解密后的明文
/// @param cipherData 密文（NSData 类型）
/// @param keyData SM4 密钥，长度 SM4_BLOCK_SIZE(16) 字节任意数据
/// @param ivecData CBC 模式需传入长度  SM4_BLOCK_SIZE(16) 字节任意字符，确保加解密相同即可
+ (nullable NSData *)decryptDataWithCBC:(NSData *)cipherData keyData:(NSData *)keyData ivecData:(NSData *)ivecData {
    if (cipherData.length == 0 || keyData.length != SM4_BLOCK_SIZE || ivecData.length != SM4_BLOCK_SIZE) {
        return nil;
    }
    uint8_t *c_obj = (uint8_t *)[cipherData bytes];
    size_t c_obj_len = (size_t)[cipherData length];
    
    uint8_t *result = (uint8_t *)OPENSSL_zalloc((int)(c_obj_len + 1));
    // 密钥 key Hex 转 uint8_t
    uint8_t *k_text = (uint8_t *)[keyData bytes];
    SM4_KEY sm4Key;
    SM4_set_key(k_text, &sm4Key);
    // 初始化向量
    uint8_t *iv_text = (uint8_t *)[ivecData bytes];
    uint8_t ivec_block[SM4_BLOCK_SIZE] = {0};
    if (iv_text) {
        memcpy(ivec_block, iv_text, SM4_BLOCK_SIZE);
    }
    // CBC 解密
    CRYPTO_cbc128_decrypt(c_obj, result, c_obj_len, &sm4Key, ivec_block,
                          (block128_f)SM4_decrypt);
    // 移除填充
    int pad_len = (int)result[c_obj_len - 1];
    int end_len = (int)(c_obj_len - pad_len);
    NSData *plainData = [NSData dataWithBytes:result length:end_len];
    // Free
    if (result) { OPENSSL_free(result); }
    
    return plainData;
}

@end
