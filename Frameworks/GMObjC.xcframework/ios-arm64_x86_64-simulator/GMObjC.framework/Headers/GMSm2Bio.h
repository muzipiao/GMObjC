//
//  GMSm2Bio.h
//  GMObjC_Example
//
//  Created by lifei on 2021/4/24.
//  Copyright © 2021 lifei. All rights reserved.
/**
 * SM2 密钥类文件 IO 操作，PEM/DER/CER/PKCS#12 等格式公私钥读取或创建
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 读取的证书信息
@interface GMSm2X509Info : NSObject

@property (nullable, nonatomic, copy) NSString *version;              // 证书的版本号
@property (nullable, nonatomic, copy) NSString *publicKey;            // 公钥(HEX 格式)
@property (nullable, nonatomic, copy) NSString *privateKey;           // 私钥(HEX 格式，PKCS#12格式可能包含)
@property (nullable, nonatomic, copy) NSString *effectiveDate;        // 生效日期，日期格式(UTC时间) yyyyMMddHHmmss
@property (nullable, nonatomic, copy) NSString *expirationDate;       // 失效日期，日期格式(UTC时间) yyyyMMddHHmmss
@property (nullable, nonatomic, copy) NSString *serialNumber;         // 证书的序列号
@property (nullable, nonatomic, copy) NSString *signature;            // 签名算法的值
@property (nullable, nonatomic, copy) NSString *signatureAlgorithm;   // 签名算法类型
@property (nullable, nonatomic, copy) NSString *sha1Fingerprint;      // 指纹(SHA-1)
@property (nullable, nonatomic, copy) NSString *sha256Fingerprint;    // 指纹(SHA-256)

@property (nullable, nonatomic, copy) NSString *country;              // 证书的国家代码
@property (nullable, nonatomic, copy) NSString *commonName;           // 证书的通用名称
@property (nullable, nonatomic, copy) NSString *organization;         // 证书的组织名称
@property (nullable, nonatomic, copy) NSString *organizationalUnit;   // 证书的组织单位名称

@property (nullable, nonatomic, copy) NSString *issuerCountry;            // 颁发机构的国家代码
@property (nullable, nonatomic, copy) NSString *issuerCommonName;         // 颁发机构的通用名称
@property (nullable, nonatomic, copy) NSString *issuerOrganization;       // 颁发机构的组织名称
@property (nullable, nonatomic, copy) NSString *issuerOrganizationalUnit; // 颁发机构的组织单位名称

@end

// 生成的PEM/DER格式公私钥文件路径
@interface GMSm2KeyFiles : NSObject

@property (nullable, nonatomic, copy) NSString *publicKeyPath;
@property (nullable, nonatomic, copy) NSString *privateKeyPath;

@end

@interface GMSm2Bio : NSObject

// MARK: - 读取PEM格式秘钥
/// 从 PEM 文件中读取 SM2 公钥，返回 HEX 格式公钥
/// @param pemData PEM 格式公钥数据
/// @param pwdData PEM 格式证书密码，无密码时传入 nil
+ (nullable NSString *)readPublicKeyFromPemData:(NSData *)pemData password:(nullable NSData *)pwdData;

/// 从 PEM 文件中读取 SM2 私钥，返回 HEX 格式私钥
/// @param pemData PEM 格式私钥数据
/// @param pwdData PEM 格式证书密码，无密码时传入 nil
+ (nullable NSString *)readPrivateKeyFromPemData:(NSData *)pemData password:(nullable NSData *)pwdData;

// MARK: - 读取DER格式秘钥
/// 从 DER 文件中读取 SM2 公钥，返回 HEX 格式公钥
/// @param derData DER 格式公钥数据
+ (nullable NSString *)readPublicKeyFromDerData:(NSData *)derData;

/// 从 DER 文件中读取 SM2 私钥，返回 HEX 格式私钥
/// @param derData DER 格式私钥数据
+ (nullable NSString *)readPrivateKeyFromDerData:(NSData *)derData;

// MARK: - 写入PEM/DER格式文件
/// 将公钥/私钥写入PEM文件，返回YES成功，NO失败
/// @param publicHex 04 开头的公钥，privateHex 私钥（ 皆为HEX 编码格式）
/// @param filePath PEM文件存储路径
+ (BOOL)savePublicKey:(NSString *)publicHex toPemFileAtPath:(NSString *)filePath;
+ (BOOL)savePrivateKey:(NSString *)privateHex toPemFileAtPath:(NSString *)filePath;

/// 将公钥/私钥写入DER文件，返回YES成功，NO失败
/// @param publicHex 04 开头的公钥，privateHex 私钥（ 皆为HEX 编码格式）
/// @param filePath DER文件存储路径
+ (BOOL)savePublicKey:(NSString *)publicHex toDerFileAtPath:(NSString *)filePath;
+ (BOOL)savePrivateKey:(NSString *)privateHex toDerFileAtPath:(NSString *)filePath;

// MARK: - PEM & DER 字符互转
/// 将 PEM 格式公私钥转换为 DER 格式
/// @param pemData PEM格式密钥数据
/// @param isPublicKey 标记 derData 是公钥/私钥，YES为公钥，NO为私钥
+ (nullable NSData *)convertPemToDer:(NSData *)pemData isPublicKey:(BOOL)isPublicKey;

/// 将 DER 格式公私钥转换为 PEM 格式
/// @param derData DER格式密钥数据
/// @param isPublicKey 标记 derData 是公钥/私钥，YES为公钥，NO为私钥
+ (nullable NSData *)convertDerToPem:(NSData *)derData isPublicKey:(BOOL)isPublicKey;

// MARK: - 读取证书
/// 从证书文件中读取证书信息，读取的公私钥可能非 SM2 密钥信息(可能是 RSA)
/// @param cerData 证书文件数据
/// @param pwdData 证书密码，默认为空
+ (nullable GMSm2X509Info *)readX509InfoFromData:(NSData *)cerData password:(nullable NSData *)pwdData;

// MARK: - 创建PEM/DER格式公私钥
/// 创建 PEM 格式 SM2 公私钥，默认保存tmp文件夹下。
/// 返回值：数组元素 1 为公钥sm2-pub.pem/.der路径，2 为私钥sm2-pri.pem/.der路径
+ (GMSm2KeyFiles *)generatePemKeyFiles;
+ (GMSm2KeyFiles *)generateDerKeyFiles;

@end

NS_ASSUME_NONNULL_END
