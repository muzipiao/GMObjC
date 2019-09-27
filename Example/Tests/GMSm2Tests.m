//
//  GMSm2Tests.m
//  GMObjC_Tests
//
//  Created by lifei on 2019/8/18.
//  Copyright © 2019 lifei. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface GMSm2Tests : GMBaseTests

@property (nonatomic, copy) NSString *userID;  // SM2 签名时用户ID

@end

@implementation GMSm2Tests

- (void)setUp {
    [super setUp];
    self.userID = @"lifei_zdjl@126.com";
}

- (void)tearDown {
    self.userID = nil;
    [super tearDown];
}

/**
 * 测试 sm2 出现空的情况
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
    
    // ASN1 解码
    NSString *decodeNullStr = [GMSm2Utils decodeWithASN1:strNull];
    XCTAssertNil(decodeNullStr, @"解码字符串应为空");
    NSString *decodeLenZeroStr = [GMSm2Utils decodeWithASN1:strLenZero];
    XCTAssertNil(decodeLenZeroStr, @"解码字符串应为空");
    
    // ASN1 编码
    NSString *encodeNullStr = [GMSm2Utils encodeWithASN1:strNull];
    XCTAssertNil(encodeNullStr, @"编码字符串应为空");
    NSString *encodeLenZeroStr = [GMSm2Utils encodeWithASN1:strLenZero];
    XCTAssertNil(encodeLenZeroStr, @"编码字符串应为空");
}

/**
 * 测试 sm2 签名出现空的情况
 */
- (void)testSm2SignNull {
    NSString *strNull = nil;
    NSString *strZero = @"";
    // 签名为空
    NSString *userID = self.userID;
    
    NSString *signNullStr = [GMSm2Utils sign:strNull PrivateKey:gPrivkey UserID:userID];
    XCTAssertNil(signNullStr, @"签名字符串应为空");
    NSString *signZeroStr = [GMSm2Utils sign:strZero PrivateKey:gPrivkey UserID:userID];
    XCTAssertNil(signZeroStr, @"签名字符串应为空");
    
    // 签名私钥为空
    NSString *plaintext = @"123456";
    NSString *signPriKeyNull = [GMSm2Utils sign:plaintext PrivateKey:strNull UserID:userID];
    XCTAssertNil(signPriKeyNull, @"签名字符串应为空");
    NSString *signPriKeyZero = [GMSm2Utils sign:plaintext PrivateKey:strZero UserID:userID];
    XCTAssertNil(signPriKeyZero, @"签名字符串应为空");
    
    // 签名的 UserID 为空
    NSString *signUserNull = [GMSm2Utils sign:plaintext PrivateKey:gPrivkey UserID:strNull];
    XCTAssertNotNil(signUserNull, @"签名字符串不应为空");
    NSString *signUserZero = [GMSm2Utils sign:plaintext PrivateKey:gPrivkey UserID:strZero];
    XCTAssertNotNil(signUserZero, @"签名字符串不应为空");
    
    // 生成一个签名
    NSString *signNormal = [GMSm2Utils sign:plaintext PrivateKey:gPrivkey UserID:userID];
    // 测试明文为空
    BOOL isMsgNullOK = [GMSm2Utils verify:strNull Sign:signNormal PublicKey:gPubkey UserID:userID];
    BOOL isMsgZeroOK = [GMSm2Utils verify:strZero Sign:signNormal PublicKey:gPubkey UserID:userID];
    XCTAssertFalse(isMsgNullOK, @"明文为空验证不通过");
    XCTAssertFalse(isMsgZeroOK, @"明文为空验证不通过");
    
    // 测试签名为空
    BOOL isSignNullOK = [GMSm2Utils verify:plaintext Sign:strNull PublicKey:gPubkey UserID:userID];
    BOOL isSignZeroOK = [GMSm2Utils verify:plaintext Sign:strZero PublicKey:gPubkey UserID:userID];
    XCTAssertFalse(isSignNullOK, @"签名为空验证不通过");
    XCTAssertFalse(isSignZeroOK, @"签名为空验证不通过");
    
    // 测试公钥为空
    BOOL isPubNullOK = [GMSm2Utils verify:plaintext Sign:signNormal PublicKey:strNull UserID:userID];
    BOOL isPubZeroOK = [GMSm2Utils verify:plaintext Sign:signNormal PublicKey:strZero UserID:userID];
    XCTAssertFalse(isPubNullOK, @"公钥为空验证不通过");
    XCTAssertFalse(isPubZeroOK, @"公钥为空验证不通过");
    
    // 测试用户ID为空，不同用户
    BOOL isUserNullOK = [GMSm2Utils verify:plaintext Sign:signNormal PublicKey:strNull UserID:strNull];
    BOOL isUserZeroOK = [GMSm2Utils verify:plaintext Sign:signNormal PublicKey:strZero UserID:strZero];
    XCTAssertFalse(isUserNullOK, @"用户 ID 不同验证不通过");
    XCTAssertFalse(isUserZeroOK, @"用户 ID 不同验证不通过");
}

