//
//  GMBaseTests.m
//  GMObjC_Tests
//
//  Created by lifei on 2019/8/18.
//  Copyright © 2019 lifei. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GMObjC.h"

static NSString *gPubkey = @"0408E3FFF9505BCFAF9307E665E9229F4E1B3936437A870407EA3D97886BAFBC9C624537215DE9507BC0E2DD276CF74695C99DF42424F28E9004CDE4678F63D698";
static NSString *gPrivkey = @"90F3A42B9FE24AB196305FD92EC82E647616C3A3694441FB3422E7838E24DEAE";


@interface GMBaseTests : XCTestCase

// sm4 加解密文件测试
@property (nonatomic, strong) NSData *fileData;

// 生成中英文混合字符串
- (NSString *)randomZhEnString:(NSInteger)maxLength;

// 随机生成ascii符串(由大小写字母、数字组成)
- (NSString *)randomEn:(NSInteger)len;

// 随机生成汉字字符串
-(NSString *)randomZh:(NSInteger)len;

@end
