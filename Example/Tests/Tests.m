//
//  GmObjCTests.m
//  GmObjCTests
//
//  Created by lifei on 07/26/2019.
//  Copyright (c) 2019 lifei. All rights reserved.
//

@import XCTest;
#import "GMSm.h"

@interface Tests : XCTestCase

// sm4 加解密文件测试
@property (nonatomic, strong) NSData *fileData;

@end

static NSString *gPubkey = @"0408E3FFF9505BCFAF9307E665E9229F4E1B3936437A870407EA3D97886BAFBC9C624537215DE9507BC0E2DD276CF74695C99DF42424F28E9004CDE4678F63D698";
static NSString *gPrivkey = @"90F3A42B9FE24AB196305FD92EC82E647616C3A3694441FB3422E7838E24DEAE";

@implementation Tests

- (void)setUp
{
    [super setUp];
    NSString *txtPath = [[NSBundle mainBundle] pathForResource:@"sm4TestFile.txt" ofType:nil];
    self.fileData = [NSData dataWithContentsOfFile:txtPath];
}

- (void)tearDown
{
    self.fileData = nil;
    [super tearDown];
}

/**
 * 测试 sm4 出现空的情况
 */
- (void)testSm4Null {
    NSString *strNull = nil;
    NSString *strLenZero = @"";
    NSData *dataNull = [NSData data];
    NSString *sm4Key = [GMSm4Utils createSm4Key];
    
    // 加密空
    NSString *encryptNullStr = [GMSm4Utils encrypt:strNull Key:sm4Key];
    XCTAssertNil(encryptNullStr, @"加密字符串应为空");
    NSString *encryptLenZeroStr = [GMSm4Utils encrypt:strLenZero Key:sm4Key];
    XCTAssertNil(encryptLenZeroStr, @"加密字符串应为空");
    NSString *encryptNullKey = [GMSm4Utils encrypt:@"123456" Key:@""];
    XCTAssertNil(encryptNullKey, @"加密字符串应为空");
    NSData *encryptNullData = [GMSm4Utils encryptData:dataNull Key:sm4Key];
    XCTAssertNil(encryptNullData, @"Data 为空，加密 Data 应为空");
    NSData *encryptDataNullKey = [GMSm4Utils encryptData:self.fileData Key:@""];
    XCTAssertNil(encryptDataNullKey, @"key为空，加密 Data 应为空");
    
    // 解密空
    NSString *decryptNullStr = [GMSm4Utils decrypt:strNull Key:sm4Key];
    XCTAssertNil(decryptNullStr, @"解密字符串应为空");
    NSString *decryptLenZeroStr = [GMSm4Utils decrypt:strLenZero Key:sm4Key];
    XCTAssertNil(decryptLenZeroStr, @"解密字符串应为空");
    NSString *decryptNullKey = [GMSm4Utils decrypt:@"123456" Key:@""];
    XCTAssertNil(decryptNullKey, @"解密字符串应为空");
    
    NSData *decryptNullData = [GMSm4Utils decryptData:dataNull Key:sm4Key];
    XCTAssertNil(decryptNullData, @"Data 为空，解密 Data 应为空");
    NSData *decryptDataNullKey = [GMSm4Utils decryptData:self.fileData Key:@""];
    XCTAssertNil(decryptDataNullKey, @"key为空，解密 Data 应为空");
}

/**
 * 测试大量生产 sm2 公私钥
 */
- (void)testSm4CreateKeys {
    for (NSInteger i = 0; i < 1000; i++) {
        // 生成一对新的公私钥
//        NSString *sm4Key = [GMSm4Utils create]
        NSString *sm4Key = [GMSm4Utils createSm4Key];
        XCTAssertNotNil(sm4Key, @"生成 sm4 密钥不为空");
        XCTAssertTrue(sm4Key.length == 16, @" sm4密钥长度 ");
    }
}


/**
 * 测试 sm4 加解密文件
 */
- (void)testSm4File {
    XCTAssertNotNil(self.fileData, @"待加密 NSData 不为空");
    
    for (NSInteger i = 0; i < 1000; i++) {
        // 生产密钥不为空
        NSString *sm4Key = [GMSm4Utils createSm4Key];
        XCTAssertNotNil(sm4Key, @"生成 sm4 密钥不为空");
        
        NSData *encryptData = [GMSm4Utils encryptData:self.fileData Key:sm4Key];
        XCTAssertTrue(encryptData.length > 0, @"加密后数据不为空");
        
        NSData *decryptData = [GMSm4Utils decryptData:encryptData Key:sm4Key];
        XCTAssertTrue(decryptData.length > 0, @"解密后数据不为空");
        
        // 加解密后与原数据相同
        BOOL isSameData = [decryptData isEqualToData:self.fileData];
        XCTAssertTrue(isSameData, @"sm4 加解密后数据不变");
    }
}

