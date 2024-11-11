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

/// 测试 sm3 出现空的情况
- (void)testSm3Null {
    NSData *dataNull = [NSData data];
    NSData *digDataNull = [GMSm3Utils hashWithData:dataNull];
    XCTAssertNil(digDataNull, @"字符串为空摘要为空");
    
    NSString *textNull = nil;
    NSString *hashTextNull = [GMSm3Utils hashWithText:textNull];
    XCTAssertNil(hashTextNull, @"字符串为空摘要为空");
}

/// 测试 HMAC 出现空的情况
- (void)testHMACNull {
    NSString *keyText = @"qwertyuiop1234567890";
    NSArray *textNilArray = @[[NSNull null], @"", keyText];
    NSArray *hmacTypeList = @[@(GMHashType_SM3), @(GMHashType_MD5), @(GMHashType_SHA1),
                              @(GMHashType_SHA224), @(GMHashType_SHA256), @(GMHashType_SHA384),
                              @(GMHashType_SHA512)];
    
    for (NSInteger i = 0; i < 100; i++) {
        NSString *randText = textNilArray[arc4random_uniform((uint32_t)textNilArray.count)];
        randText = [randText isKindOfClass:[NSNull class]] ? nil : randText;
        NSString *randKeyText = textNilArray[arc4random_uniform((uint32_t)textNilArray.count)];
        randKeyText = [randKeyText isKindOfClass:[NSNull class]] ? nil : randKeyText;
        if (randText.length > 0 && randKeyText > 0) {
            continue;
        }
        NSData *randData = randText.length >= 0 ? [randText dataUsingEncoding:NSUTF8StringEncoding] : nil;
        NSData *randKeyData = randKeyText.length >= 0 ? [randKeyText dataUsingEncoding:NSUTF8StringEncoding] : nil;
        
        NSNumber *randIndex = hmacTypeList[arc4random_uniform((uint32_t)hmacTypeList.count)];
        GMHashType randType = (GMHashType)randIndex.intValue;
        // 计算 Hmac
        NSData *hmac1 = [GMSm3Utils hmacWithData:randData keyData:randKeyData];
        XCTAssertNil(hmac1, @"空值返回nil");
        NSData *hmac2 = [GMSm3Utils hmacWithData:randData keyData:randKeyData keyType:randType];
        XCTAssertNil(hmac2, @"空值返回nil");
        NSString *hmac3 = [GMSm3Utils hmacWithText:randText keyText:randKeyText];
        XCTAssertNil(hmac3, @"空值返回nil");
        NSString *hmac4 = [GMSm3Utils hmacWithText:randText keyText:randKeyText keyType:randType];
        XCTAssertNil(hmac4, @"空值返回nil");
    }
}

/// 测试对中英文混合字符串提取摘要
- (void)testSm3ZhEnStr {
    for (NSInteger i = 0; i < 1000; i++) {
        int randLen = arc4random_uniform((int)1000);
        NSString *plaintext = [self randomZhEn:randLen];
        XCTAssertTrue(plaintext.length > 0, @"生成字符串不为空");
        
        NSString *tmpHash = [GMSm3Utils hashWithText:plaintext];
        XCTAssertTrue(tmpHash.length > 0, @"生成的 Hash 字符串不为空");
    }
    // 多次摘要相同
    int randLen = arc4random_uniform((int)1000);
    NSString *plaintext = [self randomZhEn:randLen];
    XCTAssertTrue(plaintext.length > 0, @"生成字符串不为空");
    NSString *digestText = nil;
    for (NSInteger i = 0; i < 1000; i++) {
        NSString *tmpHash = [GMSm3Utils hashWithText:plaintext];
        XCTAssertTrue(tmpHash.length > 0, @"生成的 Hash 字符串不为空");
        if (digestText) {
            BOOL isSameDigest = [digestText isEqualToString:tmpHash];
            XCTAssertTrue(isSameDigest, @"多次摘要相同");
        }
        digestText = tmpHash;
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
        NSString *keyText = [self randomZhEn:keyLen];
        XCTAssertTrue(keyText.length > 0, @"生成字符串不为空");
        
        int randLen = arc4random_uniform((int)1000);
        NSString *plaintext = [self randomZhEn:randLen];
        XCTAssertTrue(plaintext.length > 0, @"生成字符串不为空");
        
        NSString *hmac1 = [GMSm3Utils hmacWithText:plaintext keyText:keyText];
        XCTAssertTrue(hmac1.length == 64, @"SM3摘要长度为64(HEX编码格式)");
    }
    // 多次摘要相同
    int keyLen = arc4random_uniform((int)1000);
    NSString *keyText = [self randomZhEn:keyLen];
    XCTAssertTrue(keyText.length > 0, @"生成字符串不为空");
    
    int randLen = arc4random_uniform((int)1000);
    NSString *plaintext = [self randomZhEn:randLen];
    XCTAssertTrue(plaintext.length > 0, @"生成字符串不为空");
    
    NSString *digestText = nil;
    for (NSInteger i = 0; i < 1000; i++) {
        NSString *tmpDigest = [GMSm3Utils hmacWithText:plaintext keyText:keyText];
        XCTAssertTrue(tmpDigest.length > 0, @"加密字符串不为空");
        if (digestText) {
            BOOL isSameDigest = [digestText isEqualToString:tmpDigest];
            XCTAssertTrue(isSameDigest, @"多次摘要相同");
        }
        digestText = tmpDigest;
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
        NSString *keyText = [self randomZhEn:keyLen];
        XCTAssertTrue(keyText.length > 0, @"生成字符串不为空");
        
        int randLen = arc4random_uniform((int)1000);
        NSString *plaintext = [self randomZhEn:randLen];
        XCTAssertTrue(plaintext.length > 0, @"生成字符串不为空");
        
        NSString *hmacHex = [GMSm3Utils hmacWithText:plaintext keyText:keyText keyType:hashType];
        XCTAssertTrue(hmacHex.length == len * 2, @"同种类型 HASH 值长度固定");
    }
    // 多次摘要相同
    int keyLen = arc4random_uniform((int)1000);
    NSString *keyText = [self randomZhEn:keyLen];
    XCTAssertTrue(keyText.length > 0, @"生成字符串不为空");
    
    int randLen = arc4random_uniform((int)1000);
    NSString *plaintext = [self randomZhEn:randLen];
    XCTAssertTrue(plaintext.length > 0, @"生成字符串不为空");
    
    NSString *digestText = nil;
    for (NSInteger i = 0; i < 1000; i++) {
        NSString *tmpDigest = [GMSm3Utils hmacWithText:plaintext keyText:keyText keyType:hashType];
        XCTAssertTrue(tmpDigest.length > 0, @"加密字符串不为空");
        if (digestText) {
            BOOL isSameDigest = [digestText isEqualToString:tmpDigest];
            XCTAssertTrue(isSameDigest, @"多次摘要相同");
        }
        digestText = tmpDigest;
    }
}

@end
