//
//  GMSm3Tests.m
//  GMObjC_Tests
//
//  Created by lifei on 2019/8/18.
//  Copyright © 2019 lifei. All rights reserved.
//

#import "GMBaseTests.h"

@interface GMSm3Tests : GMBaseTests

@end

@implementation GMSm3Tests

/// 测试工具类
- (void)testGMUtils {
    for (NSInteger i = 0; i < 1000; i++) {
        NSString *plaintext = [self randomAny:10000];
        XCTAssertNotNil(plaintext, @"生成字符串不为空");
        NSString *hexStr = [GMUtils stringToHex:plaintext];
        XCTAssertNotNil(hexStr, @"16 进制字符串不为空");
        NSString *originStr = [GMUtils hexToString:hexStr];
        BOOL isSameStr = [originStr isEqualToString:plaintext];
        XCTAssertTrue(isSameStr, @"明文转 Hex 可逆");
        
        NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
        XCTAssertNotNil(plainData, @"明文 Data 不为空");
        NSString *hexData = [GMUtils dataToHex:plainData];
        XCTAssertNotNil(hexData, @"明文 Data 转 Hex 不为空");
        NSData *originData = [GMUtils hexToData:hexData];
        BOOL isSameData = [originData isEqualToData:plainData];
        XCTAssertTrue(isSameData, @"明文 Data 转 Hex 可逆");
    }
}

/// 测试 sm3 出现空的情况
- (void)testSm3Null {
    NSString *strNull = nil;
    NSString *strLenZero = @"";
    NSData *dataNull = [NSData data];
    
    NSString *digStrNull = [GMSm3Utils hashWithString:strNull];
    XCTAssertNil(digStrNull, @"字符串为空摘要为空");
    
    NSString *digStrZero = [GMSm3Utils hashWithString:strLenZero];
    XCTAssertNil(digStrZero, @"字符串为空摘要为空");
    
    NSString *digDataNull = [GMSm3Utils hashWithData:dataNull];
    XCTAssertNil(digDataNull, @"字符串为空摘要为空");
}

/// 测试 HMAC 出现空的情况
- (void)testHMACNull {
    NSArray *strNilArray = @[[NSNull null], @""];
    NSArray *dataNilArray = @[[NSNull null], [NSData new]];
    NSArray *hmacTypeList = @[@(GMHashType_SM3), @(GMHashType_MD5), @(GMHashType_SHA1),
                              @(GMHashType_SHA224), @(GMHashType_SHA256), @(GMHashType_SHA384),
                              @(GMHashType_SHA512)];
    
    for (NSInteger i = 0; i < 100; i++) {
        NSNumber *typeNum = hmacTypeList[arc4random_uniform((uint32_t)hmacTypeList.count)];
        GMHashType hashType = (GMHashType)typeNum.intValue;
        
        NSString *randStr1 = strNilArray[arc4random_uniform((uint32_t)strNilArray.count)];
        randStr1 = [randStr1 isKindOfClass:[NSNull class]] ? nil : randStr1;
        NSString *randStr2 = strNilArray[arc4random_uniform((uint32_t)strNilArray.count)];
        randStr2 = [randStr2 isKindOfClass:[NSNull class]] ? nil : randStr2;
        XCTAssertNil([GMSm3Utils hmacWithSm3:randStr1 plaintext:randStr2], @"空值返回nil");
        XCTAssertNil([GMSm3Utils hmac:hashType key:randStr1 plaintext:randStr2], @"空值返回nil");
        
        NSData *randData1 = dataNilArray[arc4random_uniform((uint32_t)dataNilArray.count)];
        randData1 = [randData1 isKindOfClass:[NSNull class]] ? nil : randData1;
        NSData *randData2 = dataNilArray[arc4random_uniform((uint32_t)dataNilArray.count)];
        randData2 = [randData1 isKindOfClass:[NSNull class]] ? nil : randData2;
        XCTAssertNil([GMSm3Utils hmacWithSm3:randData1 plainData:randData2], @"空值返回nil");
        XCTAssertNil([GMSm3Utils hmac:hashType keyData:randData1 plainData:randData2], @"空值返回nil");
    }
}

/**
 * 测试对英文字符串提取摘要
 */