/**
 * 测试 sm 4 大量加解密数字英文字符字符串
 */
- (void)testSm4En {
    for (NSInteger i = 0; i < 10000; i++) {
        int randLen = arc4random_uniform((int)10000);
        NSString *plainText = [self randomEn:randLen];
        XCTAssertNotNil(plainText, @"生成字符串不为空");
        // 生产密钥不为空
        NSString *sm4Key = [GMSm4Utils createSm4Key];
        XCTAssertNotNil(sm4Key, @"生成 sm4 密钥不为空");
        
        NSString *encryptStr = [GMSm4Utils encrypt:plainText Key:sm4Key];
        XCTAssertNotNil(encryptStr, @"加密字符串不为空");
        
        NSString *decryptStr = [GMSm4Utils decrypt:encryptStr Key:sm4Key];
        XCTAssertNotNil(decryptStr, @"解密结果不为空");
        
        BOOL isSame = [decryptStr isEqualToString:plainText];
        XCTAssertTrue(isSame, @"加解密结果应该相同");
    }
}

/**
 * 测试大量加密中文字符串无错误
 */
- (void)testSm4Zh {
    for (NSInteger i = 0; i < 1000; i++) {
        int randLen = arc4random_uniform((int)1000);
        NSString *plainText = [self randomZh:randLen];
        XCTAssertNotNil(plainText, @"生成字符串不为空");
        
        // 生产密钥不为空
        NSString *sm4Key = [GMSm4Utils createSm4Key];
        XCTAssertNotNil(sm4Key, @"生成 sm4 密钥不为空");
        
        NSString *encryptStr = [GMSm4Utils encrypt:plainText Key:sm4Key];
        XCTAssertNotNil(encryptStr, @"加密字符串不为空");
        
        NSString *decryptStr = [GMSm4Utils decrypt:encryptStr Key:sm4Key];
        XCTAssertNotNil(decryptStr, @"解密结果不为空");
        
        BOOL isSame = [decryptStr isEqualToString:plainText];
        XCTAssertTrue(isSame, @"加解密结果应该相同");
    }
}

/**
 * 测试大量加密中英文混合字符串无错误
 */
- (void)testSm4ZhEn {
    for (NSInteger i = 0; i < 1000; i++) {
        int randLen = arc4random_uniform((int)1000);
        NSString *plainText = [self randomZhEnString:randLen];
        XCTAssertNotNil(plainText, @"生成字符串不为空");
        // 生产密钥不为空
        NSString *sm4Key = [GMSm4Utils createSm4Key];
        XCTAssertNotNil(sm4Key, @"生成 sm4 密钥不为空");
        
        NSString *encryptStr = [GMSm4Utils encrypt:plainText Key:sm4Key];
        XCTAssertNotNil(encryptStr, @"加密字符串不为空");
        
        NSString *decryptStr = [GMSm4Utils decrypt:encryptStr Key:sm4Key];
        XCTAssertNotNil(decryptStr, @"解密结果不为空");
        
        BOOL isSame = [decryptStr isEqualToString:plainText];
        XCTAssertTrue(isSame, @"加解密结果应该相同");
    }
}

/**
 * 测试 sm4 加密耗时
 */
- (void)testPerformanceSm4Encrypt {
    NSString *plainText = @"123456";
    NSString *sm4Key = @"PfM1_Fv.Zd11Enc)";
    // 加密耗时
    [self measureBlock:^{
        NSString *encryptStr = [GMSm4Utils encrypt:plainText Key:sm4Key];
        XCTAssertNotNil(encryptStr, @"加密字符串不为空");
    }];
}

/**
 * 测试 sm4 解密耗时
 */
- (void)testPerformanceSm4Decrypt {
    NSString *encryptStr = @"F4A4AD144E539A430FA92946B00BEA0510";
    NSString *sm4Key = @"PfM1_Fv.Zd11Enc)";
    // 解密耗时
    [self measureBlock:^{
        NSString *decryptStr = [GMSm4Utils decrypt:encryptStr Key:sm4Key];
        XCTAssertNotNil(decryptStr, @"解密结果不为空");
    }];
}


///MARK: - sm2

/**
 * 测试 sm4 出现空的情况
 */
