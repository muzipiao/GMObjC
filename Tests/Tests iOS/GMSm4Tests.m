//
//  GMSm4Tests.m
//  GMObjC_Tests
//
//  Created by lifei on 2019/8/18.
//  Copyright © 2019 lifei. All rights reserved.
//

#import "GMBaseTests.h"

@interface GMSm4Tests : GMBaseTests

@end

@implementation GMSm4Tests

/// 测试 sm4 出现空的情况
- (void)testSm4Null {
    NSData *plainData = [@"123456" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *sm4Key = [GMSm4Utils generateKey];
    NSData *ivec = [GMSm4Utils generateKey];
    NSArray *randDataList = @[[NSNull null], [NSData data], plainData];
    NSArray *randKeyList = @[[NSNull null], [NSData data], sm4Key];
    NSArray *randIvecList = @[[NSNull null], [NSData data], ivec];
    
    
    for (NSInteger i = 0; i < 128; i++) {
        NSData *randData = randDataList[arc4random_uniform((uint32_t)randDataList.count)];
        randData = [randData isKindOfClass:[NSNull class]] ? nil : randData;
        NSData *randKey = randKeyList[arc4random_uniform((uint32_t)randKeyList.count)];
        randKey = [randKey isKindOfClass:[NSNull class]] ? nil : randKey;
        NSData *randIvec = randIvecList[arc4random_uniform((uint32_t)randIvecList.count)];
        randIvec = [randIvec isKindOfClass:[NSNull class]] ? nil : randIvec;
        if (randData.length > 0 && randKey.length > 0) {
            continue; // 数据和Key必须有一个为空，IVEC 的值可选
        }
        // ECB 模式加密空
        NSData *ecbEnNull = [GMSm4Utils encryptDataWithECB:randData keyData:randKey];
        XCTAssertNil(ecbEnNull, @"有空值，加密 Data 应为空");
        // CBC 模式加密空
        NSData *cbcEnNull = [GMSm4Utils encryptDataWithCBC:randData keyData:randKey ivecData:randIvec];
        XCTAssertNil(cbcEnNull, @"有空值，加密 Data 应为空");
        // ECB 模式解密空
        NSData *ecbDeNull = [GMSm4Utils decryptDataWithECB:randData keyData:randKey];
        XCTAssertNil(ecbDeNull, @"有空值，解密 Data 应为空");
        // CBC 模式解密空
        NSData *cbcDeNull = [GMSm4Utils decryptDataWithCBC:randData keyData:randKey ivecData:randIvec];
        XCTAssertNil(cbcDeNull, @"有空值，解密 Data 应为空");
    }
}

/// 测试大量生产 sm4 公私钥
- (void)testSm4CreateKeys {
    for (NSInteger i = 0; i < 1000; i++) {
        NSData *sm4Key = [GMSm4Utils generateKey];
        XCTAssertNotNil(sm4Key, @"生成 sm4 密钥不为空");
        XCTAssertTrue(sm4Key.length == 16, @" sm4密钥长度 ");
    }
}

/// 测试 sm4 加解密文件
- (void)testSm4File {
    XCTAssertNotNil(self.fileData, @"待加密 NSData 不为空");
    for (NSInteger i = 0; i < 1000; i++) {
        // 生产密钥不为空
        NSData *sm4Key = [GMSm4Utils generateKey];
        XCTAssertNotNil(sm4Key, @"生成 sm4 密钥不为空");
        
        // ECB 模式
        NSData *cipherDataByEcb = [GMSm4Utils encryptDataWithECB:self.fileData keyData:sm4Key];
        XCTAssertTrue(cipherDataByEcb.length > 0, @"加密后数据不为空");
        NSData *decryptDataByEcb = [GMSm4Utils decryptDataWithECB:cipherDataByEcb keyData:sm4Key];
        XCTAssertTrue(decryptDataByEcb.length > 0, @"解密后数据不为空");
        
        // CBC 模式
        NSData *ivec = [GMSm4Utils generateKey];
        NSData *cipherDataByCbc = [GMSm4Utils encryptDataWithCBC:self.fileData keyData:sm4Key ivecData:ivec];
        XCTAssertTrue(cipherDataByCbc.length > 0, @"加密后数据不为空");
        NSData *decryptDataByCbc = [GMSm4Utils decryptDataWithCBC:cipherDataByCbc keyData:sm4Key ivecData:ivec];
        XCTAssertTrue(decryptDataByCbc.length > 0, @"解密后数据不为空");
        
        // 加解密后与原数据相同
        BOOL isSameDataByEcb = [decryptDataByEcb isEqualToData:self.fileData];
        XCTAssertTrue(isSameDataByEcb, @"sm4 加解密后数据不变");
        
        BOOL isSameDataByCbc = [decryptDataByCbc isEqualToData:self.fileData];
        XCTAssertTrue(isSameDataByCbc, @"sm4 加解密后数据不变");
    }
}

/// 测试 sm 4 大量加解密数字英文字符字符串
- (void)testSm4Str {
    for (NSInteger i = 0; i < 3000; i++) {
        int randLen = arc4random_uniform((int)10000);
        NSString *plaintext = nil;
        if (i<1000) {
            plaintext = [self randomEn:randLen]; // 数字英文
        }else if (i>=1000 && i< 2000){
            plaintext = [self randomZh:randLen]; // 中文字符
        }else{
            plaintext = [self randomZhEn:randLen]; //中英文混合
        }
        NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
        XCTAssertNotNil(plainData, @"生成字符串不为空");
        // 生产密钥不为空
        NSData *sm4Key = [GMSm4Utils generateKey];
        XCTAssertNotNil(sm4Key, @"生成 sm4 密钥不为空");
        // ECB 模式
        NSData *encryptByEcb = [GMSm4Utils encryptDataWithECB:plainData keyData:sm4Key];
        XCTAssertNotNil(encryptByEcb, @"加密字符串不为空");
        NSData *decryptByEcb = [GMSm4Utils decryptDataWithECB:encryptByEcb keyData:sm4Key];
        XCTAssertNotNil(decryptByEcb, @"解密结果不为空");
        // CBC 模式
        NSData *ivec = [GMSm4Utils generateKey];
        NSData *encryptByCbc = [GMSm4Utils encryptDataWithCBC:plainData keyData:sm4Key ivecData:ivec];
        XCTAssertNotNil(encryptByCbc, @"加密字符串不为空");
        NSData *decryptByCbc = [GMSm4Utils decryptDataWithCBC:encryptByCbc keyData:sm4Key ivecData:ivec];
        XCTAssertNotNil(decryptByCbc, @"解密结果不为空");
        
        BOOL isSameByEcb = [decryptByEcb isEqualToData:plainData];
        XCTAssertTrue(isSameByEcb, @"加解密结果应该相同");
        
        BOOL isSameByCbc = [decryptByCbc isEqualToData:plainData];
        XCTAssertTrue(isSameByCbc, @"加解密结果应该相同");
    }
}

/// 测试 sm4 ECB 模式加密耗时
- (void)testPerformanceSm4EcbEncrypt {
    NSData *plainData = [@"123456" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *sm4Key = [GMSmUtils dataFromHexString:@"CCDEE6FB253E1CBCD40B12D5E230D0F4"];
    // 加密耗时
    [self measureBlock:^{
        NSData *encryptData = [GMSm4Utils encryptDataWithECB:plainData keyData:sm4Key];
        XCTAssertNotNil(encryptData, @"加密字符串不为空");
    }];
}

/// 测试 sm4 ECB 模式解密耗时
- (void)testPerformanceSm4EcbDecrypt {
    NSData *encryptData = [GMSmUtils dataFromHexString:@"271B76936B39CEE6CAE1ABBB4539D8E7"];
    NSData *sm4Key = [GMSmUtils dataFromHexString:@"CCDEE6FB253E1CBCD40B12D5E230D0F4"];
    // 解密耗时
    [self measureBlock:^{
        NSData *decryptData = [GMSm4Utils decryptDataWithECB:encryptData keyData:sm4Key];
        XCTAssertNotNil(decryptData, @"解密结果不为空");
    }];
}

/// 测试 sm4 ECB 模式加密耗时
- (void)testPerformanceSm4CbcEncrypt {
    NSData *plainData = [@"123456" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *sm4Key = [GMSmUtils dataFromHexString:@"26FADA370AECFB5CBCF8397BD1D8363A"];
    NSData *ivec = [GMSmUtils dataFromHexString:@"685E7C9D456A5093C83606D94FE67AA5"];
    // 加密耗时
    [self measureBlock:^{
        NSData *encryptData = [GMSm4Utils encryptDataWithCBC:plainData keyData:sm4Key ivecData:ivec];
        XCTAssertNotNil(encryptData, @"加密字符串不为空");
    }];
}

/// 测试 sm4 ECB 模式解密耗时
- (void)testPerformanceSm4CbcDecrypt {
    NSData *encryptData = [GMSmUtils dataFromHexString:@"C4DDE9A8211F78584867850DF47F0128"];
    NSData *sm4Key = [GMSmUtils dataFromHexString:@"26FADA370AECFB5CBCF8397BD1D8363A"];
    NSData *ivec = [GMSmUtils dataFromHexString:@"685E7C9D456A5093C83606D94FE67AA5"];
    // 解密耗时
    [self measureBlock:^{
        NSData *decryptData = [GMSm4Utils decryptDataWithCBC:encryptData keyData:sm4Key ivecData:ivec];
        XCTAssertNotNil(decryptData, @"解密结果不为空");
    }];
}

@end
