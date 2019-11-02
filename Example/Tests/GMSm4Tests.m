//
//  GMSm4Tests.m
//  GMObjC_Tests
//
//  Created by lifei on 2019/8/18.
//  Copyright © 2019 lifei. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface GMSm4Tests : GMBaseTests

@end

@implementation GMSm4Tests

/**
 * 测试 sm4 出现空的情况
 */
- (void)testSm4Null {
    NSString *pwd = @"123456";
    NSString *strNull = nil;
    NSString *strLenZero = @"";
    NSData *dataNull = [NSData data];
    NSString *sm4Key = [GMSm4Utils createSm4Key];
    NSString *ivec = [GMSm4Utils createSm4Key];
    
    // ECB 模式加密空
    NSString *ecbEnNullStr = [GMSm4Utils ecbEncrypt:strNull Key:sm4Key];
    XCTAssertNil(ecbEnNullStr, @"加密字符串应为空");
    NSString *ecbEnZeroStr = [GMSm4Utils ecbEncrypt:strLenZero Key:sm4Key];
    XCTAssertNil(ecbEnZeroStr, @"加密字符串应为空");
    NSString *ecbEnNullKey = [GMSm4Utils ecbEncrypt:pwd Key:@""];
    XCTAssertNil(ecbEnNullKey, @"加密字符串应为空");
    NSData *ecbEnNullData = [GMSm4Utils ecbEncryptData:dataNull Key:sm4Key];
    XCTAssertNil(ecbEnNullData, @"Data 为空，加密 Data 应为空");
    NSData *ecbEnDataNullKey = [GMSm4Utils ecbEncryptData:self.fileData Key:@""];
    XCTAssertNil(ecbEnDataNullKey, @"key为空，加密 Data 应为空");
    
    // CBC 模式加密空
    NSString *cbcEnNullStr = [GMSm4Utils cbcEncrypt:strNull Key:sm4Key IV:ivec];
    XCTAssertNil(cbcEnNullStr, @"加密字符串应为空");
    NSString *cbcEnZeroStr = [GMSm4Utils cbcEncrypt:strLenZero Key:sm4Key IV:ivec];
    XCTAssertNil(cbcEnZeroStr, @"加密字符串应为空");
    NSString *cbcEnNullKey = [GMSm4Utils cbcEncrypt:pwd Key:@"" IV:ivec];
    XCTAssertNil(cbcEnNullKey, @"加密字符串应为空");
    NSData *cbcEnNullData = [GMSm4Utils cbcEncryptData:dataNull Key:sm4Key IV:ivec];
    XCTAssertNil(cbcEnNullData, @"Data 为空，加密 Data 应为空");
    NSData *cbcEnDataNullKey = [GMSm4Utils cbcEncryptData:self.fileData Key:@"" IV:ivec];
    XCTAssertNil(cbcEnDataNullKey, @"key为空，加密 Data 应为空");
    NSString *cbcEnIvNull = [GMSm4Utils cbcEncrypt:pwd Key:sm4Key IV:strNull];
    XCTAssertNil(cbcEnIvNull, @"加密字符串应为空");
    NSString *cbcEnIvZero = [GMSm4Utils cbcEncrypt:pwd Key:sm4Key IV:strLenZero];
    XCTAssertNil(cbcEnIvZero, @"加密字符串应为空");
    NSData *cbcEnDataIvNull = [GMSm4Utils cbcEncryptData:self.fileData Key:sm4Key IV:strNull];
    XCTAssertNil(cbcEnDataIvNull, @"加密字符串应为空");
    NSData *cbcEnDataIvZero = [GMSm4Utils cbcEncryptData:self.fileData Key:sm4Key IV:strLenZero];
    XCTAssertNil(cbcEnDataIvZero, @"加密字符串应为空");
    
    // ECB 模式解密空
    NSString *ecbDeNullStr = [GMSm4Utils ecbDecrypt:strNull Key:sm4Key];
    XCTAssertNil(ecbDeNullStr, @"解密字符串应为空");
    NSString *ecbDeZeroStr = [GMSm4Utils ecbDecrypt:strLenZero Key:sm4Key];
    XCTAssertNil(ecbDeZeroStr, @"解密字符串应为空");
    NSString *ecbDeNullKey = [GMSm4Utils ecbDecrypt:pwd Key:@""];
    XCTAssertNil(ecbDeNullKey, @"解密字符串应为空");
    NSData *ecbDeNullData = [GMSm4Utils ecbDecryptData:dataNull Key:sm4Key];
    XCTAssertNil(ecbDeNullData, @"Data 为空，解密 Data 应为空");
    NSData *ecbDeDataNullKey = [GMSm4Utils ecbDecryptData:self.fileData Key:@""];
    XCTAssertNil(ecbDeDataNullKey, @"key为空，解密 Data 应为空");
    
    // CBC 模式解密空
    NSString *cbcDeNullStr = [GMSm4Utils cbcDecrypt:strNull Key:sm4Key IV:ivec];
    XCTAssertNil(cbcDeNullStr, @"解密字符串应为空");
    NSString *cbcDeZeroStr = [GMSm4Utils cbcDecrypt:strLenZero Key:sm4Key IV:ivec];
    XCTAssertNil(cbcDeZeroStr, @"解密字符串应为空");
    NSString *cbcDeNullKey = [GMSm4Utils cbcDecrypt:pwd Key:@"" IV:ivec];
    XCTAssertNil(cbcDeNullKey, @"解密字符串应为空");
    NSData *cbcDeNullData = [GMSm4Utils cbcDecryptData:dataNull Key:sm4Key IV:ivec];
    XCTAssertNil(cbcDeNullData, @"Data 为空，解密 Data 应为空");
    NSData *cbcDeDataNullKey = [GMSm4Utils cbcDecryptData:self.fileData Key:@"" IV:ivec];
    XCTAssertNil(cbcDeDataNullKey, @"key为空，解密 Data 应为空");
    NSString *cbcDeNullIv = [GMSm4Utils cbcDecrypt:pwd Key:sm4Key IV:strNull];
    XCTAssertNil(cbcDeNullIv, @"IV 为空，解密 String 应为空");
    NSData *cbcDeDataNullIv = [GMSm4Utils cbcDecryptData:self.fileData Key:sm4Key IV:strNull];
    XCTAssertNil(cbcDeDataNullIv, @"IV为空，解密 Data 应为空");
    NSString *cbcDeZeroIv = [GMSm4Utils cbcDecrypt:pwd Key:sm4Key IV:strLenZero];
    XCTAssertNil(cbcDeZeroIv, @"IV 为空，解密 String 应为空");
    NSData *cbcDeDataZeroIv = [GMSm4Utils cbcDecryptData:self.fileData Key:sm4Key IV:strLenZero];
    XCTAssertNil(cbcDeDataZeroIv, @"IV为空，解密 Data 应为空");
}