- (void)testSm2Null {
    NSString *strNull = nil;
    NSString *strLenZero = @"";
    
    // 加密
    NSString *encryptNullStr = [GMSm2Utils encrypt:strNull PublicKey:gPubkey];
    XCTAssertNil(encryptNullStr, @"加密字符串应为空");
    NSString *encryptLenZeroStr = [GMSm2Utils encrypt:strLenZero PublicKey:gPubkey];
    XCTAssertNil(encryptLenZeroStr, @"加密字符串应为空");
    NSString *encryptNullKey = [GMSm2Utils encrypt:@"123456" PublicKey:@""];
    XCTAssertNil(encryptNullKey, @"加密字符串应为空");
    
    // 解密
    NSString *decryptNullStr = [GMSm2Utils decrypt:strNull PrivateKey:gPrivkey];
    XCTAssertNil(decryptNullStr, @"解密字符串应为空");
    NSString *decryptLenZeroStr = [GMSm2Utils decrypt:strLenZero PrivateKey:gPrivkey];
    XCTAssertNil(decryptLenZeroStr, @"解密字符串应为空");
    NSString *decryptNullKey = [GMSm2Utils decrypt:@"123456" PrivateKey:@""];
    XCTAssertNil(decryptNullKey, @"解密字符串应为空");
    
    // 解码
    NSString *decodeNullStr = [GMSm2Utils decodeWithASN1:strNull];
    XCTAssertNil(decodeNullStr, @"解码字符串应为空");
    NSString *decodeLenZeroStr = [GMSm2Utils decodeWithASN1:strLenZero];
    XCTAssertNil(decodeLenZeroStr, @"解码字符串应为空");
    
    // 编码
    NSString *encodeNullStr = [GMSm2Utils encodeWithASN1:strNull];
    XCTAssertNil(encodeNullStr, @"编码字符串应为空");
    NSString *encodeLenZeroStr = [GMSm2Utils encodeWithASN1:strLenZero];
    XCTAssertNil(encodeLenZeroStr, @"编码字符串应为空");
}

/**
 * 测试大量生产 sm2 公私钥
 */
- (void)testSm2CreateKeys {
    for (NSInteger i = 0; i < 10000; i++) {
        // 生成一对新的公私钥
        NSArray *newKey = [GMSm2Utils createPublicAndPrivateKey];
        XCTAssertNotNil(newKey[0], @"生成公钥不为空");
        XCTAssertNotNil(newKey[1], @"生成私钥不为空");
    }
}

/**
 * 测试多次 ASN1 编码结果相同
 */
- (void)testSm2EncodeDecodeASN1 {
    int randLen = arc4random_uniform((int)10000);
    NSString *plainText = [self randomEn:randLen];
    XCTAssertNotNil(plainText, @"生成字符串不为空");
    NSString *encryptStr = [GMSm2Utils encrypt:plainText PublicKey:gPubkey];
    XCTAssertNotNil(encryptStr, @"加密字符串不为空");
    
    NSString *decodeStr = [GMSm2Utils decodeWithASN1:encryptStr];
    XCTAssertNotNil(decodeStr, @"ASN1解码后字符串不为空");
    for (NSInteger i = 0; i < 10000; i++) {
        NSString *newDecodeStr = [GMSm2Utils decodeWithASN1:encryptStr];
        BOOL isSame_decode = [newDecodeStr isEqualToString:decodeStr];
        XCTAssertTrue(isSame_decode, @"多次解码应该相同");
    }
    
    NSString *encodeStr = [GMSm2Utils encodeWithASN1:decodeStr];
    XCTAssertNotNil(encodeStr, @"ASN1编码后字符串不为空");
    for (NSInteger i = 0; i < 10000; i++) {
        NSString *newEncodeStr = [GMSm2Utils encodeWithASN1:decodeStr];
        BOOL isSame_encode = [newEncodeStr isEqualToString:encodeStr];
        XCTAssertTrue(isSame_encode, @"多次编码应该相同");
    }
    
    BOOL isSame_Ctext = [encodeStr isEqualToString:encryptStr];
    XCTAssertTrue(isSame_Ctext, @"编码后和原始密文相同");
    
    NSString *decryptStr = [GMSm2Utils decrypt:encryptStr PrivateKey:gPrivkey];
    XCTAssertNotNil(decryptStr, @"解密结果不为空");
    BOOL isSame_plain = [decryptStr isEqualToString:plainText];
    XCTAssertTrue(isSame_plain, @"加解密结果应该相同");
}

/**
 * 测试大量包含 ASN1 编解码的加解密无错误出现
 */
