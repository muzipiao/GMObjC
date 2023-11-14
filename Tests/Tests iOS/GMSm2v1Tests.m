//
//  GMSm2Tests.m
//  GMObjC_Tests
//
//  Created by lifei on 2019/8/18.
//  Copyright © 2019 lifei. All rights reserved.
//

#import "GMSm2v1Tests.h"

@implementation GMSm2v1Tests

- (void)setUp {
    [super setUp];
    [GMSm2Utils setCurveType:GMSm2CurveTypeSm2p256v1];
    
    self.gPubKey = @"0408E3FFF9505BCFAF9307E665E9229F4E1B3936437A870407EA3D97886BAFBC9"
                    "C624537215DE9507BC0E2DD276CF74695C99DF42424F28E9004CDE4678F63D698";
    self.gPriKey = @"90F3A42B9FE24AB196305FD92EC82E647616C3A3694441FB3422E7838E24DEAE";
    
    // 正确的加密后的数据
    self.gCipherText = @"3070022100E5E71C8158EE884CABA74BBFC43CF8A7D198928"
                        "DDD3D8A6FB610437230D42CF4022100CF361D0243F15565D0"
                        "BB55F9F1E2BA211D7B8E5568266157051E1FF9B1205DDB042"
                        "067B19DF80644D1E3697E6D3A281A402CAE59FA0AF88611D7"
                        "5ECE66C3261007C10406E6C3F6DD55A9";
    self.gCipherHex = @"3070022100BF7D0E89E02CD0F3B241B23CD4D2904D48E1A7BA"
                       "DDCD980A682DB812621ECF74022100981870FE0B8A9AF599B"
                       "94C5C2D72EB8045305CD2D072499A5D6490535E7DAF630420"
                       "F1BBEF021C566067CFD4ED243F9ED405322CBF3C003BE1A80"
                       "DD0A38CBE0ACC8804062EFFC5F9F44D";
    self.gCipherDataHex = @"306F022100D0FC97E530F1F5B11FF01680ED5517A73BED"
                           "3C06A2A3ECC593D5110A75F4653C022075FAEF6EEEA15E"
                           "9E383AD983B2B54BE003855BC46C114070304A40C09213"
                           "346A0420AC602A62EA27182445E2F5D608C01039B47C92"
                           "5527F0973F67058CE70D85C9030406CC020AC863D6";
}

- (void)tearDown {
    self.gPubKey = nil;
    self.gPriKey = nil;
    self.gCipherHex = nil;
    self.gCipherHex = nil;
    self.gCipherDataHex = nil;
    [super tearDown];
}

// MARK: - 椭圆曲线类型
- (void)testEllipticCurveType {
    int currentType = [GMSm2Utils curveType];
    XCTAssertTrue(currentType == GMSm2CurveTypeSm2p256v1, @"当前椭圆曲线应为 NID_sm2");
}


