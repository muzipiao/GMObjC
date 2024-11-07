#import "GMDoctor.h"
#ifdef DEBUG
#import <OpenSSL/OpenSSL.h>
#include <mach/mach.h> // CPU 类型
#import "GMSm2Utils.h"
#import "GMSm2Bio.h"
#import "GMSmUtils.h"
#endif

@implementation GMDoctor
#ifdef DEBUG

// Public-检查 SM2 加密
+ (void)checkSm2Encrypt:(NSData *)plainData publicKey:(NSString *)publicKey {
    [self checkEnvironment]; // 检查 OpenSSL 环境
    [self checkSm2PublicKey:publicKey]; // 检查公钥格式
    NSAssert(plainData.length != 0, @"GMObjC-Error：传入的数据存在空值");
    // 加密测试
    NSData *cipherData = [GMSm2Utils encryptData:plainData publicKey:publicKey];
    NSAssert(cipherData.length != 0, @"GMObjC-Error：公钥可能不正确，请在网站上或其他平台验证公钥正确性");
    // ASN1 解码
    NSData *c1c3c2Data = [GMSm2Utils asn1DecodeToC1C3C2Data:cipherData hasPrefix:NO];
    NSAssert(c1c3c2Data.length != 0, @"GMObjC-Error：ASN1 解码错误，加密结果可能不正确");
    NSAssert(NO, @"GMObjC-Error：未分析到失败原因，请结合在线网站或者其他平台进行验证");
}

// Public-检查 SM2 解密
+ (void)checkSm2Decrypt:(NSData *)cipherData privateKey:(NSString *)privateKey {
    [self checkEnvironment]; // 检查 OpenSSL 环境
    [self checkSm2PrivateKey:privateKey]; // 检查私钥格式
    [self checkSm2CipherData:cipherData]; // 判断原文是否为字符串
    NSAssert(cipherData.length != 0, @"GMObjC-Error：传入的数据存在空值");
    // 直接进行解密
    NSData *plainData = [GMSm2Utils decryptData:cipherData privateKey:privateKey];
    if (plainData.length > 0) {
        NSAssert(NO, @"GMObjC-Error：经测试，解密正常");
    }
    // 解密失败，先检查是否为 ASN1 编码，如果不是 ASN1 编码，则需要进行 ASN1 编码
    [self sm2DecryptWithASN1:cipherData privateKey:privateKey];
    // 解密失败，检查是不是直接传入了普通字符串
    NSString *ciphertext = [[NSString alloc] initWithData:cipherData encoding:NSUTF8StringEncoding];
    // 解密失败，检查直接传入的字符串是否为 HEX 编码格式
    [self sm2DecryptWithHex:ciphertext privateKey:privateKey];
    // 解密失败，检查直接传入的字符串是否为 Base64 编码格式
    [self sm2DecryptWithBase64:ciphertext privateKey:privateKey];
    NSAssert(ciphertext.length == 0, @"GMObjC-Error：传入的密文为普通字符串，请传入 ASN1 编码格式密文");
    NSAssert(NO, @"GMObjC-Error：未分析到失败原因，可能是密钥和密文不匹配，请结合在线网站或者其他平台进行验证");
}

// Public-检查 SM2 签名
+ (void)checkSignData:(NSData *)plainData privateKey:(NSString *)privateKey userData:(nullable NSData *)userData {
    [self checkEnvironment]; // 检查 OpenSSL 环境
    [self checkSm2PrivateKey:privateKey]; // 检查私钥格式
    NSAssert(plainData.length != 0, @"GMObjC-Error：传入的数据存在空值");
    // 签名测试
    NSString *signRS = [GMSm2Utils signData:plainData privateKey:privateKey userData:userData];
    NSAssert(signRS.length != 0, @"GMObjC-Error：私钥可能不正确，请在网站上或其他平台验证私钥正确性");
    // DER 解码
    NSString *signDer = [GMSm2Utils encodeDerWithSignRS:signRS];
    NSAssert(signDer.length != 0, @"GMObjC-Error：DER 编码错误，签名结果可能不正确");
    NSAssert(NO, @"GMObjC-Error：未分析到失败原因，请结合在线网站或者其他平台进行验证");
}