/**
 * 测试大量生产 sm2 公私钥
 */
- (void)testSm4CreateKeys {
    for (NSInteger i = 0; i < 1000; i++) {
        NSString *sm4Key = [GMSm4Utils createSm4Key];
        XCTAssertNotNil(sm4Key, @"生成 sm4 密钥不为空");
        XCTAssertTrue(sm4Key.length == 32, @" sm4密钥长度 ");
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
        
        // ECB 模式
        NSData *cipherDataByEcb = [GMSm4Utils ecbEncryptData:self.fileData Key:sm4Key];
        XCTAssertTrue(cipherDataByEcb.length > 0, @"加密后数据不为空");
        NSData *decryptDataByEcb = [GMSm4Utils ecbDecryptData:cipherDataByEcb Key:sm4Key];
        XCTAssertTrue(decryptDataByEcb.length > 0, @"解密后数据不为空");
        
        // CBC 模式
        NSString *ivec = [GMSm4Utils createSm4Key];
        NSData *cipherDataByCbc = [GMSm4Utils cbcEncryptData:self.fileData Key:sm4Key IV:ivec];
        XCTAssertTrue(cipherDataByCbc.length > 0, @"加密后数据不为空");
        NSData *decryptDataByCbc = [GMSm4Utils cbcDecryptData:cipherDataByCbc Key:sm4Key IV:ivec];
        XCTAssertTrue(decryptDataByCbc.length > 0, @"解密后数据不为空");
        
        // 加解密后与原数据相同
        BOOL isSameDataByEcb = [decryptDataByEcb isEqualToData:self.fileData];
        XCTAssertTrue(isSameDataByEcb, @"sm4 加解密后数据不变");
        
        BOOL isSameDataByCbc = [decryptDataByCbc isEqualToData:self.fileData];
        XCTAssertTrue(isSameDataByCbc, @"sm4 加解密后数据不变");
    }
}