// MARK: - NULL
/// 测试加解密出现空值情况
- (void)testEnDeNull {
    NSData *plainData = [NSData dataWithBytes:"123456" length:6];
    NSArray *randStrArray = @[[NSNull null], @"", @"123456"];
    NSArray *randPubArray = @[[NSNull null], @"", self.gPubKey];
    NSArray *randPriArray = @[[NSNull null], @"", self.gPriKey];
    NSArray *randDataArray = @[[NSNull null], [NSData new], plainData];
    
    for (NSInteger i = 0; i < 60; i++) {
        NSString *randStr = randStrArray[arc4random_uniform((uint32_t)randStrArray.count)];
        NSString *randPub = randPubArray[arc4random_uniform((uint32_t)randPubArray.count)];
        NSString *randPri = randPriArray[arc4random_uniform((uint32_t)randPriArray.count)];
        NSData *randData = randDataArray[arc4random_uniform((uint32_t)randDataArray.count)];
        randStr = [randStr isKindOfClass:[NSNull class]] ? nil : randStr;
        randPub = [randPub isKindOfClass:[NSNull class]] ? nil : randPub;
        randPri = [randPri isKindOfClass:[NSNull class]] ? nil : randPri;
        randData = [randData isKindOfClass:[NSNull class]] ? nil : randData;
        // 测试加密有空值情况
        if ((randStr.length > 0 && randPub.length > 0) == NO) {
            // 加密普通字符串
            NSData *enData = [GMSm2Utils encryptData:[randStr dataUsingEncoding:NSUTF8StringEncoding] publicKey:randPub];
            XCTAssertNil(enData, @"加密字符串应为空");
        }
        if ((randData.length > 0 && randPub.length > 0) == NO) {
            NSData *enData = [GMSm2Utils encryptData:randData publicKey:randPub];
            XCTAssertNil(enData, @"加密字符串应为空");
        }
        // 测试解密有空值情况
        if ((randStr.length > 0 && randPri.length > 0) == NO) {
            NSData *cipherData = [randStr dataUsingEncoding:NSUTF8StringEncoding];
            // 若有值，转为对应密文
            if (randStr.length > 0) {
                cipherData = [GMSm2Utils encryptData:[randStr dataUsingEncoding:NSUTF8StringEncoding] publicKey:self.gPubKey];
                XCTAssertNotNil(cipherData, @"测试密文不为空");
            }
            NSData *deData = [GMSm2Utils decryptData:cipherData privateKey:randPri];
            XCTAssertNil(deData, @"解密字符串应为空");
        }
        if ((randData.length > 0 && randPri.length > 0) == NO) {
            NSData *cipherData = randData;
            if (randData.length > 0) {
                cipherData = [GMSm2Utils encryptData:randData publicKey:self.gPubKey];
                XCTAssertNotNil(cipherData, @"测试密文不为空");
            }
            NSData *deData = [GMSm2Utils decryptData:cipherData privateKey:randPri];
            XCTAssertNil(deData, @"解密字符串应为空");
        }
    }
}

/// 测试 ASN1 编码解码出现空值情况
- (void)testASN1Null {
    NSArray *randStrArray = @[[NSNull null], @""];
    NSArray *randC1C3C2Array = @[[NSNull null], [NSArray array]];
    NSArray *randDataArray = @[[NSNull null], [NSData new]];
    
    for (NSInteger i = 0; i < 60; i++) {
        NSString *randStr = randStrArray[arc4random_uniform((uint32_t)randStrArray.count)];
        NSArray *randArray = randC1C3C2Array[arc4random_uniform((uint32_t)randC1C3C2Array.count)];
        NSData *randData = randDataArray[arc4random_uniform((uint32_t)randDataArray.count)];
        randStr = [randStr isKindOfClass:[NSNull class]] ? nil : randStr;
        randArray = [randArray isKindOfClass:[NSNull class]] ? nil : randArray;
        randData = [randData isKindOfClass:[NSNull class]] ? nil : randData;
        NSData *asn1Data = [GMSm2Utils asn1EncodeWithC1C3C2Data:randData hasPrefix:NO];
        XCTAssertNil(asn1Data, @"编码字符串应为空");
        NSData *asn1DeData = [GMSm2Utils asn1DecodeToC1C3C2Data:randData hasPrefix:NO];
        XCTAssertNil(asn1DeData, @"解码字符串应为空");
    }
}

// 测试密文转换出现空值的情况
- (void)testConvertNull {
    NSArray *randStrList = @[[NSNull null], @"", @"krand"];
    for (NSInteger i = 0; i < 100; i++) {
        NSString *randStr = randStrList[arc4random_uniform((uint32_t)randStrList.count)];
        randStr = [randStr isKindOfClass:[NSNull class]] ? nil : randStr;
        if ([randStr isEqualToString:@"krand"]) {
            randStr = [self randomEn:(int)arc4random_uniform(32)];
        }
        BOOL randPrefix = i%2 == 0 ? YES : NO;
        NSData *randData = [randStr dataUsingEncoding:NSUTF8StringEncoding];
        NSData *c1c3c2 = [GMSm2Utils convertC1C2C3DataToC1C3C2:randData hasPrefix:randPrefix];
        XCTAssertNil(c1c3c2, @"转换结果为空");
        NSData *c1c2c3 = [GMSm2Utils convertC1C3C2DataToC1C2C3:randData hasPrefix:randPrefix];
        XCTAssertNil(c1c2c3, @"转换结果为空");
    }
}

