# GMObjC

[![CI Status](https://img.shields.io/travis/muzipiao/GMObjC.svg?style=flat)](https://travis-ci.org/muzipiao/GMObjC)
[![codecov](https://codecov.io/gh/muzipiao/GMObjC/branch/master/graph/badge.svg)](https://codecov.io/gh/muzipiao/GMObjC)
[![Version](https://img.shields.io/cocoapods/v/GMObjC.svg?style=flat)](https://cocoapods.org/pods/GMObjC)
[![License](https://img.shields.io/cocoapods/l/GMObjC.svg?style=flat)](https://cocoapods.org/pods/GMObjC)
[![Platform](https://img.shields.io/cocoapods/p/GMObjC.svg?style=flat)](https://cocoapods.org/pods/GMObjC)

OpenSSL 1.1.1 以上版本增加了对中国 SM2/SM3/SM4 加密算法的支持，基于 OpenSSL 对国密 SM2 非对称加密、SM2 签名验签、ECDH 密钥协商、SM3 摘要算法，SM4 对称加密做 OC 封装。

## 快速开始

在终端运行以下命令:

```ruby
git clone https://github.com/muzipiao/GMObjC.git

cd GMObjC/Example

pod install

open GMObjC.xcworkspace
```

## 环境需求

OpenSSL 1.1.1 以上版本，已打包为 Framework，并上传 cocoapods，可拖入直接安装或使用 cocoapods 安装，导入系统框架 Security.framework。

* [GMOpenSSL.framework](https://github.com/muzipiao/GMOpenSSL)(openssl.framework)
* Security.framework

## 集成

### CocoaPods

CocoaPods 是最简单方便的集成方法，编辑 Podfile 文件，添加

```ruby
pod 'GMObjC'
```

然后执行 `pod install` 即可。

### 直接集成

从 Git 下载最新代码，找到和 README 同级的 GMObjC 文件夹，将 GMObjC 文件夹拖入项目即可，在需要使用的地方导入头文件 `GMObjC.h` 即可使用 SM2、SM4 加解密，签名验签，计算 SM3 摘要等。

集成 OpenSSL 的注意事项：

1. 工具类依赖 OpenSSL，可通过`pod GMOpenSSL`安装 OpenSSL，或者下载 [openssl.framework](https://github.com/muzipiao/GMOpenSSL)，找到`GMOpenSSL/openssl.framework`，拖入项目即可。
2. 如果需要自编译 OpenSSL，在 [GMOpenSSL](https://github.com/muzipiao/GMOpenSSL) 项目目录下有一个`OpenSSL_BUILD`文件夹，终端 cd 切换到该目录下，先执行`./build-libssl.sh`命令编译生成 .a 文件，等待结束后再执行`./create-openssl-framework.sh`命令打包为 framework，这时该目录下就出现了 openssl.framework。
3. 打包完成的静态库并未暴露国密的头文件，打开下载的源码，将 crypto/include/internal 路径下的 sm2.h、sm3.h，sm4.h 都拖到 openssl.framework/Headers 文件夹下即可。

## 用法

### SM2 加解密

SM2 加解密都很简单，加密传入待加密明文和公钥，解密传入密文和私钥即可，代码：

```objc
// 公钥
NSString *pubKey = @"0408E3FFF9505BCFAF9307E665E9229F4E1B3936437A870407EA3D97886BAFBC9"
                    "C624537215DE9507BC0E2DD276CF74695C99DF42424F28E9004CDE4678F63D698";
// 私钥
NSString *prikey = @"90F3A42B9FE24AB196305FD92EC82E647616C3A3694441FB3422E7838E24DEAE";

// 明文
NSString *plaintext = @"123456"; // 普通明文
NSString *plainHex = @"313233343536"; // Hex 格式字明文（123456 的 Hex 编码为 313233343536）
NSData *plainData = [NSData dataWithBytes:"123456" length:6]; // NSData 格式明文

// sm2 加密
NSString *enResult1 = [GMSm2Utils encryptText:plaintext publicKey:pubKey]; // 加密普通字符串
NSString *enResult2 = [GMSm2Utils encryptHex:plainHex publicKey:pubKey]; // 加密 Hex 编码格式字符串
NSData *enResult3 = [GMSm2Utils encryptData:plainData publicKey:pubKey]; // 加密 NSData 类型数据

// sm2 解密
NSString *deResult1 = [GMSm2Utils decryptToText:enResult1 privateKey:priKey]; // 解密为普通字符串明文
NSString *deResult2 = [GMSm2Utils decryptToHex:enResult2 privateKey:priKey]; // 解密为 Hex 格式明文
NSData *deResult3 = [GMSm2Utils decryptToData:enResult3 privateKey:priKey]; // 解密为 NSData 格式明文
```

**注意：**

1. OpenSSL 所用公钥是 04 开头的，后台返回公钥可能是不带 04 的，需要手动拼接。
2. 后台返回的解密结果可能是没有标准编码的原始密文 C1C3C2 格式，而 OpenSSL 的加解密都是需要 ASN1 编码格式，所以与后台交互过程中，可能需要 ASN1 编码解码。

### SM2 签名验签

SM2 私钥签名，公钥验签，可防篡改或验证身份。签名时传入明文、私钥和用户 ID；验签时传入明文、签名、公钥和用户 ID，代码：

```objc
// 公钥
NSString *pubKey = @"0408E3FFF9505BCFAF9307E665E9229F4E1B3936437A870407EA3D97886BAFBC9"
                    "C624537215DE9507BC0E2DD276CF74695C99DF42424F28E9004CDE4678F63D698";
// 私钥
NSString *prikey = @"90F3A42B9FE24AB196305FD92EC82E647616C3A3694441FB3422E7838E24DEAE";

// 明文
NSString *plaintext = @"123456"; // 普通明文
NSString *plainHex = @"313233343536"; // Hex 格式字明文（123456 的 Hex 编码为 313233343536）
NSData *plainData = [NSData dataWithBytes:"123456" length:6]; // NSData 格式明文

// userID 传入 nil 或空时默认 1234567812345678；不为空时，签名和验签需要相同 ID
NSString *userID = @"lifei_zdjl@126.com"; // 普通字符串的 userID
NSString *userHex = [GMUtils stringToHex:userID]; // Hex 格式的 userID
NSData *userData = [userID dataUsingEncoding:NSUTF8StringEncoding]; // NSData 格式的 userID

// 签名结果是 RS 拼接的 128 字节 Hex 格式字符串，前 64 字节是 R，后 64 字节是 S
NSString *signStr1 = [GMSm2Utils signText:plaintext privateKey:priKey userID:userID];
NSString *signStr2 = [GMSm2Utils signHex:plainHex privateKey:priKey userHex:userHex];
NSString *signStr3 = [GMSm2Utils signData:plainData priKey:priKey userData:userData];

// 验证签名，YES 为验签通过
BOOL isOK1 = [GMSm2Utils verifyText:plaintext signRS:signStr1 publicKey:pubKey userID:userID];
BOOL isOK2 = [GMSm2Utils verifyHex:plainHex signRS:signStr2 publicKey:pubKey userHex:userHex];
BOOL isOK3 = [GMSm2Utils verifyData:plainData signRS:signStr3 pubKey:pubKey userData:userData];

// 编码为 Der 格式，Der 编码解码后应该与原值相同
NSString *derSign1 = [GMSm2Utils derEncode:signStr1];
NSString *derSign2 = [GMSm2Utils derEncode:signStr2];
NSString *derSign3 = [GMSm2Utils derEncode:signStr3];

// 解码为 RS 字符串格式，RS 拼接的 128 字节 Hex 格式字符串，前 64 字节是 R，后 64 字节是 S
NSString *rs1 = [GMSm2Utils derDecode:derSign1];
NSString *rs2 = [GMSm2Utils derDecode:derSign2];
NSString *rs3 = [GMSm2Utils derDecode:derSign3];
```

注意：

1. 用户 ID 可传空值，当传空值时使用 OpenSSL 默认用户 ID，OpenSSL 中默认用户定义为`#define SM2_DEFAULT_USERID "1234567812345678"` ，客户端和服务端用户 ID 要保持一致。
2. 客户端和后台交互的过程中，假设后台签名，客户端验签，后台返回的签名是 DER 编码格式，就需要先对签名进行 DER 解码，然后再进行验签。同理，若客户端签名，后台验签，根据后台是需要 RS 拼接格式签名，还是 DER 格式，进行编码解码。

### ECDH 密钥协商

OpenSSL 中的 `ECDH_compute_key()`执行椭圆曲线 Diffie-Hellman 密钥协商，可在双方都是明文传输的情况下，协商出一个相同的密钥。

协商流程：

1. 客户端随机生成一对公私钥 clientPublicKey，clientPrivateKey；
2. 服务端随机生成一对公私钥 serverPublicKey，serverPrivateKey；
3. 双方利用网络请求或其他方式交换公钥 clientPublicKey 和 serverPublicKey，私钥自己保存；
4. 客户端计算`clientKey = ECDH_compute_key(clientPrivateKey，serverPublicKey)`；
5. 服务端计算`serverKey = ECDH_compute_key(serverPrivateKey，clientPublicKey)`；
6. 双方各自计算出的 clientKey 和 serverKey 应该是相等的，这个 key 可以作为对称加密的密钥。

```objc
// 客户端client生成一对公私钥
NSArray *clientKey = [GMSm2Utils createKeyPair];
NSString *cPubKey = clientKey[0];
NSString *cPriKey = clientKey[1];

// 服务端server生成一对公私钥
NSArray *serverKey = [GMSm2Utils createKeyPair];
NSString *sPubKey = serverKey[0];
NSString *sPriKey = serverKey[1];

// 客户端client从服务端server获取公钥sPubKey，client协商出32字节对称密钥clientECDH，转Hex后为64字节
NSString *clientECDH = [GMSm2Utils computeECDH:sPubKey privateKey:cPriKey];
// 客户端client将公钥cPubKey发送给服务端server，server协商出32字节对称密钥serverECDH，转Hex后为64字节
NSString *serverECDH = [GMSm2Utils computeECDH:cPubKey privateKey:sPriKey];

// 在全部明文传输的情况下，client与server协商出相等的对称密钥，clientECDH==serverECDH 成立
if ([clientECDH isEqualToString:serverECDH]) {
    NSLog(@"ECDH 密钥协商成功，协商出的对称密钥为：\n%@", clientECDH);
}else{
    NSLog(@"ECDH 密钥协商失败");
}
```

### SM4 加解密

SM4 加解密都很简单，加密传入待加密字符串和密钥，解密传入密文和密钥即可，代码：

* ECB 电子密码本模式，密文分割成长度相等的块（不足补齐），逐个块加密。
* CBC 密文分组链接模式，前一个分组的密文和当前分组的明文异或或操作后再加密。

```objc

NSString *sm4Key = @"EA4EBDC1DCEAEC733FFD358BA15E8DCD"; // 32 字节 Hex 编码格式字符串密钥
NSString *ivec = @"1AFE5CC82D2DE304343FED0AF5FDE7FA"; // 32 字节初始化向量，CBC 加密模式需要

// 明文
NSString *plaintext = @"123456"; // 普通明文
NSData *plainData = [NSData dataWithBytes:"123456" length:6]; // NSData 格式明文

// ECB 加密模式
NSString *ecbCipertext = [GMSm4Utils ecbEncryptText:plaintext key:sm4Key]; // 加密普通字符串明文
NSData *ecbCipherData = [GMSm4Utils ecbEncryptData:plainData key:sm4Key]; // 加密 NSData 类型明文
// ECB 解密模式
NSString *ecbPlaintext = [GMSm4Utils ecbDecryptText:ecbCipertext key:sm4Key];
NSData *ecbDecryptData = [GMSm4Utils ecbDecryptData:ecbCipherData key:sm4Key];

// CBC 加密模式
NSString *cbcCipertext = [GMSm4Utils cbcEncryptText:plaintext key:sm4Key IV:ivec];
NSData *cbcCipherData = [GMSm4Utils cbcEncryptData:plainData key:sm4Key IV:ivec];
// CBC 解密模式
NSString *cbcPlaintext = [GMSm4Utils cbcDecryptText:cbcCipertext key:sm4Key IV:ivec];
NSData *cbcDecryptData = [GMSm4Utils cbcDecryptData:cbcCipherData key:sm4Key IV:ivec];
```

### SM3 摘要

类似于 hash、md5，SM3 摘要算法可对文本文件进行摘要计算，摘要长度为 64 字节的 Hex 编码格式字符串。

```objc
// 原文
NSString *plaintext = @"123456"; // 普通原文
NSData *plainData = [NSData dataWithBytes:"123456" length:6]; // NSData 格式原文

// 字符串摘要
NSString *textDigest = [GMSm3Utils hashWithString:plaintext];
// NSData 的摘要
NSString *dataDigest = [GMSm3Utils hashWithData:plainData];
```

### ASN1 编码解码

OpenSSL 对 SM2 加密结果进行了 ASN1 编码，解密时也是要求密文编码格式为 ASN1 格式，其他平台加解密可能需要 C1C3C2 拼接的原始密文，所以需要编码解码。个别后端加解密是按照 C1C2C3 来拼接的，也可能是其他顺序，若无法加解密，与后台确认拼接顺序，自行拼接即可。

```objc
// 公钥
NSString *pubKey = @"0408E3FFF9505BCFAF9307E665E9229F4E1B3936437A870407EA3D97886BAFBC9"
                    "C624537215DE9507BC0E2DD276CF74695C99DF42424F28E9004CDE4678F63D698";
// 私钥
NSString *prikey = @"90F3A42B9FE24AB196305FD92EC82E647616C3A3694441FB3422E7838E24DEAE";

// 明文
NSString *plaintext = @"123456"; // 普通明文
NSString *plainHex = @"313233343536"; // Hex 格式字明文（123456 的 Hex 编码为 313233343536）
NSData *plainData = [NSData dataWithBytes:"123456" length:6]; // NSData 格式明文

// sm2 加密结果，ASN1 编码的密文
NSString *enResult1 = [GMSm2Utils encryptText:plaintext publicKey:pubKey]; // 加密普通字符串
NSString *enResult2 = [GMSm2Utils encryptHex:plainHex publicKey:pubKey]; // 加密 Hex 编码格式字符串
NSData *enResult3 = [GMSm2Utils encryptData:plainData publicKey:pubKey]; // 加密 NSData 类型数据

// ASN1 解码，将 ASN1 编码格式的密文解码字符串，数组或者 NSData
NSString *c1c3c2Result1 = [GMSm2Utils asn1DecodeToC1C3C2:enResult1]; // 解码为 c1c3c2字符串
NSArray<NSString *> *c1c3c2Result2 = [GMSm2Utils asn1DecodeToC1C3C2Array:enResult2]; // 解码为 @[c1,c3,c2]
NSData *c1c3c2Result3 = [GMSm2Utils asn1DecodeToC1C3C2Data:enResult3]; // 解码为 c1c3c2拼接的Data

// ASN1 编码，将解码后 c1c3c2 密文重新编码为 ASN1 格式，应该与 enResult1，enResult2，enResult3 完全相同
NSString *asn1Result1 = [GMSm2Utils asn1EncodeWithC1C3C2:c1c3c2Result1];
NSString *asn1Result2 = [GMSm2Utils asn1EncodeWithC1C3C2Array:c1c3c2Result2];
NSData *asn1Result3 = [GMSm2Utils asn1EncodeWithC1C3C2Data:c1c3c2Result3];
```

### 生成公私钥

基于 SM2 推荐曲线（素数域 256 位椭圆曲线），生成公私钥。

```objc
NSArray *keyPair = [GMSm2Utils createKeyPair];
NSString *pubKey = keyPair[0]; // 04 开头公钥，Hex 编码格式
NSString *priKey = keyPair[1]; // 私钥，Hex 编码格式
```

## 其他

如果您觉得有所帮助，请在 [GitHub GMObjC](https://github.com/muzipiao/GMObjC) 上赏个Star ⭐️，您的鼓励是我前进的动力
