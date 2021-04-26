//
//  GMSm3Utils.m
//  BaseDemo
//
//  Created by lifei on 2019/8/2.
//  Copyright © 2019 lifei. All rights reserved.
//

#import "GMSm3Utils.h"
#import <openssl/sm3.h>
#import "GMUtils.h"

@implementation GMSm3Utils

// OpenSSL 1.1.1 以上版本支持国密
+ (void)initialize
{
    if (self == [GMSm3Utils class]) {
        if (OPENSSL_VERSION_NUMBER < 0x1010100fL) {
            GMLog(@"OpenSSL 当前版本：%s",OPENSSL_VERSION_TEXT);
            NSAssert(NO, @"OpenSSL 版本低于 1.1.1，不支持国密");
        }
    }
}

///MARK: - 字符串的摘要值
+ (nullable NSString *)hashWithString:(NSString *)plaintext{
    if (!plaintext || plaintext.length == 0) {
        return nil;
    }
    NSData *strData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
    NSString *digStr = [self hashWithData:strData];
    return digStr;
}

///MARK: - 文件的摘要值
+ (nullable NSString *)hashWithData:(NSData *)plainData{
    if (!plainData || plainData.length == 0) {
        return nil;
    }
    // 原文
    uint8_t *pData = (uint8_t *)plainData.bytes;
    // 摘要结果
    SM3_CTX ctx;
    unsigned char output[SM3_DIGEST_LENGTH];
    memset(output, 0, SM3_DIGEST_LENGTH);
    do {
        if (!sm3_init(&ctx)) {
            break;
        }
        size_t pDataLen = plainData.length;
        if (!sm3_update(&ctx, pData, pDataLen)) {
            break;
        }
        if (!sm3_final(output, &ctx)) {
            break;
        }
        memset(&ctx, 0, sizeof(SM3_CTX));
    } while (NO);
    // 转为 16 进制
    NSMutableString *digestStr = [NSMutableString stringWithCapacity:SM3_DIGEST_LENGTH];
    for (NSInteger i = 0; i < SM3_DIGEST_LENGTH; i++) {
        NSString *subStr = [NSString stringWithFormat:@"%X",output[i]&0xff];
        if (subStr.length == 1) {
            [digestStr appendFormat:@"0%@", subStr];
        }else{
            [digestStr appendString:subStr];
        }
    }
    return digestStr;
}

@end