// Public-验证 SM2 签名
+ (void)checkVerifyData:(NSData *)plainData signRS:(NSString *)signRS publicKey:(NSString *)publicKey userData:(nullable NSData *)userData {
    [self checkEnvironment]; // 检查 OpenSSL 环境
    [self checkSm2PublicKey:publicKey]; // 检查公钥格式
    NSAssert(plainData.length != 0, @"GMObjC-Error：传入的数据存在空值");
    NSAssert(signRS.length != 0, @"GMObjC-Error：传入的数据存在空值");
    // 直接进行验签
    BOOL isSuccess0 = [GMSm2Utils verifyData:plainData signRS:signRS publicKey:publicKey userData:userData];
    NSAssert(isSuccess0 == NO, @"GMObjC-Error：经测试，验签正常");
    // 判断 signRS 为 ASN1 编码格式
    if ([signRS hasPrefix:@"30"]) {
        NSString *decodeRS = [GMSm2Utils decodeDerToSignRS:signRS];
        NSAssert(decodeRS.length > 0, @"GMObjC-Error：signRS 不是有效的 DER 编码格式，请结合在线网站或者其他平台进行验证");
        BOOL isSuccess1 = [GMSm2Utils verifyData:plainData signRS:decodeRS publicKey:publicKey userData:userData];
        if (isSuccess1 == YES) {
            NSAssert(NO, @"GMObjC-Error：经测试，signRS 为 DER 编码格式，先使用 [GMSm2Utils decodeDerToSignRS:] 解码即可");
        } else {
            NSAssert(isSuccess0 == NO, @"GMObjC-Error：signRS 可能不是有效的 DER 编码格式，请结合在线网站或者其他平台进行验证");
        }
    }
    // 判断 userData 为空
    BOOL isSuccess2 = [GMSm2Utils verifyData:plainData signRS:signRS publicKey:publicKey userData:nil];
    NSAssert(isSuccess2 == NO, @"GMObjC-Error：userData 参数错误，应传入 nil，取默认值 1234567812345678");
    NSAssert(NO, @"GMObjC-Error：未分析到失败原因，请结合在线网站或者其他平台进行验证");
}

// Private-判断原文 cipherData 是否为字符串
+ (void)checkSm2CipherData:(NSData *)cipherData {
    NSData *convertData = [GMSmUtils checkStringData:cipherData];
    if ([convertData isEqualToData:cipherData]) {
        return;
    }
    NSString *cipherString = [[NSString alloc] initWithData:cipherData encoding:NSUTF8StringEncoding];
    if ([GMSmUtils isValidHexString:cipherString]) {
        NSAssert(NO, @"GMObjC-Error：使用 [GMSm2Utils dataFromHexString:] 解析 cipherData");
    }
    if ([GMSmUtils isValidBase64String:cipherString]) {
        NSAssert(NO, @"GMObjC-Error：使用 [GMSm2Utils dataFromBase64EncodedString:] 解析 cipherData");
    }
}

// Private-如果直接传入 HEX 格式字符串数据
+ (void)sm2DecryptWithHex:(NSString *)cipherHex privateKey:(NSString *)privateKey {
    if (cipherHex.length == 0 || [GMSmUtils isValidHexString:cipherHex] == NO) {
        return;
    }
    // 将 HEX 格式密文解码为 NSData
    NSData *cipherData = [GMSmUtils dataFromHexString:cipherHex];
    // 尝试直接解密密文 Data
    if ([cipherHex hasPrefix:@"30"]) {
        NSData *plainData = [GMSm2Utils decryptData:cipherData privateKey:privateKey];
        NSAssert(plainData.length == 0, @"GMObjC-Error：解密失败的原因是直接传入了普通字符串，先使用 [GMSmUtils dataFromHexString:] 解码");
    }
    // 非 30 开头，则尝试 ASN1 编码
    [self sm2DecryptWithASN1:cipherData privateKey:privateKey];
}

