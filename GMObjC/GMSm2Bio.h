//
//  GMSm2Bio.h
//  GMObjC_Example
//
//  Created by lifei on 2021/4/24.
//  Copyright © 2021 lifei. All rights reserved.
/**
 * SM2 密钥类 IO 操作，PEM/DER 格式公私钥读取或创建
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GMSm2Bio : NSObject

///MARK: - 读取PEM格式秘钥
/// 从PEM文件中读取SM2公钥或者私钥
/// @param filePath PEM格式文件路径
+ (nullable NSString *)readPublicKeyFromPemFile:(NSString *)filePath;
+ (nullable NSString *)readPrivateKeyFromPemFile:(NSString *)filePath;

/// 从PEM字符串中获取SM2公钥或者私钥
/// @param pemStr PEM格式的公钥或者私钥字符串
+ (nullable NSString *)readPublicKeyFromPemString:(NSString *)pemStr;
+ (nullable NSString *)readPrivateKeyFromPemString:(NSString *)pemStr;

///MARK: - 读取DER格式秘钥
/// 从DER文件中读取SM2公钥或者私钥
/// @param filePath DER格式文件路径
+ (nullable NSString *)readPublicKeyFromDerFile:(NSString *)filePath;
+ (nullable NSString *)readPrivateKeyFromDerFile:(NSString *)filePath;

/// 从DER内存数据中读取SM2公钥或者私钥
/// @param derData DER格式数据
+ (nullable NSString *)readPublicKeyFromDerData:(NSData *)derData;
+ (nullable NSString *)readPrivateKeyFromDerData:(NSData *)derData;

///MARK: - 写入PEM/DER格式文件
/// 将公钥/私钥写入PEM文件，返回YES成功，NO失败
/// @param publicKey 04 开头的公钥，privateKey私钥（ 皆为Hex 编码格式）
/// @param filePath PEM文件存储路径
+ (BOOL)savePublicKeyToPemFile:(NSString *)publicKey filePath:(NSString *)filePath;
+ (BOOL)savePrivateKeyToPemFile:(NSString *)privateKey filePath:(NSString *)filePath;

/// 将公钥/私钥写入DER文件，返回YES成功，NO失败
/// @param publicKey 04 开头的公钥，privateKey私钥（ 皆为Hex 编码格式）
/// @param filePath DER文件存储路径
+ (BOOL)savePublicKeyToDerFile:(NSString *)publicKey filePath:(NSString *)filePath;
+ (BOOL)savePrivateKeyToDerFile:(NSString *)privateKey filePath:(NSString *)filePath;

///MARK: - PEM & DER 字符互转
/// PEM 格式与 DER格式互转
/// @param pemStr PEM格式字符串 derData DER格式秘钥 isPublic YES为公钥，NO为私钥
+ (nullable NSData *)convertPemToDer:(NSString *)pemStr;
+ (nullable NSString *)convertDerToPem:(NSData *)derData public:(BOOL)isPublic;

///MARK: - 创建PEM/DER格式公私钥
/// 创建 PEM 格式 SM2 公私钥，默认保存tmp文件夹下。
/// 返回值：数组元素 1 为公钥sm2-pub.pem/.der路径，2 为私钥sm2-pri.pem/.der路径
+ (NSArray<NSString *> *)createPemKeyPairFiles;
+ (NSArray<NSString *> *)createDerKeyPairFiles;

///MARK: - 椭圆曲线类型
/// 常见椭圆曲线为 NID_sm2、NID_secp256k1、NID_X9_62_prime256v1
/// 默认 NID_sm2，参考 GMObjCDef.h 中说明，一般不需更改
/// 若需要更改，传入枚举 GMCurveType 枚举值即可，枚举定义在GMObjCDef.h
/// 若需要其他曲线，在 OpenSSL 源码 crypto/ec/ec_curve.c 查找
+ (int)ellipticCurveType;
+ (void)setEllipticCurveType:(int)curveType;

@end

NS_ASSUME_NONNULL_END
