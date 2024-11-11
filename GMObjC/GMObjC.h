//  Created by lifei on 2019/8/2.
//  Copyright © 2019 lifei. All rights reserved.
/**
 * 基于 OpenSSL 对国密 SM2 非对称加密、SM2 签名验签、ECDH 密钥协商、SM3 摘要算法，SM4 对称加密做 OC 封装。
 * GMSm2Utils SM2 非对称加解密及签名验签，ECDH密钥协商
 * GMSm2Bio PEM/DER 格式公私钥读取或创建
 * GMSm3Utils SM3 摘要提取，HMAC 计算
 * GMSm4Utils SM4 对称加解密，含ECB和CBC模式
 * GMSmUtils  工具类，16进制编码解码等
 * GMDoctor 问题诊断，仅用于 Debug 环境调试检查可能遇到的问题
 */

#import <Foundation/Foundation.h>

#define GMOBJC_VERSION_NUMBER  0x400000
#define GMOBJC_VERSION_TEXT    "GMObjC 4.0.0  08 Nov 2024"

#if __has_include(<GMObjC/GMSm2Bio.h>)
#import <GMObjC/GMSm2Bio.h>
#import <GMObjC/GMSm2Utils.h>
#import <GMObjC/GMSm3Utils.h>
#import <GMObjC/GMSm4Utils.h>
#import <GMObjC/GMSmUtils.h>
#import <GMObjC/GMDoctor.h>
#else
#import "GMSm2Bio.h"
#import "GMSm2Utils.h"
#import "GMSm3Utils.h"
#import "GMSm4Utils.h"
#import "GMSmUtils.h"
#import "GMDoctor.h"
#endif
