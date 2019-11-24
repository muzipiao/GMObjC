//
//  GMSm2Tests.m
//  GMObjC_Tests
//
//  Created by lifei on 2019/8/18.
//  Copyright © 2019 lifei. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface GMSm2Tests : GMBaseTests

@end

@implementation GMSm2Tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

/**
 * 测试 sm2 出现空的情况
 */
- (void)testSm2Null {
    NSString *strNull = nil;
    NSString *strLenZero = @"";
    
    // 加密
    NSString *encryptNullStr = [GMSm2Utils encryptText:strNull publicKey:GMPubKey];
    XCTAssertNil(encryptNullStr, @"加密字符串应为空");
    NSString *encryptLenZeroStr = [GMSm2Utils encryptText:strLenZero publicKey:GMPubKey];
    XCTAssertNil(encryptLenZeroStr, @"加密字符串应为空");
    NSString *encryptNullKey = [GMSm2Utils encryptText:@"123456" publicKey:@""];
    XCTAssertNil(encryptNullKey, @"加密字符串应为空");
    
    // 解密
    NSString *decryptNullStr = [GMSm2Utils decryptToText:strNull privateKey:GMPriKey];
    XCTAssertNil(decryptNullStr, @"解密字符串应为空");
    NSString *decryptLenZeroStr = [GMSm2Utils decryptToText:strLenZero privateKey:GMPriKey];
    XCTAssertNil(decryptLenZeroStr, @"解密字符串应为空");
    NSString *decryptNullKey = [GMSm2Utils decryptToText:@"123456" privateKey:@""];
    XCTAssertNil(decryptNullKey, @"解密字符串应为空");
    
    // ASN1 解码
    NSString *decodeNullStr = [GMSm2Utils asn1DecodeToC1C3C2:strNull];
    XCTAssertNil(decodeNullStr, @"解码字符串应为空");
    NSString *decodeLenZeroStr = [GMSm2Utils asn1DecodeToC1C3C2:strLenZero];
    XCTAssertNil(decodeLenZeroStr, @"解码字符串应为空");
    
    // ASN1 编码
    NSString *encodeNullStr = [GMSm2Utils asn1EncodeWithC1C3C2:strNull];
    XCTAssertNil(encodeNullStr, @"编码字符串应为空");
    NSString *encodeLenZeroStr = [GMSm2Utils asn1EncodeWithC1C3C2:strLenZero];
    XCTAssertNil(encodeLenZeroStr, @"编码字符串应为空");
}

/**
 * 测试 sm2 签名出现空的情况
 */