- (void)testErrorKey {
    NSString *plaintext = @"123456";
    NSString *pubErrorKey = @"0408E3FFF9505BCFAF9307E888888999999B3936437A870407EA3D97886BAFBC9C624537215DE9507BC0E2DD276CF74695C924F28E9004CDE4678F63D698";
    NSString *privErrorKey = @"6666662B9FE24AB196305F82E647616C3A3694441FB3422E7838E24DEAE";
    
    NSString *enTrueStr = [GMSm2Utils encrypt:plaintext PublicKey:gPubkey];
    XCTAssertNotNil(enTrueStr, @"加密字符串不为空");

    NSString *signTrueStr = [GMSm2Utils sign:plaintext PrivateKey:gPrivkey UserID:nil];
    XCTAssertNotNil(signTrueStr, @"签名结果不为为空");
    
    NSString *enWithErrorPubKey = [GMSm2Utils encrypt:plaintext PublicKey:pubErrorKey];
    XCTAssertNil(enWithErrorPubKey, @"加密结果为空");
    
    NSString *deWithErrorPri = [GMSm2Utils decrypt:enTrueStr PrivateKey:privErrorKey];
    XCTAssertNil(deWithErrorPri, @"解密结果为空");
    
    NSString *signWithErrorPriv = [GMSm2Utils sign:plaintext PrivateKey:privErrorKey UserID:nil];
    BOOL isOKErrorPub = [GMSm2Utils verify:plaintext Sign:signTrueStr PublicKey:pubErrorKey UserID:nil];
    BOOL isOKErrorSign = [GMSm2Utils verify:plaintext Sign:signWithErrorPriv PublicKey:pubErrorKey UserID:nil];
    XCTAssertFalse(isOKErrorPub, @"签名结果应该校验失败");
    XCTAssertFalse(isOKErrorSign, @"签名结果应该校验失败");
}

/**
 * 测试大量生产 sm2 公私钥
 */