- (void)testSm3EnStr {
    for (NSInteger i = 0; i < 1000; i++) {
        int randLen = arc4random_uniform((int)1000);
        NSString *plaintext = [self randomEn:randLen];
        XCTAssertNotNil(plaintext, @"生成字符串不为空");
        
        NSString *tempDigStr = [GMSm3Utils hashWithString:plaintext];
        XCTAssertNotNil(tempDigStr, @"加密字符串不为空");
    }
    // 多次摘要相同
    int randLen = arc4random_uniform((int)1000);
    NSString *plaintext = [self randomEn:randLen];
    NSString *digStr = nil;
    for (NSInteger i = 0; i < 1000; i++) {
        XCTAssertNotNil(plaintext, @"生成字符串不为空");
        NSString *tempDigStr = [GMSm3Utils hashWithString:plaintext];
        XCTAssertNotNil(tempDigStr, @"加密字符串不为空");
        if (digStr) {
            BOOL isSameDig = [digStr isEqualToString:tempDigStr];
            XCTAssertTrue(isSameDig, @"多次摘要相同");
        }
        digStr = tempDigStr;
    }
}

/**
 * 测试对中文字符串提取摘要
 */
- (void)testSm3ZhStr {
    for (NSInteger i = 0; i < 1000; i++) {
        int randLen = arc4random_uniform((int)1000);
        NSString *plaintext = [self randomZh:randLen];
        XCTAssertNotNil(plaintext, @"生成字符串不为空");
        
        NSString *tempDigStr = [GMSm3Utils hashWithString:plaintext];
        XCTAssertNotNil(tempDigStr, @"加密字符串不为空");
    }
    // 多次摘要相同
    int randLen = arc4random_uniform((int)1000);
    NSString *plaintext = [self randomZh:randLen];
    NSString *digStr = nil;
    for (NSInteger i = 0; i < 1000; i++) {
        XCTAssertNotNil(plaintext, @"生成字符串不为空");
        NSString *tempDigStr = [GMSm3Utils hashWithString:plaintext];
        XCTAssertNotNil(tempDigStr, @"加密字符串不为空");
        if (digStr) {
            BOOL isSameDig = [digStr isEqualToString:tempDigStr];
            XCTAssertTrue(isSameDig, @"多次摘要相同");
        }
        digStr = tempDigStr;
    }
}

/**
 * 测试对中英文混合字符串提取摘要
 */
- (void)testSm3ZhEnStr {
    for (NSInteger i = 0; i < 1000; i++) {
        int randLen = arc4random_uniform((int)1000);
        NSString *plaintext = [self randomZhEn:randLen];
        XCTAssertNotNil(plaintext, @"生成字符串不为空");
        
        NSString *tempDigStr = [GMSm3Utils hashWithString:plaintext];
        XCTAssertNotNil(tempDigStr, @"加密字符串不为空");
    }
    // 多次摘要相同
    int randLen = arc4random_uniform((int)1000);
    NSString *plaintext = [self randomZhEn:randLen];
    NSString *digStr = nil;
    for (NSInteger i = 0; i < 1000; i++) {
        XCTAssertNotNil(plaintext, @"生成字符串不为空");
        NSString *tempDigStr = [GMSm3Utils hashWithString:plaintext];
        XCTAssertNotNil(tempDigStr, @"加密字符串不为空");
        if (digStr) {
            BOOL isSameDig = [digStr isEqualToString:tempDigStr];
            XCTAssertTrue(isSameDig, @"多次摘要相同");
        }
        digStr = tempDigStr;
    }
}

/**
 * 测试对文件提取摘要
 */
- (void)testSm3Data {
    XCTAssertNotNil(self.fileData, @"待加密 NSData 不为空");
    NSString *digStr = nil;
    for (NSInteger i = 0; i < 1000; i++) {
        NSString *tempDigStr = [GMSm3Utils hashWithData:self.fileData];
        XCTAssertNotNil(tempDigStr, @"加密字符串不为空");
        if (digStr) {
            BOOL isSameDig = [digStr isEqualToString:tempDigStr];
            XCTAssertTrue(isSameDig, @"多次摘要相同");
        }
        digStr = tempDigStr;
    }
}

