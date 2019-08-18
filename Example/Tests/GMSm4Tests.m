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

@end
