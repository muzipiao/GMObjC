//
//  Sm2HexUtils.m
//  GMPro
//
//  Created by lifei on 2019/7/18.
//  Copyright © 2019 lifei. All rights reserved.
//

#import "GMCodecUtils.h"

@implementation GMCodecUtils

///MARK: - 编码为 16 进制字符串
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

///MARK: - 16 字符串解码
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

///MARK: - 字符串每两位加冒号
+(nullable NSString *)addColon:(NSString *)str{
    if (!str || str.length == 0) {
        return nil;
    }
    if (str.length < 3) {
        return str;
    }
    NSString *lastStr = @"";
    if (str.length % 2 != 0) {
        lastStr = [str substringFromIndex:str.length - 1];
        str = [str substringToIndex:str.length - 1];
    }
    NSUInteger len = str.length + (NSUInteger)(str.length / 2);
    NSMutableString *mstr = [NSMutableString stringWithCapacity:len];
    for (NSInteger i = 0; i < str.length - 1; i+=2) {
        @autoreleasepool{
            NSString *sub = [str substringWithRange:NSMakeRange(i, 2)];
            [mstr appendString:sub];
            if (i < str.length - 2) {
                [mstr appendString:@":"];
            }
        }
    }
    if (lastStr.length > 0) {
        [mstr appendFormat:@":%@", lastStr];
    }
    return mstr.copy;
}

@end