// Private-如果直接传入 Base64 格式字符串数据
+ (void)sm2DecryptWithBase64:(NSString *)cipherBase64 privateKey:(NSString *)privateKey {
    if (cipherBase64.length == 0 || [GMSmUtils isValidBase64String:cipherBase64] == NO) {
        return;
    }
    // 将 Base64 格式密文解码为 NSData
    NSData *cipherData = [GMSmUtils dataFromBase64EncodedString:cipherBase64];
    NSString *cipherHex = [GMSmUtils hexStringFromData:cipherData];
    // 尝试直接解密密文 Data
    if ([cipherHex hasPrefix:@"30"]) {
        NSData *plainData = [GMSm2Utils decryptData:cipherData privateKey:privateKey];
        NSAssert(plainData.length == 0, @"GMObjC-Error：解密失败的原因是直接传入了普通字符串，先使用 [GMSmUtils dataFromHexString:] 解码");
    }
    // 非 30 开头，则尝试 ASN1 编码
    [self sm2DecryptWithASN1:cipherData privateKey:privateKey];
}

// Private-将数据进行 ASN1 再解密
+ (void)sm2DecryptWithASN1:(NSData *)cipherData privateKey:(NSString *)privateKey {
    [self checkSm2CipherData:cipherData]; // 判断原文是否为字符串
    // 解密失败，先检查是否为 ASN1 编码，如果不是 ASN1 编码，则需要进行 ASN1 编码
    NSData *asn1CipherData0 = [GMSm2Utils asn1EncodeWithC1C3C2Data:cipherData hasPrefix:NO];
    NSData *plainData = [GMSm2Utils decryptData:asn1CipherData0 privateKey:privateKey];
    NSAssert(plainData.length == 0, @"GMObjC-Error：解密失败的原因是 cipherData 不是 ASN1 编码格式，使用时进行 ASN1 编码");
    // 解密失败，尝试 ASN1 编码前，移除 cipherData 的 04 前缀
    NSData *asn1CipherData1 = [GMSm2Utils asn1EncodeWithC1C3C2Data:cipherData hasPrefix:YES];
    plainData = [GMSm2Utils decryptData:asn1CipherData1 privateKey:privateKey];
    NSAssert(plainData.length == 0, @"GMObjC-Error：解密失败的原因是 cipherData 不是 ASN1 编码格式，使用时进行 ASN1 编码");
    // 解密失败，尝试改变 C1C2C3 的顺序，当密文无前缀时
    NSData *c1c3c2Data0 = [GMSm2Utils convertC1C2C3DataToC1C3C2:cipherData hasPrefix:NO];
    NSData *asn1CipherData2 = [GMSm2Utils asn1EncodeWithC1C3C2Data:c1c3c2Data0 hasPrefix:NO];
    plainData = [GMSm2Utils decryptData:asn1CipherData2 privateKey:privateKey];
    NSAssert(plainData.length == 0, @"GMObjC-Error：解密失败的原因是 cipherData 不是 ASN1 编码格式，且顺序为 C1C2C3，先调整顺序，再 ASN1 编码");
    // 解密失败，尝试改变 C1C2C3 的顺序，当密文有前缀时
    NSData *c1c3c2Data1 = [GMSm2Utils convertC1C2C3DataToC1C3C2:cipherData hasPrefix:YES];
    NSData *asn1CipherData3 = [GMSm2Utils asn1EncodeWithC1C3C2Data:c1c3c2Data1 hasPrefix:YES];
    plainData = [GMSm2Utils decryptData:asn1CipherData3 privateKey:privateKey];
    NSAssert(plainData.length == 0, @"GMObjC-Error：解密失败的原因是 cipherData 不是 ASN1 编码格式，顺序为 C1C2C3，并包含04前缀，先调整顺序，再 ASN1 编码");
}

