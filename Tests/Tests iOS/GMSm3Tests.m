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
        NSString *hexStr = [GMSmUtils hexStringFromString:plaintext];
        XCTAssertNotNil(hexStr, @"16 进制字符串不为空");
        NSString *originStr = [GMSmUtils stringFromHexString:hexStr];
        BOOL isSameStr = [originStr isEqualToString:plaintext];
        XCTAssertTrue(isSameStr, @"明文转 Hex 可逆");
        
        NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
        XCTAssertNotNil(plainData, @"明文 Data 不为空");
        NSString *hexData = [GMSmUtils hexStringFromData:plainData];
        XCTAssertNotNil(hexData, @"明文 Data 转 Hex 不为空");
        NSData *originData = [GMSmUtils dataFromHexString:hexData];
        BOOL isSameData = [originData isEqualToData:plainData];
        XCTAssertTrue(isSameData, @"明文 Data 转 Hex 可逆");
    }
}

/// 测试 sm3 出现空的情况
- (void)testSm3Null {
    NSData *dataNull = [NSData data];
    NSData *digDataNull = [GMSm3Utils hashWithData:dataNull];
    XCTAssertNil(digDataNull, @"字符串为空摘要为空");
}

/// 测试 HMAC 出现空的情况
- (void)testHMACNull {
    NSArray *dataNilArray = @[[NSNull null], [NSData data]];
    NSArray *hmacTypeList = @[@(GMHashType_SM3), @(GMHashType_MD5), @(GMHashType_SHA1),
                              @(GMHashType_SHA224), @(GMHashType_SHA256), @(GMHashType_SHA384),
                              @(GMHashType_SHA512)];
    
    for (NSInteger i = 0; i < 100; i++) {
        NSData *randData = dataNilArray[arc4random_uniform((uint32_t)dataNilArray.count)];
        randData = [randData isKindOfClass:[NSNull class]] ? nil : randData;
        NSData *randKey = dataNilArray[arc4random_uniform((uint32_t)dataNilArray.count)];
        randKey = [randKey isKindOfClass:[NSNull class]] ? nil : randKey;
        NSNumber *randIndex = hmacTypeList[arc4random_uniform((uint32_t)hmacTypeList.count)];
        GMHashType randType = (GMHashType)randIndex.intValue;
        // 计算 Hmac
        NSData *hmac1 = [GMSm3Utils hmacWithData:randData keyData:randKey];
        XCTAssertNil(hmac1, @"空值返回nil");
        NSData *hmac2 = [GMSm3Utils hmacWithData:randData keyData:randKey keyType:randType];
        XCTAssertNil(hmac2, @"空值返回nil");
    }
}

/// 测试对中英文混合字符串提取摘要
- (void)testSm3ZhEnStr {
    for (NSInteger i = 0; i < 1000; i++) {
        int randLen = arc4random_uniform((int)1000);
        NSString *plaintext = [self randomZhEn:randLen];
        NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
        XCTAssertNotNil(plainData, @"生成字符串不为空");
        
        NSData *tempDigData = [GMSm3Utils hashWithData:plainData];
        XCTAssertNotNil(tempDigData, @"加密字符串不为空");
    }
    // 多次摘要相同
    int randLen = arc4random_uniform((int)1000);
    NSString *plaintext = [self randomZhEn:randLen];
    NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
    NSData *digData = nil;
    for (NSInteger i = 0; i < 1000; i++) {
        XCTAssertNotNil(plainData, @"生成字符串不为空");
        NSData *tempDigData = [GMSm3Utils hashWithData:plainData];
        XCTAssertNotNil(tempDigData, @"加密字符串不为空");
        if (digData) {
            BOOL isSameDig = [digData isEqualToData:tempDigData];
            XCTAssertTrue(isSameDig, @"多次摘要相同");
        }
        digData = tempDigData;
    }
}

/// 测试对文件提取摘要
- (void)testSm3Data {
    XCTAssertNotNil(self.fileData, @"待加密 NSData 不为空");
    NSData *digData = nil;
    for (NSInteger i = 0; i < 1000; i++) {
        NSData *tempDigData = [GMSm3Utils hashWithData:self.fileData];
        XCTAssertNotNil(tempDigData, @"加密字符串不为空");
        if (digData) {
            BOOL isSameDig = [digData isEqualToData:tempDigData];
            XCTAssertTrue(isSameDig, @"多次摘要相同");
        }
        digData = tempDigData;
    }
}