- (void)testSm2SignNull {
    NSString *strNull = nil;
    NSString *strZero = @"";
    // 签名为空
    NSString *userID = GMTestUserID;
    
    NSString *signNullStr = [GMSm2Utils signText:strNull privateKey:GMPriKey userID:userID];
    XCTAssertNil(signNullStr, @"签名字符串应为空");
    NSString *signZeroStr = [GMSm2Utils signText:strZero privateKey:GMPriKey userID:userID];
    XCTAssertNil(signZeroStr, @"签名字符串应为空");
    
    // 签名私钥为空
    NSString *plaintext = @"123456";
    NSString *signPriKeyNull = [GMSm2Utils signText:plaintext privateKey:strNull userID:userID];
    XCTAssertNil(signPriKeyNull, @"签名字符串应为空");
    NSString *signPriKeyZero = [GMSm2Utils signText:plaintext privateKey:strZero userID:userID];
    XCTAssertNil(signPriKeyZero, @"签名字符串应为空");
    
    // 签名的 UserID 为空
    NSString *signUserNull = [GMSm2Utils signText:plaintext privateKey:GMPriKey userID:strNull];
    XCTAssertNotNil(signUserNull, @"签名字符串不应为空");
    NSString *signUserZero = [GMSm2Utils signText:plaintext privateKey:GMPriKey userID:strZero];
    XCTAssertNotNil(signUserZero, @"签名字符串不应为空");
    
    // 生成一个签名
    NSString *signNormal = [GMSm2Utils signText:plaintext privateKey:GMPriKey userID:userID];
    // 测试明文为空
    BOOL isMsgNullOK = [GMSm2Utils verifyText:strNull signRS:signNormal publicKey:GMPubKey userID:userID];
    BOOL isMsgZeroOK = [GMSm2Utils verifyText:strZero signRS:signNormal publicKey:GMPubKey userID:userID];
    XCTAssertFalse(isMsgNullOK, @"明文为空验证不通过");
    XCTAssertFalse(isMsgZeroOK, @"明文为空验证不通过");
    
    // 测试签名为空
    BOOL isSignNullOK = [GMSm2Utils verifyText:plaintext signRS:strNull publicKey:GMPubKey userID:userID];
    BOOL isSignZeroOK = [GMSm2Utils verifyText:plaintext signRS:strZero publicKey:GMPubKey userID:userID];
    XCTAssertFalse(isSignNullOK, @"签名为空验证不通过");
    XCTAssertFalse(isSignZeroOK, @"签名为空验证不通过");
    
    // 测试公钥为空
    BOOL isPubNullOK = [GMSm2Utils verifyText:plaintext signRS:signNormal publicKey:strNull userID:userID];
    BOOL isPubZeroOK = [GMSm2Utils verifyText:plaintext signRS:signNormal publicKey:strZero userID:userID];
    XCTAssertFalse(isPubNullOK, @"公钥为空验证不通过");
    XCTAssertFalse(isPubZeroOK, @"公钥为空验证不通过");
    
    // 测试用户ID为空，不同用户
    BOOL isUserNullOK = [GMSm2Utils verifyText:plaintext signRS:signNormal publicKey:strNull userID:strNull];
    BOOL isUserZeroOK = [GMSm2Utils verifyText:plaintext signRS:signNormal publicKey:strZero userID:strZero];
    XCTAssertFalse(isUserNullOK, @"用户 ID 不同验证不通过");
    XCTAssertFalse(isUserZeroOK, @"用户 ID 不同验证不通过");
}


/// 测试 ECDH 密钥协商出现空值情况
- (void)testECDHNull {
    NSString *strNull = nil;
    NSString *strZero = @"";
    
    // 测试公钥为空
    NSString *ecdhNullPub = [GMSm2Utils computeECDH:strNull privateKey:GMPriKey];
    XCTAssertNil(ecdhNullPub, @"协商密钥应为空");
    NSString *ecdhZeroPub = [GMSm2Utils computeECDH:strZero privateKey:GMPriKey];
    XCTAssertNil(ecdhZeroPub, @"协商密钥应为空");
    
    // 测试私钥为空
    NSString *ecdhNullPri = [GMSm2Utils computeECDH:GMPubKey privateKey:strNull];
    XCTAssertNil(ecdhNullPri, @"协商密钥应为空");
    NSString *ecdhZeroPri = [GMSm2Utils computeECDH:GMPubKey privateKey:strZero];
    XCTAssertNil(ecdhZeroPri, @"协商密钥应为空");
    
    // 测试公私钥都为空情况
    NSString *ecdhNullKey = [GMSm2Utils computeECDH:strNull privateKey:strNull];
    XCTAssertNil(ecdhNullKey, @"协商密钥应为空");
    NSString *ecdhZeroKey = [GMSm2Utils computeECDH:strZero privateKey:strZero];
    XCTAssertNil(ecdhZeroKey, @"协商密钥应为空");
}

