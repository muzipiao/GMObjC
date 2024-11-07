//
//  GMBaseTests.m
//  GMObjC_Tests
//
//  Created by lifei on 2019/8/18.
//  Copyright © 2019 lifei. All rights reserved.
//

#import "GMBaseTests.h"

NSString *const GMTestUserID = @"lifei_zdjl@qq.com";

@implementation GMBaseTests

- (void)setUp {
    [super setUp];
    NSLog(@"GMObjC 版本：%d", GMOBJC_VERSION_NUMBER);
    NSLog(@"GMObjC 版本：%s", GMOBJC_VERSION_TEXT);
    
    NSString *txtPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"sm4TestFile.txt" ofType:nil];
    self.fileData = [NSData dataWithContentsOfFile:txtPath];
}

- (void)tearDown {
    self.fileData = nil;
    [super tearDown];
}

// 生成中英文混合字符串
- (NSString *)randomZhEn:(NSInteger)maxLength{
    int zhEnLen = arc4random_uniform((int)maxLength);
    zhEnLen = zhEnLen >= 1 ? zhEnLen : 10; // zhEnLen 需大于1
    NSMutableString *zhEnStr = [NSMutableString stringWithCapacity:zhEnLen];
    for (NSInteger i = 0; i < zhEnLen; i++) {
        if (zhEnStr.length >= zhEnLen) {
            break;
        }
        int randType = arc4random_uniform(2);
        int surplusNum = (int)(zhEnLen - zhEnStr.length);
        int surplusRandNum = surplusNum <= 3 ? surplusNum : arc4random_uniform(surplusNum);
        if (randType % 2 == 0) {
            NSString *zh = [self randomZh:surplusRandNum];
            [zhEnStr appendString:zh];
        }else{
            NSString *en = [self randomEn:surplusRandNum];
            [zhEnStr appendString:en];
        }
    }
    return zhEnStr.copy;
}

// 随机生成ascii符串(由大小写字母、数字组成)
- (NSString *)randomEn:(NSInteger)len {
    len = len >= 1 ? len : 10;
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
    len = len >= 1 ? len : 10;
    NSMutableString *mStr = [NSMutableString stringWithCapacity:len];
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    for (NSInteger i = 0; i < len; i++) {
        NSInteger randomH = 0xA1+arc4random()%(0xFE - 0xA1+1);
        NSInteger randomL = 0xB0+arc4random()%(0xF7 - 0xB0+1);
        NSInteger number = (randomH<<8)+randomL;
        NSData *data = [NSData dataWithBytes:&number length:2];
        NSString *string = [[NSString alloc] initWithData:data encoding:gbkEncoding];
        [mStr appendString:string];
    }
    return mStr.copy;
}

// 生成任意长度任意类型的字符串
- (NSString *)randomAny:(NSInteger)maxLen{
    int randKind = arc4random_uniform((int)3);
    int randLen = arc4random_uniform((int)maxLen);
    NSString *plaintext = nil;
    if (randKind == 0) {
        plaintext = [self randomEn:randLen]; // 数字英文
    }else if (randKind == 1){
        plaintext = [self randomZh:randLen]; // 中文字符
    }else{
        plaintext = [self randomZhEn:randLen]; //中英文混合
    }
    return plaintext;
}

@end
