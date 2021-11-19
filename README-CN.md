# GMObjC

[![Build Status](https://github.com/muzipiao/GMObjC/actions/workflows/build.yml/badge.svg)](https://github.com/muzipiao/GMObjC/actions/workflows/build.yml)
[![Pod Version](https://img.shields.io/cocoapods/v/GMObjC.svg?style=flat)](https://cocoapods.org/pods/GMObjC)
[![Pod Platform](https://img.shields.io/cocoapods/p/GMObjC.svg?style=flat)](https://cocoapods.org/pods/GMObjC)
[![Pod License](https://img.shields.io/cocoapods/l/GMObjC.svg?style=flat)](https://cocoapods.org/pods/GMObjC)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/muzipiao/GMObjC)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![codecov](https://codecov.io/gh/muzipiao/GMObjC/branch/master/graph/badge.svg)](https://codecov.io/gh/muzipiao/GMObjC)

[English Readme](https://github.com/muzipiao/GMObjC/blob/master/README.md)

OpenSSL 1.1.1 以上版本增加了对中国 SM2/SM3/SM4 加密算法的支持，基于 OpenSSL 对国密 SM2 非对称加密、SM2 签名验签、ECDH 密钥协商、SM3 摘要算法，SM4 对称加密做 OC 封装。

## 快速开始

在终端运行以下命令:

```ruby
git clone https://github.com/muzipiao/GMObjC.git

cd GMObjC

pod install

open GMObjC.xcworkspace
```

## 环境需求

依赖 OpenSSL 1.1.1 以上版本，已打包为 Framework，并上传 cocoapods，可拖入项目直接安装，或使用 cocoapods 配置  Podfile 文件`pod GMOpenSSL`安装；并导入系统框架 Security.framework。

* iOS 9.0 以上系统
* [GMOpenSSL.framework](https://github.com/muzipiao/GMOpenSSL)(openssl.framework)
* Security.framework

## 集成

在项目中使用 GMObjC 的方法如下：

* 使用 CocoaPods
* 使用 Carthage
* 编译为 Framework/XCFramework
* 使用 Swift Package Manager
* 拖入项目源码直接使用

### CocoaPods

CocoaPods 是最简单方便的集成方法，编辑 Podfile 文件，添加

```ruby
pod 'GMObjC'
```

然后执行 `pod install` 即可。GMObjC 依赖 OpenSSL 1.1.1 以上版本，CocoaPods 不支持依赖同一静态库库的不同版本，如果遇到与三方库的 OpenSSL 冲突，例如百度地图（BaiduMapKit）依赖了低版本的 OpenSSL 静态库，会产生依赖冲突。

OpenSSL 冲突常见解决办法：

方法1：将三方库使用 OpenSSL 升级为 1.1.1 以上版本，GMObjC 直接共用此 OpenSSL 库，不需要再为 GMObjC 单独增加 OpenSSL 依赖库，手动集成 GMObjC 即可；

方法2：将 GMObjC 编译为动态库可解决此类冲突。通过 Carthage 自动将 GMObjC 编译动态库，具体操作看下一步。

### Carthage

Carthage 可以自动将第三方框架编译为动态库（Dynamic framework），未安装的先执行 `brew update` 和 `brew install carthage` 安装，然后创建一个名称为 Cartfile 的文件（类似 Podfile），编辑添加想要编译的三方库名称如 `github "muzipiao/GMObjC"`，然后执行 `carthage update --use-xcframeworks` 即可。

```ruby
# 安装 carthage
brew update && brew install carthage
# 创建 Cartfile 文件，并写入文件 github "muzipiao/GMObjC"
touch Cartfile && echo 'github "muzipiao/GMObjC"' >> Cartfile
# 拉取编译为动态库，在当前执行命令目录下 Carthage/Build/iOS/ 可找到 GMObjC.framework
carthage update --use-xcframeworks
```

编译成功后，打开 Carthage 查看生成的文件目录，Carthage/Build/iOS/GMObjC.xcframework 既是编译成功的动态库，将动态库拖入工程即可。

注意：GMObjC.xcframework 为动态库，需要选择 `Embed & Sign` 模式，且不需要再单独导入 openssl.framework 库。若 Carthage 编译失败，下载项目源码，执行 `carthage build --no-skip-current --use-xcframeworks` 手动编译即可。

### Swift Package Manager

GMObjC 从 3.3.0 开始支持 SwiftPM，在工程中使用，点击 `File` -> `Swift Packages` -> `Add Package Dependency`，输入 [GMObjC 分支 URL](https://github.com/muzipiao/GMObjC.git)，或者在 Xcode 中添加 GitHub 账号，搜索 `GMObjC` 即可。

如果在组件库中使用，更新 `Package.swift` 文件：

```swift
dependencies: [
    .package(url: "https://github.com/muzipiao/GMObjC.git", from: "3.3.0")
],
```

### 直接集成

从 Git 下载最新代码，找到和 README 同级的 GMObjC 文件夹，将 GMObjC 文件夹拖入项目即可，在需要使用的地方导入头文件 `GMObjC.h` 即可使用 SM2、SM4 加解密，签名验签，计算 SM3 摘要等。

集成 OpenSSL 的注意事项：

1. 工具类依赖 OpenSSL，可通过`pod GMOpenSSL`安装 OpenSSL，或者下载 [openssl.framework](https://github.com/muzipiao/GMOpenSSL)，找到`GMOpenSSL/openssl.framework`，拖入项目即可。
2. 如果需要自编译 OpenSSL，在 [GMOpenSSL](https://github.com/muzipiao/GMOpenSSL) 项目目录下有一个`OpenSSL_BUILD`文件夹，终端 cd 切换到该目录下，先执行`./build-libssl.sh`命令编译生成 .a 文件，等待结束后再执行`./create-openssl-framework.sh`命令打包为 framework，这时该目录下就出现了 openssl.framework。
3. 打包完成的静态库并未暴露国密的头文件，打开下载的源码，将 crypto/include/internal 路径下的 sm2.h、sm3.h，sm4.h 都拖到 openssl.framework/Headers 文件夹下即可。

### 集成可能遇到的 Xcode 编译错误

错误1：

```text
Building for iOS, but the linked and embedded framework 'GMObjC.framework' was built for iOS + iOS Simulator.
```

解决办法，选择工程路径 `Build Settings - Build Options - Validate Workspace` 更改为 YES/NO，更改一次即可。

错误2：

```text
building for iOS Simulator, but linking in object file built for iOS, for architecture arm64
```
解决办法，选择工程 路径`Build Settings - Architectures - Excluded Architecture` 选择 `Any iOS Simulator SDK` 添加 arm64，参考[stackoverflow 方案](https://stackoverflow.com/questions/63607158/xcode-12-building-for-ios-simulator-but-linking-in-object-file-built-for-ios)。

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

1. OpenSSL 所用公钥是 04 开头的，表示非压缩公钥格式，后台返回公钥可能是不带 04 的，需要手动拼接。
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

### SM2 密钥文件读写(PEM/DER)

SM2 公私钥格式可能为 PEM 或 DER 格式，可使用 GMSm2Bio 进行操作。

```objc
NSString *filePath = @"PEM或DER文件地址";
// 从PEM文件读取SM2公私钥
NSString *pubPemKey = [GMSm2Bio readPublicKeyFromPemFile:filePath];
NSString *priPemKey = [GMSm2Bio readPrivateKeyFromPemFile:filePath];
// 从DER文件读取SM2公私钥
NSString *pubDerKey = [GMSm2Bio readPublicKeyFromDerFile:filePath];
NSString *priDerKey = [GMSm2Bio readPrivateKeyFromDerFile:filePath];

NSString *savePath = @"保存SM2公私钥至PEM/DER文件的沙盒地址";
// 保存04开头的公钥字符串为PEM或DER文件，保存成功返回YES，否则NO
BOOL success1 = [GMSm2Bio savePublicKeyToPemFile:pubKey filePath:pubPemPath];
BOOL success2 = [GMSm2Bio savePublicKeyToDerFile:pubKey filePath:pubDerPath];
// 保存私钥字符串为PEM或DER文件，保存成功返回YES，否则NO
BOOL success3 = [GMSm2Bio savePrivateKeyToPemFile:priKey filePath:priPemPath];
BOOL success4 = [GMSm2Bio savePrivateKeyToDerFile:priKey filePath:priDerPath];

// 创建PEM或DER格式秘钥对文件，数组元素0为公钥文件地址，元素1为私钥文件地址
NSArray<NSString *> *derFilesArray = [GMSm2Bio createDerKeyPairFiles];
NSArray<NSString *> *pemFilesArray = [GMSm2Bio createPemKeyPairFiles];
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

类似于 md5、sha1，SM3 摘要算法可对文本文件进行摘要计算，摘要长度为 64 字节的 Hex 编码格式字符串。

```objc
// 原文
NSString *plaintext = @"123456"; // 普通原文
NSData *plainData = [NSData dataWithBytes:"123456" length:6]; // NSData 格式原文

// 字符串摘要
NSString *textDigest = [GMSm3Utils hashWithString:plaintext];
// NSData 的摘要
NSString *dataDigest = [GMSm3Utils hashWithData:plainData];
```

### HMAC 计算摘要

HMAC 算法计算摘要，计算的摘要长度和原摘要算法长度相同。

```objc
NSString *plaintext = @"123456"; // 普通原文
NSString *randomKey = @"qwertyuiop1234567890"; // 服务端传过来的 key
// HMAC 使用 SM3 摘要算法
NSString *hmacSM3 = [GMSm3Utils hmacWithSm3:randomKey plaintext:plaintext];
// HMAC 使用 MD5 摘要算法
NSString *hmacMD5 = [GMSm3Utils hmac:GMHashType_MD5 key:randomKey plaintext:plaintext];
// HMAC 使用 SHA1 摘要算法
NSString *hmacSHA1 = [GMSm3Utils hmac:GMHashType_SHA1 key:randomKey plaintext:plaintext];
// HMAC 使用 SHA224 摘要算法
NSString *hmacSHA224 = [GMSm3Utils hmac:GMHashType_SHA224 key:randomKey plaintext:plaintext];
// HMAC 使用 SHA256 摘要算法
NSString *hmacSHA256 = [GMSm3Utils hmac:GMHashType_SHA256 key:randomKey plaintext:plaintext];
// HMAC 使用 SHA384 摘要算法
NSString *hmacSHA384 = [GMSm3Utils hmac:GMHashType_SHA384 key:randomKey plaintext:plaintext];
// HMAC 使用 SHA512 摘要算法
NSString *hmacSHA512 = [GMSm3Utils hmac:GMHashType_SHA512 key:randomKey plaintext:plaintext];
```

### ASN1 编码解码

OpenSSL 对 SM2 加密结果进行了 ASN1 编码，解密时也是要求密文编码格式为 ASN1 格式，解码后得到顺序为 C1C3C2 拼接的原始密文。

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

### 密文格式转换

ASN1 解码密文后，得到的密文排列顺序为 C1C3C2，其他平台可能需要顺序为 C1C2C3 的密文；例如 Java 端使用 BouncyCastle 进行 SM2 加密，得到密文可能是**04**开头，按照 C1C2C3 排列的密文。

OpenSSL 解密要求密文排列顺序为 C1C3C2，且为 ASN1 编码格式，这两种情况都需要进行转换。BouncyCastle 加密的密文，需要先将密文格式由 C1C2C3 更改为 C1C3C2，再进行 ASN1 编码，然后进行解密。

密文一般不包含**密文格式标识**，至于是否包含，可通过观察或与其他平台确认，密文开头常见标识。

* 02或03 压缩表示形式
* 04 未压缩表示形式
* 06或07 混合表示形式

```objc
NSString *ciphertext = @"C1C2C3 排列顺序的密文";
// 将 C1C2C3 排列顺序的密文，更改为 C1C3C2 顺序
NSString *c1c3c2 = [GMSm2Utils convertC1C2C3ToC1C3C2:c1c2c3 hasPrefix:NO];
// ASN1 编码，将 c1c3c2 顺序的密文编码为 ASN1 格式
NSString *asn1Result = [GMSm2Utils asn1EncodeWithC1C3C2:c1c3c2];
// 解密为普通字符串明文
NSString *deResult1 = [GMSm2Utils decryptToText:asn1Result privateKey:priKey]; 
// 根据需要，可以将 C1C3C2 排列顺序的密文，更改为 C1C2C3 顺序
NSString *c1c2c3 = [GMSm2Utils convertC1C3C2ToC1C2C3:c1c3c2 hasPrefix:NO];
```

密文拆分原理：假设未进行 ASN1 编码的密文是 Hex 编码（16 进制编码）格式，且按照 C1C2C3 顺序排列的，已知 C1 长度固定为 128 字节，C3 长度固定为 64 字节，那 C2 长度 = 密文字符串总长度 - C1长度 128 - C3长度，这样就分别得到了 C1、C2、C3 字符串，自由拼接。

### 生成公私钥

基于 SM2 推荐曲线（素数域 256 位椭圆曲线），生成公私钥。

```objc
NSArray *keyPair = [GMSm2Utils createKeyPair];
NSString *pubKey = keyPair[0]; // 04 开头公钥，Hex 编码格式
NSString *priKey = keyPair[1]; // 私钥，Hex 编码格式
```

## SM2 曲线

1. GM/T 0003-2012 标准推荐参数  sm2p256v1（NID_sm2）；
2. SM2 如果需要使用其他曲线，调用`[GMSm2Utils setEllipticCurveType:*]`，传入 int 类型即可；
3. 如何查找到需要的曲线，GMSm2Utils 头文件枚举中列出最常见 3 种曲线 sm2p256v1、secp256k1，secp256r1；
4. 如果是其他曲线，可在 OpenSSL 源码 crypto/ec/ec_curve.c 中查找，传入 int 类型即可。

GMSm2Utils.h 文件中 GMCurveType 对应曲线参数：

```text
ECC推荐参数：sm2p256v1（对应 OpenSSL 中 NID_sm2）
p   = FFFFFFFE FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF 00000000 FFFFFFFF FFFFFFFF
a   = FFFFFFFE FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF 00000000 FFFFFFFF FFFFFFFC
b   = 28E9FA9E 9D9F5E34 4D5A9E4B CF6509A7 F39789F5 15AB8F92 DDBCBD41 4D940E93
n   = FFFFFFFE FFFFFFFF FFFFFFFF FFFFFFFF 7203DF6B 21C6052B 53BBF409 39D54123
Gx =  32C4AE2C 1F198119 5F990446 6A39C994 8FE30BBF F2660BE1 715A4589 334C74C7
Gy =  BC3736A2 F4F6779C 59BDCEE3 6B692153 D0A9877C C62A4740 02DF32E5 2139F0A0

ECC推荐参数：secp256k1（对应 OpenSSL 中 NID_secp256k1）
p   = FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE FFFFFC2F
a   = 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
b   = 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000007
n   = FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE BAAEDCE6 AF48A03B BFD25E8C D0364141
Gx =  79BE667E F9DCBBAC 55A06295 CE870B07 029BFCDB 2DCE28D9 59F2815B 16F81798
Gy =  483ADA77 26A3C465 5DA4FBFC 0E1108A8 FD17B448 A6855419 9C47D08F FB10D4B8

ECC推荐参数：secp256r1（对应 OpenSSL 中 NID_X9_62_prime256v1）
p   = FFFFFFFF 00000001 00000000 00000000 00000000 FFFFFFFF FFFFFFFF FFFFFFFF
a   = FFFFFFFF 00000001 00000000 00000000 00000000 FFFFFFFF FFFFFFFF FFFFFFFC
b   = 5AC635D8 AA3A93E7 B3EBBD55 769886BC 651D06B0 CC53B0F6 3BCE3C3E 27D2604B
n   = FFFFFFFF 00000000 FFFFFFFF FFFFFFFF BCE6FAAD A7179E84 F3B9CAC2 FC632551
Gx  = 6B17D1F2 E12C4247 F8BCE6E5 63A440F2 77037D81 2DEB33A0 F4A13945 D898C296
Gy  = 4FE342E2 FE1A7F9B 8EE7EB4A 7C0F9E16 2BCE3357 6B315ECE CBB64068 37BF51F5
```

## 其他

如果您觉得有所帮助，请在 [GitHub GMObjC](https://github.com/muzipiao/GMObjC) 上赏个Star ⭐️，您的鼓励是我前进的动力