// 测试 SM3 类型 HMAC 摘要
- (void)testHmacWithSm3 {
    for (NSInteger i = 0; i < 1000; i++) {
        int keyLen = arc4random_uniform((int)1000);
        NSString *key = [self randomZhEn:keyLen];
        NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
        XCTAssertNotNil(keyData, @"生成字符串不为空");
        
        int randLen = arc4random_uniform((int)1000);
        NSString *plaintext = [self randomZhEn:randLen];
        NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
        XCTAssertNotNil(plainData, @"生成字符串不为空");
        NSData *hmac1 = [GMSm3Utils hmacWithData:plainData keyData:keyData];
        XCTAssertTrue(hmac1.length == 32, @"长度为32");
    }
    // 多次摘要相同
    int keyLen = arc4random_uniform((int)1000);
    NSString *keyText = [self randomZhEn:keyLen];
    NSData *keyData = [keyText dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertNotNil(keyData, @"生成字符串不为空");
    
    int randLen = arc4random_uniform((int)1000);
    NSString *plaintext = [self randomZhEn:randLen];
    NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertNotNil(plainData, @"生成字符串不为空");
    
    NSData *digData = nil;
    for (NSInteger i = 0; i < 1000; i++) {
        NSData *tempDigData = [GMSm3Utils hmacWithData:plainData keyData:keyData];
        XCTAssertNotNil(tempDigData, @"加密字符串不为空");
        if (digData) {
            BOOL isSameDig = [digData isEqualToData:tempDigData];
            XCTAssertTrue(isSameDig, @"多次摘要相同");
        }
        digData = tempDigData;
    }
}

// 测试其他类型 HMAC 摘要
- (void)testHmacWithOtherType {
    [self hmacWithType:GMHashType_SM3 hashLen:32];
    [self hmacWithType:GMHashType_MD5 hashLen:16];
    [self hmacWithType:GMHashType_SHA1 hashLen:20];
    [self hmacWithType:GMHashType_SHA224 hashLen:28];
    [self hmacWithType:GMHashType_SHA256 hashLen:32];
    [self hmacWithType:GMHashType_SHA384 hashLen:48];
    [self hmacWithType:GMHashType_SHA512 hashLen:64];
}

- (void)hmacWithType:(GMHashType)hashType hashLen:(int)len {
    for (NSInteger i = 0; i < 1000; i++) {
        int keyLen = arc4random_uniform((int)1000);
        NSString *key = [self randomZhEn:keyLen];
        NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
        XCTAssertNotNil(keyData, @"生成字符串不为空");
        
        int randLen = arc4random_uniform((int)1000);
        NSString *plaintext = [self randomZhEn:randLen];
        NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
        XCTAssertNotNil(plainData, @"生成字符串不为空");
        
        NSData *hmac1 = [GMSm3Utils hmacWithData:plainData keyData:keyData keyType:hashType];;
        XCTAssertTrue(hmac1.length == len, @"同种类型 HASH 值长度固定");
    }
    // 多次摘要相同
    int keyLen = arc4random_uniform((int)1000);
    NSString *keyText = [self randomZhEn:keyLen];
    NSData *keyData = [keyText dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertNotNil(keyData, @"生成字符串不为空");
    
    int randLen = arc4random_uniform((int)1000);
    NSString *plaintext = [self randomZhEn:randLen];
    NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertNotNil(plainData, @"生成字符串不为空");
    
    NSData *digData = nil;
    for (NSInteger i = 0; i < 1000; i++) {
        NSData *tempDigData = [GMSm3Utils hmacWithData:plainData keyData:keyData keyType:hashType];
        XCTAssertNotNil(tempDigData, @"加密字符串不为空");
        if (digData) {
            BOOL isSameDig = [digData isEqualToData:tempDigData];
            XCTAssertTrue(isSameDig, @"多次摘要相同");
        }
        digData = tempDigData;
    }
}

@end