/// 测试签名验签出现空值情况
- (void)testSignNull {
    NSData *plainData = [NSData dataWithBytes:"123456" length:6];
    NSArray *randStrArray = @[[NSNull null], @"", @"123456"];
    NSArray *randPubArray = @[[NSNull null], @"", self.gPubKey];
    NSArray *randPriArray = @[[NSNull null], @"", self.gPriKey];
    NSArray *randDataArray = @[[NSNull null], [NSData new], plainData];
    NSArray *randUserArray = @[[NSNull null], @"", GMTestUserID];
    
    for (NSInteger i = 0; i < 80; i++) {
        NSString *randStr = randStrArray[arc4random_uniform((uint32_t)randStrArray.count)];
        NSString *randPub = randPubArray[arc4random_uniform((uint32_t)randPubArray.count)];
        NSString *randPri = randPriArray[arc4random_uniform((uint32_t)randPriArray.count)];
        NSData *randData = randDataArray[arc4random_uniform((uint32_t)randDataArray.count)];
        NSString *randUser = randUserArray[arc4random_uniform((uint32_t)randUserArray.count)];
        randStr = [randStr isKindOfClass:[NSNull class]] ? nil : randStr;
        randPub = [randPub isKindOfClass:[NSNull class]] ? nil : randPub;
        randPri = [randPri isKindOfClass:[NSNull class]] ? nil : randPri;
        randData = [randData isKindOfClass:[NSNull class]] ? nil : randData;
        randUser = [randUser isKindOfClass:[NSNull class]] ? nil : randUser;
        // 测试签名
        if ((randData.length > 0 && randPri.length > 0) == NO) {
            NSData *userData = [randUser dataUsingEncoding:NSUTF8StringEncoding];
            NSString *signData = [GMSm2Utils signData:randData privateKey:randPri userData:userData];
            XCTAssertNil(signData, @"签名字符串应为空");
        }
        // 测试验签
        if ((randData.length > 0 && randPub.length > 0) == NO) {
            NSString *sign = randStr;
            NSData *userData= [randUser dataUsingEncoding:NSUTF8StringEncoding];
            if (randData.length == 0) {
                NSData *plainData = [NSData dataWithBytes:"123456" length:6];
                sign = [GMSm2Utils signData:plainData privateKey:self.gPriKey userData:userData];
                XCTAssertNotNil(sign, @"测试签名不为空");
            }
            BOOL isDataOK = [GMSm2Utils verifyData:randData signRS:sign publicKey:randPub userData:userData];
            XCTAssertFalse(isDataOK, @"明文为空验证不通过");
        }
    }
}

/// 测试 ECDH 密钥协商出现空值情况
- (void)testECDHNull {
    NSArray *randPubArray = @[[NSNull null], @"", self.gPubKey];
    NSArray *randPriArray = @[[NSNull null], @"", self.gPriKey];
    for (NSInteger i = 0; i < 30; i++) {
        NSString *randPub = randPubArray[arc4random_uniform((uint32_t)randPubArray.count)];
        NSString *randPri = randPriArray[arc4random_uniform((uint32_t)randPriArray.count)];
        randPub = [randPub isKindOfClass:[NSNull class]] ? nil : randPub;
        randPri = [randPri isKindOfClass:[NSNull class]] ? nil : randPri;
        
        if ((randPub.length > 0 && randPri.length > 0) == NO) {
            NSString *ecdhNull = [GMSm2Utils computeECDH:randPub privateKey:randPri];
            XCTAssertNil(ecdhNull, @"协商密钥应为空");
        }
    }
}