// Public-检查公钥
+ (void)checkSm2PublicKey:(NSString *)publicKey {
    NSAssert(publicKey.length != 0, @"GMObjC-Error：公钥为空");
    
    if ([publicKey containsString:@"-----BEGIN"]) {
        NSAssert(NO, @"GMObjC-Error：privateKey 为 PEM 格式，使用 [GMSm2Bio readPublicKeyFromPemData:] 读取");
    }
    // 判断是不是 PEM 或者 DER
    if ([GMSmUtils isValidBase64String:publicKey] == YES && [GMSmUtils isValidHexString:publicKey] == NO) {
        NSArray *pemList = @[@"-----BEGIN PUBLIC KEY-----", publicKey, @"-----END PUBLIC KEY-----"];
        NSString *pemPubKey = [pemList componentsJoinedByString:@"\n"];
        NSString *pemKeyHex = [GMSm2Bio readPublicKeyFromPemData:[pemPubKey dataUsingEncoding:NSUTF8StringEncoding] password:nil];
        if (pemKeyHex.length > 0) {
            NSAssert(NO, @"GMObjC-Error：公钥为不完整的 PEM 格式，先拼接，使用 [GMSm2Bio readPublicKeyFromPemData:] 读取");
        } else {
            NSAssert(NO, @"GMObjC-Error：公钥必须为 04 开头的 HEX 编码格式，使用 [GMSmUtils dataFromBase64EncodedString:] 解码");
        }
    }
    if ([GMSmUtils isValidHexString:publicKey] == NO) {
        NSAssert(NO, @"GMObjC-Error：公钥必须为 04 开头的 HEX 编码格式");
    }
    // 检查是否传入了普通字符串
    NSData *keyData = [GMSmUtils dataFromHexString:publicKey];
    NSString *keyStr = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
    if (keyStr.length > 0) {
        NSAssert(NO, @"GMObjC-Error：公钥格式错误，请传入正确的 HEX 编码格式公钥，不是将普通字符串进行 HEX 编码");
    }
    // 非压缩前缀 04，压缩格式当坐标点 y 是偶数时，使用 02 作为前缀，否则使用 03 作为前缀
    if ([publicKey hasPrefix:@"02"] || [publicKey hasPrefix:@"03"]) {
        NSAssert(NO, @"GMObjC-Error：公钥为压缩格式，请使用[GMSm2Utils decompressPublicKey:]解压");
    }
    if (![publicKey hasPrefix:@"04"] && (publicKey.length == 128 || publicKey.length == 256)) {
        NSAssert(NO, @"GMObjC-Error：公钥必须为 04 开头的 HEX 编码格式，请在公钥前面手动拼接 04 字符串");
    }
    if (![publicKey hasPrefix:@"04"]) {
        NSAssert(NO, @"GMObjC-Error：公钥必须为 04 开头的 HEX 编码格式，一般长度130字节或258字节");
    }
    // 256位未压缩形式的公钥长度为64字节,对应x、y坐标各32字节；压缩形式的公钥长度为32字节,只包含x坐标。
    if (publicKey.length < 130) {
        NSAssert(NO, @"GMObjC-Error：公钥不正确，必须为 04 开头的 HEX 编码格式，一般长度130字节或258字节");
    }
}