/// 测试 ECDH 密钥协商
- (void)testECDH {
    for (NSInteger i = 0; i < 1000; i++) {
        NSArray *clientKey = [GMSm2Utils createKeyPair];
        NSString *cPubKey = clientKey[0];
        NSString *cPriKey = clientKey[1];
        
        NSArray *serverKey = [GMSm2Utils createKeyPair];
        NSString *sPubKey = serverKey[0];
        NSString *sPriKey = serverKey[1];
        
        XCTAssertNotNil(cPubKey, @"客户端公钥不为空");
        XCTAssertNotNil(cPriKey, @"客户端私钥不为空");
        XCTAssertNotNil(sPubKey, @"服务端公钥不为空");
        XCTAssertNotNil(sPriKey, @"服务端私钥不为空");
        
        // 客户端client从服务端server获取公钥sPubKey，client协商出32字节对称密钥clientECDH，转HEX为64字节
        NSString *clientECDH = [GMSm2Utils computeECDH:sPubKey privateKey:cPriKey];
        XCTAssertTrue(clientECDH.length==64, @"client 协商出 32 字节对称密钥");
        // 客户端client将公钥cPubKey发送给服务端server，server协商出32字节对称密钥serverECDH，转HEX为64字节
        NSString *serverECDH = [GMSm2Utils computeECDH:cPubKey privateKey:sPriKey];
        XCTAssertTrue(serverECDH.length==64, @"server 协商出 32 字节对称密钥");
        
        BOOL isSameECDH = [clientECDH isEqualToString:serverECDH];
        XCTAssertTrue(isSameECDH, @"ECDH 密钥协商应相同");
    }
}

/// 测试公私钥错误的情况下
- (void)testErrorKey {
    NSString *plaintext = @"123456";
    NSString *pubErrorKey = @"0408E3FFF9505BCFAF9307E888888999999B3936437A870407EA3D97886BAF"
                             "BC9C624537215DE9507BC0E2DD276CF74695C924F28E9004CDE4678F63D698";
    NSString *privErrorKey = @"6666662B9FE24AB196305F82E647616C3A3694441FB3422E7838E24DEAE";
    
    NSString *enTrueStr = [GMSm2Utils encryptText:plaintext publicKey:GMPubKey];
    XCTAssertNotNil(enTrueStr, @"加密字符串不为空");

    NSString *signTrueStr = [GMSm2Utils signText:plaintext privateKey:GMPriKey userID:nil];
    XCTAssertNotNil(signTrueStr, @"签名结果不为为空");
    
    NSString *enWithErrorPubKey = [GMSm2Utils encryptText:plaintext publicKey:pubErrorKey];
    XCTAssertTrue(enWithErrorPubKey.length == 0, @"加密结果为空");
    
    NSString *deWithErrorPri = [GMSm2Utils decryptToText:enTrueStr privateKey:privErrorKey];
    XCTAssertTrue(deWithErrorPri.length == 0, @"解密结果为空");
    
    NSString *signWithErrorPriv = [GMSm2Utils signText:plaintext privateKey:privErrorKey userID:nil];
    BOOL isOKErrorPub = [GMSm2Utils verifyText:plaintext signRS:signTrueStr publicKey:pubErrorKey userID:nil];
    BOOL isOKErrorSign = [GMSm2Utils verifyText:plaintext signRS:signWithErrorPriv publicKey:pubErrorKey userID:nil];
    XCTAssertFalse(isOKErrorPub, @"签名结果应该校验失败");
    XCTAssertFalse(isOKErrorSign, @"签名结果应该校验失败");
}

/**
 * 测试大量生产 sm2 公私钥
 */