- (void)testSm2EncryptDecryptWithASN1 {
    for (NSInteger i = 0; i < 10000; i++) {
        int randLen = arc4random_uniform((int)10000);
        NSString *plainText = [self randomEn:randLen];
        XCTAssertNotNil(plainText, @"生成字符串不为空");
        
        NSString *encryptStr = [GMSm2Utils encrypt:plainText PublicKey:gPubkey];
        XCTAssertNotNil(encryptStr, @"加密字符串不为空");
        
        NSString *decodeStr = [GMSm2Utils decodeWithASN1:encryptStr];
        XCTAssertNotNil(decodeStr, @"ASN1解码后字符串不为空");
        NSString *encodeStr = [GMSm2Utils encodeWithASN1:decodeStr];
        XCTAssertNotNil(encodeStr, @"ASN1编码后字符串不为空");
        
        NSString *decryptStr = [GMSm2Utils decrypt:encryptStr PrivateKey:gPrivkey];
        XCTAssertNotNil(decryptStr, @"解密结果不为空");
        BOOL isSame_plain = [decryptStr isEqualToString:plainText];
        XCTAssertTrue(isSame_plain, @"加解密结果应该相同");
    }
}

/**
 * 测试大量加解密英文字符串无错误
 */
- (void)testSm2En {
    for (NSInteger i = 0; i < 10000; i++) {
        int randLen = arc4random_uniform((int)10000);
        NSString *plainText = [self randomEn:randLen];
        XCTAssertNotNil(plainText, @"生成字符串不为空");
        
        NSString *encryptStr = [GMSm2Utils encrypt:plainText PublicKey:gPubkey];
        XCTAssertNotNil(encryptStr, @"加密字符串不为空");
        
        NSString *decryptStr = [GMSm2Utils decrypt:encryptStr PrivateKey:gPrivkey];
        XCTAssertNotNil(decryptStr, @"解密结果不为空");
        
        BOOL isSame = [decryptStr isEqualToString:plainText];
        XCTAssertTrue(isSame, @"加解密结果应该相同");
    }
}

/**
 * 测试大量加密中文字符串无错误
 */
- (void)testSm2Zh {
    for (NSInteger i = 0; i < 1000; i++) {
        int randLen = arc4random_uniform((int)1000);
        NSString *plainText = [self randomZh:randLen];
        XCTAssertNotNil(plainText, @"生成字符串不为空");
        NSString *hexStr = [GMCodecUtils stringToHex:plainText];
        
        NSString *encryptStr = [GMSm2Utils encrypt:hexStr PublicKey:gPubkey];
        XCTAssertNotNil(encryptStr, @"加密字符串不为空");
        
        NSString *decryptStr = [GMSm2Utils decrypt:encryptStr PrivateKey:gPrivkey];
        XCTAssertNotNil(decryptStr, @"解密结果不为空");
        
        BOOL isSame = [decryptStr isEqualToString:hexStr];
        XCTAssertTrue(isSame, @"加解密结果应该相同");
        
        NSString *orginStr = [GMCodecUtils hexToString:hexStr];
        BOOL isSameHex = [plainText isEqualToString:orginStr];
        XCTAssertTrue(isSameHex, @"加解密结果应该相同");
    }
}

/**
 * 测试大量加密中英文混合字符串无错误
 */
- (void)testSm2ZhEn {
    for (NSInteger i = 0; i < 1000; i++) {
        int randLen = arc4random_uniform((int)1000);
        NSString *plainText = [self randomZhEnString:randLen];
        XCTAssertNotNil(plainText, @"生成字符串不为空");
        NSString *hexStr = [GMCodecUtils stringToHex:plainText];
        
        NSString *encryptStr = [GMSm2Utils encrypt:hexStr PublicKey:gPubkey];
        XCTAssertNotNil(encryptStr, @"加密字符串不为空");
        
        NSString *decryptStr = [GMSm2Utils decrypt:encryptStr PrivateKey:gPrivkey];
        XCTAssertNotNil(decryptStr, @"解密结果不为空");
        
        BOOL isSame = [decryptStr isEqualToString:hexStr];
        XCTAssertTrue(isSame, @"加解密结果应该相同");
    }
}

/**
 * 测试加密耗时
 */
- (void)testPerformanceSm2Encrypt {
    // 加密耗时
    [self measureBlock:^{
        NSString *plainText = @"123456";
        NSString *encryptStr = [GMSm2Utils encrypt:plainText PublicKey:gPubkey];
        XCTAssertNotNil(encryptStr, @"加密字符串不为空");
    }];
}

/**
 * 测试解密耗时
 */