- (void)testSm2CreateKeys {
    for (NSInteger i = 0; i < 1000; i++) {
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
    NSString *plaintext = [self randomEn:randLen];
    XCTAssertNotNil(plaintext, @"生成字符串不为空");
    NSString *encryptStr = [GMSm2Utils encrypt:plaintext PublicKey:gPubkey];
    XCTAssertNotNil(encryptStr, @"加密字符串不为空");
    
    NSString *decodeStr = [GMSm2Utils decodeWithASN1:encryptStr];
    XCTAssertNotNil(decodeStr, @"ASN1解码后字符串不为空");
    for (NSInteger i = 0; i < 1000; i++) {
        NSString *newDecodeStr = [GMSm2Utils decodeWithASN1:encryptStr];
        BOOL isSame_decode = [newDecodeStr isEqualToString:decodeStr];
        XCTAssertTrue(isSame_decode, @"多次解码应该相同");
    }
    
    NSString *encodeStr = [GMSm2Utils encodeWithASN1:decodeStr];
    XCTAssertNotNil(encodeStr, @"ASN1编码后字符串不为空");
    for (NSInteger i = 0; i < 1000; i++) {
        NSString *newEncodeStr = [GMSm2Utils encodeWithASN1:decodeStr];
        BOOL isSame_encode = [newEncodeStr isEqualToString:encodeStr];
        XCTAssertTrue(isSame_encode, @"多次编码应该相同");
    }
    
    BOOL isSame_Ctext = [encodeStr isEqualToString:encryptStr];
    XCTAssertTrue(isSame_Ctext, @"编码后和原始密文相同");
    
    NSString *decryptStr = [GMSm2Utils decrypt:encryptStr PrivateKey:gPrivkey];
    XCTAssertNotNil(decryptStr, @"解密结果不为空");
    BOOL isSame_plain = [decryptStr isEqualToString:plaintext];
    XCTAssertTrue(isSame_plain, @"加解密结果应该相同");
}

/**
 * 测试大量包含 ASN1 编解码的加解密无错误出现
 */
- (void)testSm2EncryptDecryptWithASN1 {
    for (NSInteger i = 0; i < 1000; i++) {
        int randLen = arc4random_uniform((int)10000);
        NSString *plaintext = [self randomEn:randLen];
        XCTAssertNotNil(plaintext, @"生成字符串不为空");
        
        NSString *encryptStr = [GMSm2Utils encrypt:plaintext PublicKey:gPubkey];
        XCTAssertNotNil(encryptStr, @"加密字符串不为空");
        
        NSString *decodeStr = [GMSm2Utils decodeWithASN1:encryptStr];
        XCTAssertNotNil(decodeStr, @"ASN1解码后字符串不为空");
        NSString *encodeStr = [GMSm2Utils encodeWithASN1:decodeStr];
        XCTAssertNotNil(encodeStr, @"ASN1编码后字符串不为空");
        
        NSString *decryptStr = [GMSm2Utils decrypt:encryptStr PrivateKey:gPrivkey];
        XCTAssertNotNil(decryptStr, @"解密结果不为空");
        BOOL isSame_plain = [decryptStr isEqualToString:plaintext];
        XCTAssertTrue(isSame_plain, @"加解密结果应该相同");
    }
}

/**
 * 测试大量加解密字符串无错误
 */
- (void)testSm2Str {
    for (NSInteger i = 0; i < 3000; i++) {
        int randLen = arc4random_uniform((int)10000);
        NSString *plaintext = nil;
        if (i<1000) {
            plaintext = [self randomEn:randLen]; // 数字英文
        }else if (i>=1000 && i< 2000){
            plaintext = [self randomZh:randLen]; // 中文字符
        }else{
            plaintext = [self randomZhEnString:randLen]; //中英文混合
        }
        XCTAssertNotNil(plaintext, @"生成字符串不为空");
        
        NSString *encryptStr = [GMSm2Utils encrypt:plaintext PublicKey:gPubkey];
        XCTAssertNotNil(encryptStr, @"加密字符串不为空");
        
        NSString *decryptStr = [GMSm2Utils decrypt:encryptStr PrivateKey:gPrivkey];
        XCTAssertNotNil(decryptStr, @"解密结果不为空");
        
        BOOL isSame = [decryptStr isEqualToString:plaintext];
        XCTAssertTrue(isSame, @"加解密结果应该相同");
    }
}

- (void)testSm2SignVerify {
    NSString *userID = @"lifei_zdjl@126.com";
    for (NSInteger i = 0; i < 1000; i++) {
        int randLen = arc4random_uniform((int)1000);
        NSString *plaintext = [self randomZhEnString:randLen];
        XCTAssertNotNil(plaintext, @"生成字符串不为空");
        
        // 随机 UserID
        NSString *tempUserID = userID;
        int randUser = arc4random_uniform((int)1000);
        if (randUser % 2 == 0) {
            tempUserID = nil;
        }else if (randUser % 5 == 0){
            tempUserID = @"";
        }
        
        NSString *signStr = [GMSm2Utils sign:plaintext PrivateKey:gPrivkey UserID:tempUserID];
        XCTAssertNotNil(signStr, @"签名结果不为空");
        
        BOOL isOK = [GMSm2Utils verify:plaintext Sign:signStr PublicKey:gPubkey UserID:tempUserID];
        XCTAssertTrue(isOK, @"签名结果应该校验成功");
        
        NSString *derStr = [GMSm2Utils encodeWithDer:signStr];
        XCTAssertNotNil(derStr, @"Der 签名结果不为空");
        
        NSString *orginSign = [GMSm2Utils decodeWithDer:derStr];
        XCTAssertNotNil(orginSign, @"Der 解析结果不为空");
        
        BOOL isSame = [signStr isEqualToString:orginSign];
        XCTAssertTrue(isSame, @"Der 编码解码结果应该相同");
    }
}

/**
 * 测试加密耗时
 */
- (void)testPerformanceSm2Encrypt {
    // 加密耗时
    [self measureBlock:^{
        NSString *plaintext = @"123456";
        NSString *encryptStr = [GMSm2Utils encrypt:plaintext PublicKey:gPubkey];
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

@end