- (void)testSm2CreateKeys {
    for (NSInteger i = 0; i < 1000; i++) {
        // 生成一对新的公私钥
        NSArray *newKey = [GMSm2Utils createKeyPair];
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
    NSString *encryptStr = [GMSm2Utils encryptText:plaintext publicKey:GMPubKey];
    XCTAssertNotNil(encryptStr, @"加密字符串不为空");
    
    NSString *decodeStr = [GMSm2Utils asn1DecodeToC1C3C2:encryptStr];
    XCTAssertNotNil(decodeStr, @"ASN1解码后字符串不为空");
    for (NSInteger i = 0; i < 1000; i++) {
        NSString *newDecodeStr = [GMSm2Utils asn1DecodeToC1C3C2:encryptStr];
        BOOL isSame_decode = [newDecodeStr isEqualToString:decodeStr];
        XCTAssertTrue(isSame_decode, @"多次解码应该相同");
    }
    
    NSString *encodeStr = [GMSm2Utils asn1EncodeWithC1C3C2:decodeStr];
    XCTAssertNotNil(encodeStr, @"ASN1编码后字符串不为空");
    for (NSInteger i = 0; i < 1000; i++) {
        NSString *newEncodeStr = [GMSm2Utils asn1EncodeWithC1C3C2:decodeStr];
        BOOL isSame_encode = [newEncodeStr isEqualToString:encodeStr];
        XCTAssertTrue(isSame_encode, @"多次编码应该相同");
    }
    BOOL isSame_Ctext = [encodeStr isEqualToString:encryptStr];
    XCTAssertTrue(isSame_Ctext, @"编码后和原始密文相同");
    
    NSString *decryptStr = [GMSm2Utils decryptToText:encryptStr privateKey:GMPriKey];
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
        
        NSString *encryptStr = [GMSm2Utils encryptText:plaintext publicKey:GMPubKey];
        XCTAssertNotNil(encryptStr, @"加密字符串不为空");
        
        NSString *decodeStr = [GMSm2Utils asn1DecodeToC1C3C2:encryptStr];
        XCTAssertNotNil(decodeStr, @"ASN1解码后字符串不为空");
        NSString *encodeStr = [GMSm2Utils asn1EncodeWithC1C3C2:decodeStr];
        XCTAssertNotNil(encodeStr, @"ASN1编码后字符串不为空");
        
        NSString *decryptStr = [GMSm2Utils decryptToText:encryptStr privateKey:GMPriKey];
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
        
        NSString *encryptStr = [GMSm2Utils encryptText:plaintext publicKey:GMPubKey];
        XCTAssertNotNil(encryptStr, @"加密字符串不为空");
        
        NSString *decryptStr = [GMSm2Utils decryptToText:encryptStr privateKey:GMPriKey];
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
        
        NSString *signStr = [GMSm2Utils signText:plaintext privateKey:GMPriKey userID:tempUserID];
        XCTAssertNotNil(signStr, @"签名结果不为空");
        
        BOOL isOK = [GMSm2Utils verifyText:plaintext signRS:signStr publicKey:GMPubKey userID:tempUserID];
        XCTAssertTrue(isOK, @"签名结果应该校验成功");
        
        NSString *derStr = [GMSm2Utils derEncode:signStr];
        XCTAssertNotNil(derStr, @"Der 签名结果不为空");
        
        NSString *orginSign = [GMSm2Utils derDecode:derStr];
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
        NSString *encryptStr = [GMSm2Utils encryptText:plaintext publicKey:GMPubKey];
        XCTAssertNotNil(encryptStr, @"加密字符串不为空");
    }];
}

/**
 * 测试解密耗时
 */
- (void)testPerformanceSm2Decrypt {
    NSString *ctext = @"306F022100D4F1B32E29501E9444467F9E2E51361E91F5EC0B96F33494E550829F00CCB5B70220044283DF7621B29CEB7F648BB47A3CBFFE9747E4D2BD4744C9DA1D68122343D6042045F6AB5422716393953B58E38D9032B7A1D8762BB816F26A835177442D282CD20406629F386A7776";
    // 解密耗时
    [self measureBlock:^{
        NSString *decryptStr = [GMSm2Utils decryptToText:ctext privateKey:GMPriKey];
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
        NSString *encodeStr = [GMSm2Utils asn1EncodeWithC1C3C2:dCodeCtext];
        XCTAssertNotNil(encodeStr, @"ASN1编码后字符串不为空");
    }];
}

/**
 * 测试 ASN1 解码耗时
 */
- (void)testPerformanceSm2ASN1Decode {
    NSString *ctext = @"306F022100D4F1B32E29501E9444467F9E2E51361E91F5EC0B96F33494E550829F00CCB5B70220044283DF7621B29CEB7F648BB47A3CBFFE9747E4D2BD4744C9DA1D68122343D6042045F6AB5422716393953B58E38D9032B7A1D8762BB816F26A835177442D282CD20406629F386A7776";
    // 解码耗时
    [self measureBlock:^{
        NSString *decodeStr = [GMSm2Utils asn1DecodeToC1C3C2:ctext];
        XCTAssertNotNil(decodeStr, @"ASN1解码后字符串不为空");
    }];
}

@end