// Public-检查私钥
+ (void)checkSm2PrivateKey:(NSString *)privateKey {
    NSAssert(privateKey.length != 0, @"GMObjC-Error：私钥为空");
    
    if ([privateKey containsString:@"-----BEGIN"]) {
        NSAssert(NO, @"GMObjC-Error：私钥为 PEM 格式，使用 [GMSm2Bio readPrivateKeyFromPemData:] 读取");
    }
    if ([GMSmUtils isValidBase64String:privateKey] == YES && [GMSmUtils isValidHexString:privateKey] == NO) {
        NSArray *pemList = @[@"-----BEGIN EC PRIVATE KEY-----", privateKey, @"-----END EC PRIVATE KEY-----"];
        NSString *pemPriKey = [pemList componentsJoinedByString:@"\n"];
        NSString *pemKeyHex = [GMSm2Bio readPrivateKeyFromPemData:[pemPriKey dataUsingEncoding:NSUTF8StringEncoding] password:nil];
        if (pemKeyHex.length > 0) {
            NSAssert(NO, @"GMObjC-Error：私钥为不完整的 PEM 格式，先拼接，使用 [GMSm2Bio readPrivateKeyFromPemData:] 读取");
        } else {
            NSAssert(NO, @"GMObjC-Error：私钥必须为 HEX 编码格式，使用 [GMSmUtils dataFromBase64EncodedString:] 解码");
        }
    }
    if ([GMSmUtils isValidHexString:privateKey] == NO) {
        NSAssert(NO, @"GMObjC-Error：私钥必须为正确的 HEX 编码格式");
    }
    // 检查是否传入了普通字符串
    NSData *keyData = [GMSmUtils dataFromHexString:privateKey];
    NSString *keyStr = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
    if (keyStr.length > 0) {
        NSAssert(NO, @"GMObjC-Error：私钥格式错误，请传入正确的 HEX 编码格式私钥，不是将普通字符串进行 HEX 编码");
    }
    // 与公钥长度对应，一般为 32 或 64 字节
    if (privateKey.length < 32 || privateKey.length % 16 != 0) {
        NSAssert(NO, @"GMObjC-Error：私钥不正确，必须为长度 32 或 64 字节的 HEX 编码格式");
    }
}

// MARK: - 检查环境
// Public-检查OpenSSL环境
+ (void)checkEnvironment {
    NSAssert1([self isRightOpenSSLVersion], @"GMObjC-Error：OpenSSL 版本低于 1.1.1，不支持国密，OpenSSL 当前版本：%s", OPENSSL_VERSION_TEXT);
    NSAssert([self isSupportCPUType], @"GMObjC-Error：GMObjC 仅支持 arm64 和 x86_64 等类型 CPU，支持 iOS & Mac");
    // 当存在多个版本 OpenSSL 时，最简单的方法是将 GMObjC 编译为动态库，不用再 link OpenSSL 静态库；
    // 其他解决方案供参考1，排查删除较旧的 OpenSSL，统一为较新的 OpenSSL 库；
    // 其他解决方案供参考2，更改静态库编译顺序，将新版本 OpenSSL 排在前面；
    NSAssert([self isNotExistMultipleOpenSSL], @"GMObjC-Error：项目中可能存在多个 OpenSSL 版本，例如百度地图，阿里的Mpaas都有 OpenSSL");
}

// Private-检查 OpenSSL 版本
+ (BOOL)isRightOpenSSLVersion {
    if (OPENSSL_VERSION_NUMBER >= 0x1010100fL) {
        return YES;
    }
    return NO;
}

// Private-检查 CPU 类型
+ (BOOL)isSupportCPUType {
    host_basic_info_data_t hostInfo;
    mach_msg_type_number_t infoCount;
    infoCount = HOST_BASIC_INFO_COUNT;
    host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo, &infoCount);
    if (hostInfo.cpu_type == CPU_TYPE_ARM64 || hostInfo.cpu_type == CPU_TYPE_X86_64) {
        return YES;
    }
    return NO;
}

// Private-检查存在多个 OpenSSL
+ (BOOL)isNotExistMultipleOpenSSL {
    EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_sm2);
    if (group == NULL) {
        return NO;
    }
    EC_GROUP_free(group);
    return YES;
}

#endif
@end
