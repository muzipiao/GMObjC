//
//  GMBaseTests.m
//  GMObjC_Tests
//
//  Created by lifei on 2019/8/18.
//  Copyright © 2019 lifei. All rights reserved.
//

#import "GMBaseTests.h"

@implementation GMBaseTests

- (void)setUp {
    [super setUp];
    NSString *txtPath = [[NSBundle mainBundle] pathForResource:@"sm4TestFile.txt" ofType:nil];
    self.fileData = [NSData dataWithContentsOfFile:txtPath];
}

- (void)tearDown {
    self.fileData = nil;
    [super tearDown];
}

/**
 * 测试工具类
 */
- (void)testGMUtils {
    int randLen = arc4random_uniform((int)10000);
    NSString *plaintext = [self randomEn:randLen];
    XCTAssertNotNil(plaintext, @"生成字符串不为空");
    
    NSString *colonStr = [GMUtils addColon:plaintext];
    XCTAssertNotNil(colonStr, @"添加冒号字符串不为空");
    
    NSString *hexStr = [GMUtils stringToHex:plaintext];
    XCTAssertNotNil(hexStr, @"16 进制字符串不为空");
    
    NSString *originStr = [GMUtils hexToString:hexStr];
    XCTAssertNotNil(originStr, @"16 进制转原文不为空");
}

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