// MARK: - Error Key
/// 测试公私钥错误的情况下加解密和签名验签情况
- (void)testErrorKey {
    NSString *errorPubKey = @"0408E3FFF9505BCFAF9307E888888999999B3936437A870407EA3D97886BAF"
                             "BC9C624537215DE9507BC0E2DD276CF74695C924F28E9004CDE4678F63D698";
    NSString *errorPriKey = @"6666662B9FE24AB196305F82E647616C3A3694441FB3422E7838E24DEAE";
    
    // 使用错误的公钥加密结果为空
    NSData *plainData = [NSData dataWithBytes:"123456" length:6];
    NSData *enData = [GMSm2Utils encryptData:plainData publicKey:errorPubKey];
    XCTAssertTrue(enData.length == 0, @"加密结果为空");
    
    NSData *cipherData = [GMSmUtils dataFromHexString:self.gCipherDataHex];
    // 使用错误的私钥解密为空
    NSData *deData = [GMSm2Utils decryptData:cipherData privateKey:errorPriKey];
    XCTAssertTrue(deData.length == 0, @"解密结果为空");
    
    // 使用错误的公钥私钥，验签不通过
    NSArray *pubArray = @[self.gPubKey, errorPubKey];
    NSArray *priArray = @[errorPriKey, self.gPriKey];
    for (NSInteger i = 0; i < pubArray.count; i++) {
        NSString *pubKey = pubArray[i];
        NSString *priKey = priArray[i];
        NSString *signData = [GMSm2Utils signData:plainData privateKey:priKey userData:nil];
        BOOL isDataOK = [GMSm2Utils verifyData:plainData signRS:signData publicKey:pubKey userData:nil];
        XCTAssertFalse(isDataOK, @"签名结果应校验失败");
    }
}