// 测试 SM3 类型 HMAC 摘要
- (void)testHmacWithSm3 {
    for (NSInteger i = 0; i < 1000; i++) {
        int keyLen = arc4random_uniform((int)1000);
        NSString *key = [self randomZhEn:keyLen];
        XCTAssertNotNil(key, @"生成字符串不为空");
        
        int randLen = arc4random_uniform((int)1000);
        NSString *plaintext = [self randomZhEn:randLen];
        XCTAssertNotNil(plaintext, @"生成字符串不为空");
        
        NSString *hmac1 = [GMSm3Utils hmacWithSm3:key plaintext:plaintext];
        XCTAssertTrue(hmac1.length == 64, @"长度为64");
        
        NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
        NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
        NSString *hmac2 = [GMSm3Utils hmacWithSm3:keyData plainData:plainData];
        XCTAssertTrue([hmac1 isEqualToString:hmac2], @"相同数据不同类型摘要相同");
    }
    // 多次摘要相同
    int keyLen = arc4random_uniform((int)1000);
    NSString *keyText = [self randomZhEn:keyLen];
    XCTAssertNotNil(keyText, @"生成字符串不为空");
    
    int randLen = arc4random_uniform((int)1000);
    NSString *plaintext = [self randomZhEn:randLen];
    XCTAssertNotNil(plaintext, @"生成字符串不为空");
    
    NSString *digStr = nil;
    for (NSInteger i = 0; i < 1000; i++) {
        NSString *tempDigStr = [GMSm3Utils hmacWithSm3:keyText plaintext:plaintext];
        XCTAssertNotNil(tempDigStr, @"加密字符串不为空");
        if (digStr) {
            BOOL isSameDig = [digStr isEqualToString:tempDigStr];
            XCTAssertTrue(isSameDig, @"多次摘要相同");
        }
        digStr = tempDigStr;
    }
}

// 测试其他类型 HMAC 摘要
- (void)testHmacWithOtherType {
    [self hmacWithType:GMHashType_SM3 hashLen:64];
    [self hmacWithType:GMHashType_MD5 hashLen:32];
    [self hmacWithType:GMHashType_SHA1 hashLen:40];
    [self hmacWithType:GMHashType_SHA224 hashLen:56];
    [self hmacWithType:GMHashType_SHA256 hashLen:64];
    [self hmacWithType:GMHashType_SHA384 hashLen:96];
    [self hmacWithType:GMHashType_SHA512 hashLen:128];
}

- (void)hmacWithType:(GMHashType)hashType hashLen:(int)len {
    for (NSInteger i = 0; i < 1000; i++) {
        int keyLen = arc4random_uniform((int)1000);
        NSString *key = [self randomZhEn:keyLen];
        XCTAssertNotNil(key, @"生成字符串不为空");
        
        int randLen = arc4random_uniform((int)1000);
        NSString *plaintext = [self randomZhEn:randLen];
        XCTAssertNotNil(plaintext, @"生成字符串不为空");
        
        NSString *hmac1 = [GMSm3Utils hmac:hashType key:key plaintext:plaintext];
        XCTAssertTrue(hmac1.length == len, @"同种类型 HASH 值长度固定");
        
        NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
        NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString *hmac2 = [GMSm3Utils hmac:hashType keyData:keyData plainData:plainData];
        XCTAssertTrue([hmac1 isEqualToString:hmac2], @"相同数据不同类型摘要相同");
    }
    // 多次摘要相同
    int keyLen = arc4random_uniform((int)1000);
    NSString *keyText = [self randomZhEn:keyLen];
    XCTAssertNotNil(keyText, @"生成字符串不为空");
    
    int randLen = arc4random_uniform((int)1000);
    NSString *plaintext = [self randomZhEn:randLen];
    XCTAssertNotNil(plaintext, @"生成字符串不为空");
    
    NSString *digStr = nil;
    for (NSInteger i = 0; i < 1000; i++) {
        NSString *tempDigStr = [GMSm3Utils hmac:hashType key:keyText plaintext:plaintext];
        XCTAssertNotNil(tempDigStr, @"加密字符串不为空");
        if (digStr) {
            BOOL isSameDig = [digStr isEqualToString:tempDigStr];
            XCTAssertTrue(isSameDig, @"多次摘要相同");
        }
        digStr = tempDigStr;
    }
}

@end
