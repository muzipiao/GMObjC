//
//  GMBaseTests.m
//  GMObjC_Tests
//
//  Created by lifei on 2019/8/18.
//  Copyright © 2019 lifei. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GMObjC.h"

FOUNDATION_EXPORT NSString *const GMTestUserID; // 测试 ID

@interface GMBaseTests : XCTestCase

// sm4 加解密文件测试
@property (nonatomic, strong) NSData *fileData;

/// 生成中英文混合字符串
/// @param maxLength 字符串最大长度
- (NSString *)randomZhEn:(NSInteger)maxLength;

/// 随机生成ascii符串(由大小写字母、数字组成)
/// @param len 字符串长度
- (NSString *)randomEn:(NSInteger)len;

/// 随机生成汉字字符串
/// @param len 字符串长度
- (NSString *)randomZh:(NSInteger)len;

/// 随机生成任意长度任意一种字符串
/// @param maxLen 字符串最大长度
- (NSString *)randomAny:(NSInteger)maxLen;

@end