/**
 * 测试 sm 4 大量加解密数字英文字符字符串
 */
- (void)testSm4Str {
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
        // 生产密钥不为空
        NSString *sm4Key = [GMSm4Utils createSm4Key];
        XCTAssertNotNil(sm4Key, @"生成 sm4 密钥不为空");
        // ECB 模式
        NSString *encryptByEcb = [GMSm4Utils ecbEncrypt:plaintext Key:sm4Key];
        XCTAssertNotNil(encryptByEcb, @"加密字符串不为空");
        NSString *decryptByEcb = [GMSm4Utils ecbDecrypt:encryptByEcb Key:sm4Key];
        XCTAssertNotNil(decryptByEcb, @"解密结果不为空");
        // CBC 模式
        NSString *ivec = [GMSm4Utils createSm4Key];
        NSString *encryptByCbc = [GMSm4Utils cbcEncrypt:plaintext Key:sm4Key IV:ivec];
        XCTAssertNotNil(encryptByCbc, @"加密字符串不为空");
        NSString *decryptByCbc = [GMSm4Utils cbcDecrypt:encryptByCbc Key:sm4Key IV:ivec];
        XCTAssertNotNil(decryptByCbc, @"解密结果不为空");
        
        BOOL isSameByEcb = [decryptByEcb isEqualToString:plaintext];
        XCTAssertTrue(isSameByEcb, @"加解密结果应该相同");
        
        BOOL isSameByCbc = [decryptByCbc isEqualToString:plaintext];
        XCTAssertTrue(isSameByCbc, @"加解密结果应该相同");
    }
}

/**
 * 测试 sm4 ECB 模式加密耗时
 */
- (void)testPerformanceSm4EcbEncrypt {
    NSString *plaintext = @"123456";
    NSString *sm4Key = @"CCDEE6FB253E1CBCD40B12D5E230D0F4";
    // 加密耗时
    [self measureBlock:^{
        NSString *encryptStr = [GMSm4Utils ecbEncrypt:plaintext Key:sm4Key];
        XCTAssertNotNil(encryptStr, @"加密字符串不为空");
    }];
}

/**
 * 测试 sm4 ECB 模式解密耗时
 */
- (void)testPerformanceSm4EcbDecrypt {
    NSString *encryptStr = @"271B76936B39CEE6CAE1ABBB4539D8E7";
    NSString *sm4Key = @"CCDEE6FB253E1CBCD40B12D5E230D0F4";
    // 解密耗时
    [self measureBlock:^{
        NSString *decryptStr = [GMSm4Utils ecbDecrypt:encryptStr Key:sm4Key];
        XCTAssertNotNil(decryptStr, @"解密结果不为空");
    }];
}

/**
 * 测试 sm4 ECB 模式加密耗时
 */
- (void)testPerformanceSm4CbcEncrypt {
    NSString *plaintext = @"123456";
    NSString *sm4Key = @"26FADA370AECFB5CBCF8397BD1D8363A";
    NSString *ivec = @"685E7C9D456A5093C83606D94FE67AA5";
    // 加密耗时
    [self measureBlock:^{
        NSString *encryptStr = [GMSm4Utils cbcEncrypt:plaintext Key:sm4Key IV:ivec];
        XCTAssertNotNil(encryptStr, @"加密字符串不为空");
    }];
}

/**
 * 测试 sm4 ECB 模式解密耗时
 */
- (void)testPerformanceSm4CbcDecrypt {
    NSString *encryptStr = @"C4DDE9A8211F78584867850DF47F0128";
    NSString *sm4Key = @"26FADA370AECFB5CBCF8397BD1D8363A";
    NSString *ivec = @"685E7C9D456A5093C83606D94FE67AA5";
    // 解密耗时
    [self measureBlock:^{
        NSString *decryptStr = [GMSm4Utils cbcEncrypt:encryptStr Key:sm4Key IV:ivec];
        XCTAssertNotNil(decryptStr, @"解密结果不为空");
    }];
}

@end
