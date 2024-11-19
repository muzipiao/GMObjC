//  Created by lifei on 2023/9/14.
//  参考 issue 反馈，总结遇到的问题，协助分析；
//  用于测试环境排查故障，不能用于生产环境。

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GMDoctor : NSObject
#ifdef DEBUG

// 检查 SM2 加密
+ (void)checkSm2Encrypt:(NSData *)plainData publicKey:(NSString *)publicKey;
// 检查 SM2 解密
+ (void)checkSm2Decrypt:(NSData *)cipherData privateKey:(NSString *)privateKey;
// 检查 SM2 签名
+ (void)checkSignData:(NSData *)plainData privateKey:(NSString *)privateKey userData:(nullable NSData *)userData;
// 检查 SM2 验签
+ (void)checkVerifyData:(NSData *)plainData signRS:(NSString *)signRS publicKey:(NSString *)publicKey userData:(nullable NSData *)userData;
// 检查 SM2 公钥
+ (void)checkSm2PublicKey:(NSString *)publicKey;
// 检查 SM2 私钥
+ (void)checkSm2PrivateKey:(NSString *)privateKey;
// 检查 OpenSSL 环境
+ (void)checkEnvironment;

#endif
@end

NS_ASSUME_NONNULL_END
