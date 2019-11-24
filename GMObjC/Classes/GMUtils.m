//
//  Sm2HexUtils.m
//  GMPro
//
//  Created by lifei on 2019/7/18.
//  Copyright © 2019 lifei. All rights reserved.
//

#import "GMUtils.h"
#import <openssl/crypto.h>

@implementation GMUtils

///MARK: - Hex 编码

+ (nullable NSString *)stringToHex:(NSString *)str{
    if (!str || str.length == 0) {
        return nil;
    }
    NSData *strData = [str dataUsingEncoding:NSUTF8StringEncoding];
    Byte *strBytes = (Byte *)[strData bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[strData length];i++)
    {
        @autoreleasepool{
            NSString *newHexStr = [NSString stringWithFormat:@"%X",strBytes[i]&0xff];///16进制数
            if([newHexStr length]==1){
                hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
            }else{
                hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
            }
        }
    }
    return hexStr;
}

+ (nullable NSString *)dataToHex:(NSData *)data{
    if (!data || data.length == 0) {
        return nil;
    }
    Byte *strBytes = (Byte *)[data bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++)
    {
        @autoreleasepool{
            NSString *newHexStr = [NSString stringWithFormat:@"%X",strBytes[i]&0xff];///16进制数
            if([newHexStr length]==1){
                hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
            }else{
                hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
            }
        }
    }
    return hexStr;
}

///MARK: - Hex 解码

+ (nullable NSString *)hexToString:(NSString *)hexStr{
    if (!hexStr || hexStr.length == 0) {
        return nil;
    }
    char *myBuffer = (char *)malloc((int)(hexStr.length / 2) + 1);
    bzero(myBuffer, hexStr.length / 2 + 1);
    for (int i = 0; i < hexStr.length - 1; i += 2) {
        @autoreleasepool{
            unsigned int anInt;
            NSString * hexCharStr = [hexStr substringWithRange:NSMakeRange(i, 2)];
            NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
            [scanner scanHexInt:&anInt];
            myBuffer[i / 2] = (char)anInt;
        }
    }
    
    NSString *utfStr = [NSString stringWithCString:myBuffer encoding:NSUTF8StringEncoding];
    free(myBuffer);
    
    return utfStr;
}

+ (nullable NSData *)hexToData:(NSString *)hexStr{
    if (!hexStr || hexStr.length == 0) {
        return nil;
    }
    size_t result_len = hexStr.length / 2;
    uint8_t *myBuffer = (uint8_t *)malloc((int)(result_len) + 1);
    bzero(myBuffer, result_len + 1);
    for (int i = 0; i < hexStr.length - 1; i += 2) {
        @autoreleasepool{
            unsigned int anInt;
            NSString * hexCharStr = [hexStr substringWithRange:NSMakeRange(i, 2)];
            NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
            [scanner scanHexInt:&anInt];
            myBuffer[i / 2] = (uint8_t)anInt;
        }
    }
    
    NSData *data = [NSData dataWithBytes:myBuffer length:result_len];
    free(myBuffer);
    
    return data;
}


@end