// MARK: - ECDH
/// 测试 ECDH 密钥协商
- (void)testECDH {
    for (NSInteger i = 0; i < 1000; i++) {
        GMSm2Key *clientKey = [GMSm2Utils generateKey];
        NSString *cPubKey = clientKey.publicKey;
        NSString *cPriKey = clientKey.privateKey;
        
        GMSm2Key *serverKey = [GMSm2Utils generateKey];
        NSString *sPubKey = serverKey.publicKey;
        NSString *sPriKey = serverKey.privateKey;
        
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

// MARK: - KeyPair
/// 测试大量生产 sm2 公私钥
- (void)testCreateKeys {
    for (NSInteger i = 0; i < 10000; i++) {
        // 生成一对新的公私钥
        GMSm2Key *newKey = [GMSm2Utils generateKey];
        NSString *pubKey = newKey.publicKey;
        NSString *priKey = newKey.privateKey;
        XCTAssertNotNil(pubKey, @"生成公钥不为空");
        XCTAssertNotNil(priKey, @"生成私钥不为空");
    }
}

// 测试密文转换
- (void)testConvertCiphertext {
    for (NSInteger i = 0; i < 1000; i++) {
        GMSm2Key *newKey = [GMSm2Utils generateKey];
        NSString *pubKey = newKey.publicKey;
        NSString *priKey = newKey.privateKey;
        XCTAssertNotNil(pubKey, @"生成公钥不为空");
        XCTAssertNotNil(priKey, @"生成私钥不为空");
        // 加密
        NSString *plaintext = [self randomAny:10000];
        XCTAssertNotNil(plaintext, @"生成明文字符串不为空");
        NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
        NSData *ciphertextASN1 = [GMSm2Utils encryptData:plainData publicKey:pubKey];
        XCTAssertNotNil(ciphertextASN1, @"密文字符串不为空");
        // ASN1 解码
        NSData *originC1C3C2 = [GMSm2Utils asn1DecodeToC1C3C2Data:ciphertextASN1 hasPrefix:NO];
        XCTAssertNotNil(originC1C3C2, @"密文字符串不为空");
        // 顺序转换
        BOOL hasPrefix = i%2 == 0 ? YES : NO;
        NSData *prefixC1C3C2 = originC1C3C2;
        if (hasPrefix == YES) {
            NSMutableData *mutableData = [NSMutableData dataWithData:[GMSmUtils dataFromHexString:@"04"]];
            [mutableData appendData:originC1C3C2];
            prefixC1C3C2 = mutableData.copy;
        }
        NSData *convertC1C2C3 = [GMSm2Utils convertC1C3C2DataToC1C2C3:prefixC1C3C2 hasPrefix:hasPrefix];
        XCTAssertNotNil(convertC1C2C3, @"密文字符串不为空");
        NSData *convertC1C3C2 = [GMSm2Utils convertC1C2C3DataToC1C3C2:convertC1C2C3 hasPrefix:hasPrefix];
        XCTAssertTrue([convertC1C3C2 isEqualToData:prefixC1C3C2], @"转换后结果一致");
        // ASN1 编码
        NSData *convertASN1 = [GMSm2Utils asn1EncodeWithC1C3C2Data:convertC1C3C2 hasPrefix:hasPrefix];
        XCTAssertNotNil(convertASN1, @"密文字符串不为空");
        // 解密
        NSData *deData = [GMSm2Utils decryptData:convertASN1 privateKey:priKey];
        XCTAssertTrue([deData isEqualToData:plainData], @"解密结果与原文一致");
    }
}

// MARK: - ASN1 编解码
/// 测试多次 ASN1 编码解码结果相同
- (void)testASN1SameResult {
    NSString *plaintext = [self randomAny:10000];
    XCTAssertNotNil(plaintext, @"生成字符串不为空");
    NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ciphertext = [GMSm2Utils encryptData:plainData publicKey:self.gPubKey];
    XCTAssertNotNil(ciphertext, @"加密字符串不为空");
    
    NSData *c1c3c2Str = [GMSm2Utils asn1DecodeToC1C3C2Data:ciphertext hasPrefix:NO];
    XCTAssertNotNil(c1c3c2Str, @"ASN1解码后字符串不为空");
    for (NSInteger i = 0; i < 1000; i++) {
        NSData *newDecodeStr = [GMSm2Utils asn1DecodeToC1C3C2Data:ciphertext hasPrefix:NO];
        BOOL isSame_decode = [newDecodeStr isEqualToData:c1c3c2Str];
        XCTAssertTrue(isSame_decode, @"多次解码应该相同");
    }
    
    NSData *encodeStr = [GMSm2Utils asn1EncodeWithC1C3C2Data:c1c3c2Str hasPrefix:NO];
    XCTAssertNotNil(encodeStr, @"ASN1编码后字符串不为空");
    for (NSInteger i = 0; i < 1000; i++) {
        NSData *newEncodeStr = [GMSm2Utils asn1EncodeWithC1C3C2Data:c1c3c2Str hasPrefix:NO];
        BOOL isSame_encode = [newEncodeStr isEqualToData:encodeStr];
        XCTAssertTrue(isSame_encode, @"多次编码应该相同");
    }
    
    BOOL isSame_Ctext = [encodeStr isEqualToData:ciphertext];
    XCTAssertTrue(isSame_Ctext, @"编码后和原始密文相同");
    
    NSData *decryptStr = [GMSm2Utils decryptData:ciphertext privateKey:self.gPriKey];
    XCTAssertNotNil(decryptStr, @"解密结果不为空");
    BOOL isSame_plain = [decryptStr isEqualToData:plainData];
    XCTAssertTrue(isSame_plain, @"加解密结果应该相同");
}

- (void)testASN1AnyText {
    for (NSInteger i = 0; i < 1000; i++) {
        NSString *plaintext = [self randomAny:10000];
        XCTAssertNotNil(plaintext, @"生成明文字符串不为空");
        NSString *plainHex = [GMSmUtils hexStringFromString:plaintext];
        XCTAssertNotNil(plainHex, @"生成明文 Hex 字符串不为空");
        NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
        XCTAssertNotNil(plainData, @"生成明文 Data 不为空");
        // ASN1 格式密文
        NSData *enData = [GMSm2Utils encryptData:plainData publicKey:self.gPubKey];
        XCTAssertNotNil(enData, @"加密字符串不为空");
        // 解码 ASN1 为 c1c3c2 格式
        NSData *c1c3c2Data = [GMSm2Utils asn1DecodeToC1C3C2Data:enData hasPrefix:NO];
        XCTAssertNotNil(c1c3c2Data, @"ASN1 解码后 Data 不为空");
        // ASN1 编码后应与密文相同
        NSData *asn1Data = [GMSm2Utils asn1EncodeWithC1C3C2Data:c1c3c2Data hasPrefix:NO];
        XCTAssertTrue([asn1Data isEqualToData:enData], @"ASN1 解码编码后与密文相同");
    }
}

// MARK: - 加解密
/// 测试 SM2 加解密
- (void)testEnDe {
    for (NSInteger i = 0; i < 3000; i++) {
        NSString *plaintext = [self randomAny:10000];
        XCTAssertNotNil(plaintext, @"生成明文字符串不为空");
        NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
        XCTAssertNotNil(plainData, @"生成明文 Data 不为空");
        // ASN1 格式密文
        NSData *enData = [GMSm2Utils encryptData:plainData publicKey:self.gPubKey];
        XCTAssertNotNil(enData, @"加密字符串不为空");
        // 解密
        NSData *deData = [GMSm2Utils decryptData:enData privateKey:self.gPriKey];
        XCTAssertTrue([deData isEqualToData:plainData], @"解密结果与原文一致");
    }
}

// MARK: - 签名验签
/// 测试签名验签
- (void)testSignVerify {
    NSArray *randUserArray = @[[NSNull null], @"", GMTestUserID];
    for (NSInteger i = 0; i < 1000; i++) {
        NSString *plaintext = [self randomAny:100];
        XCTAssertNotNil(plaintext, @"生成明文字符串不为空");
        NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
        XCTAssertNotNil(plainData, @"生成明文 Data 不为空");
        NSString *randUser = randUserArray[arc4random_uniform((uint32_t)randUserArray.count)];
        NSData *randUserData = [randUser isKindOfClass:[NSNull class]] ? nil : [randUser dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString *signData = [GMSm2Utils signData:plainData privateKey:self.gPriKey userData:randUserData];
        XCTAssertNotNil(signData, @"签名结果不为空");
        NSString *derData = [GMSm2Utils encodeDerWithSignRS:signData];
        XCTAssertNotNil(derData, @"Der 编码不为空");
        NSString *originSignData = [GMSm2Utils decodeDerToSignRS:derData];
        XCTAssertTrue([originSignData isEqualToString:signData], @"Der 编码解码结果应该相同");
        BOOL isDataOK = [GMSm2Utils verifyData:plainData signRS:signData publicKey:self.gPubKey userData:randUserData];
        XCTAssertTrue(isDataOK, @"签名结果应该校验成功");
    }
}

// MARK: - 加解密耗时
/// 测试加密耗时
- (void)testPerformanceEnText {
    NSString *plaintext = @"123456";
    [self measureBlock:^{
        NSData *enText = [GMSm2Utils encryptData:[plaintext dataUsingEncoding:NSUTF8StringEncoding] publicKey:self.gPubKey];
        XCTAssertNotNil(enText, @"加密字符串不为空");
    }];
}

- (void)testPerformanceEnData {
    NSData *plainData = [NSData dataWithBytes:"123456" length:6];
    [self measureBlock:^{
        NSData *enData = [GMSm2Utils encryptData:plainData publicKey:self.gPubKey];
        XCTAssertNotNil(enData, @"加密字符串不为空");
    }];
}

/// 测试解密耗时
- (void)testPerformanceDeData {
    NSData *plainData = [NSData dataWithBytes:"123456" length:6];
    NSData *cipherData = [GMSm2Utils encryptData:plainData publicKey:self.gPubKey];
    XCTAssertNotNil(cipherData, @"密文不为空");
    [self measureBlock:^{
        NSData *deData = [GMSm2Utils decryptData:cipherData privateKey:self.gPriKey];
        XCTAssertNotNil(deData, @"解密结果不为空");
    }];
}

// MARK: - ASN1 耗时
- (void)testPerformanceASN1EnData {
    NSData *plainData = [NSData dataWithBytes:"123456" length:6];
    NSData *cipherData = [GMSm2Utils encryptData:plainData publicKey:self.gPubKey];
    XCTAssertNotNil(cipherData, @"密文不为空");
    NSData *c1c3c2Data = [GMSm2Utils asn1DecodeToC1C3C2Data:cipherData hasPrefix:NO];
    XCTAssertNotNil(c1c3c2Data, @"c1c3c2 Data 格式不为空");
    [self measureBlock:^{
        NSData *encodeData = [GMSm2Utils asn1EncodeWithC1C3C2Data:c1c3c2Data hasPrefix:NO];
        XCTAssertNotNil(encodeData, @"ASN1 编码后 Data 不为空");
    }];
}

/// 测试 ASN1 解码耗时
- (void)testPerformanceASN1DeToData {
    NSData *plainData = [NSData dataWithBytes:"123456" length:6];
    NSData *cipherData = [GMSm2Utils encryptData:plainData publicKey:self.gPubKey];
    XCTAssertNotNil(cipherData, @"密文不为空");
    [self measureBlock:^{
        NSData *c1c3c2Data = [GMSm2Utils asn1DecodeToC1C3C2Data:cipherData hasPrefix:NO];
        XCTAssertNotNil(c1c3c2Data, @"c1c3c2 Data 格式不为空");
    }];
}

@end
