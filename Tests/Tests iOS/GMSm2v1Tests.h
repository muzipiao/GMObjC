//
//  GMSm2Tests.h
//  GMObjC
//
//  Created by lif on 2020/7/10.
//  Copyright © 2020 lifei. All rights reserved.
//

#import "GMBaseTests.h"

@interface GMSm2v1Tests : GMBaseTests

@property (nonatomic, copy) NSString *gPubKey;          // 公钥
@property (nonatomic, copy) NSString *gPriKey;          // 私钥
@property (nonatomic, copy) NSString *gCipherText;      // 解密结果为 Text
@property (nonatomic, copy) NSString *gCipherHex;       // 解密结果为 Hex
@property (nonatomic, copy) NSString *gCipherDataHex;   // 解密结果为 NSData

@end