- (void)testPerformanceSm2Decrypt {
    NSString *ctext = @"30:6F:02:21:00:D4:F1:B3:2E:29:50:1E:94:44:46:7F:9E:2E:51:36:1E:91:F5:EC:0B:96:F3:34:94:E5:50:82:9F:00:CC:B5:B7:02:20:04:42:83:DF:76:21:B2:9C:EB:7F:64:8B:B4:7A:3C:BF:FE:97:47:E4:D2:BD:47:44:C9:DA:1D:68:12:23:43:D6:04:20:45:F6:AB:54:22:71:63:93:95:3B:58:E3:8D:90:32:B7:A1:D8:76:2B:B8:16:F2:6A:83:51:77:44:2D:28:2C:D2:04:06:62:9F:38:6A:77:76";
    // 解密耗时
    [self measureBlock:^{
        NSString *decryptStr = [GMSm2Utils decrypt:ctext PrivateKey:gPrivkey];
        XCTAssertNotNil(decryptStr, @"解密结果不为空");
    }];
}

/**
 * 测试 ASN1 编码耗时
 */
- (void)testPerformanceSm2ASN1Encode {
    NSString *dCodeCtext = @"D4F1B32E29501E9444467F9E2E51361E91F5EC0B96F33494E550829F00CCB5B7044283DF7621B29CEB7F648BB47A3CBFFE9747E4D2BD4744C9DA1D68122343D645F6AB5422716393953B58E38D9032B7A1D8762BB816F26A835177442D282CD2629F386A7776";
    
    // 编码耗时
    [self measureBlock:^{
        NSString *encodeStr = [GMSm2Utils encodeWithASN1:dCodeCtext];
        XCTAssertNotNil(encodeStr, @"ASN1编码后字符串不为空");
    }];
}

/**
 * 测试 ASN1 解码耗时
 */
- (void)testPerformanceSm2ASN1Decode {
    NSString *ctext = @"30:6F:02:21:00:D4:F1:B3:2E:29:50:1E:94:44:46:7F:9E:2E:51:36:1E:91:F5:EC:0B:96:F3:34:94:E5:50:82:9F:00:CC:B5:B7:02:20:04:42:83:DF:76:21:B2:9C:EB:7F:64:8B:B4:7A:3C:BF:FE:97:47:E4:D2:BD:47:44:C9:DA:1D:68:12:23:43:D6:04:20:45:F6:AB:54:22:71:63:93:95:3B:58:E3:8D:90:32:B7:A1:D8:76:2B:B8:16:F2:6A:83:51:77:44:2D:28:2C:D2:04:06:62:9F:38:6A:77:76";
    // 解码耗时
    [self measureBlock:^{
        NSString *decodeStr = [GMSm2Utils decodeWithASN1:ctext];
        XCTAssertNotNil(decodeStr, @"ASN1解码后字符串不为空");
    }];
}

///MARK: - tool

// 生成中英文混合字符串
- (NSString *)randomZhEnString:(NSInteger)maxLength{
    int randLen = arc4random_uniform((int)maxLength);
    randLen = randLen > 1 ? randLen : 10;
    NSMutableString *mstr = [NSMutableString stringWithCapacity:randLen];
    for (NSInteger i = 0; i < randLen - 1; i+=2) {
        int randZhEn = arc4random_uniform(2);
        if (randZhEn % 2 == 0) {
            NSString *zh = [self randomZh:2];
            [mstr appendString:zh];
        }else{
            NSString *en = [self randomEn:2];
            [mstr appendString:en];
        }
    }
    return mstr.copy;
}

// 随机生成ascii符串(由大小写字母、数字组成)
- (NSString *)randomEn:(NSInteger)len {
    len = len > 1 ? len : 10;
    // 33 至 126
    char ch[len];
    for (NSInteger index=0; index<len; index++) {
        int num = arc4random_uniform(93)+33;
        ch[index] = num;
    }
    return [[NSString alloc] initWithBytes:ch length:len encoding:NSUTF8StringEncoding];
}

// 随机生成汉字字符串
-(NSString *)randomZh:(NSInteger)len{
    len = len > 1 ? len : 10;
    NSMutableString *mStr = [NSMutableString string];
    for (NSInteger i = 0; i < len; i++) {
        NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        
        NSInteger randomH = 0xA1+arc4random()%(0xFE - 0xA1+1);
        
        NSInteger randomL = 0xB0+arc4random()%(0xF7 - 0xB0+1);
        
        NSInteger number = (randomH<<8)+randomL;
        NSData *data = [NSData dataWithBytes:&number length:2];
        
        NSString *string = [[NSString alloc] initWithData:data encoding:gbkEncoding];
        [mStr appendString:string];
    }
    return mStr.copy;
}


@end

