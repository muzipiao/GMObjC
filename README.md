# GMObjC

[![CI Status](https://img.shields.io/travis/muzipiao/GMObjC.svg?style=flat)](https://travis-ci.org/muzipiao/GMObjC)
[![codecov](https://codecov.io/gh/muzipiao/GMObjC/branch/master/graph/badge.svg)](https://codecov.io/gh/muzipiao/GMObjC)
[![Version](https://img.shields.io/cocoapods/v/GMObjC.svg?style=flat)](https://cocoapods.org/pods/GMObjC)
[![License](https://img.shields.io/cocoapods/l/GMObjC.svg?style=flat)](https://cocoapods.org/pods/GMObjC)
[![Platform](https://img.shields.io/cocoapods/p/GMObjC.svg?style=flat)](https://cocoapods.org/pods/GMObjC)

OpenSSL 1.1.1 以上版本增加了对中国 SM2/SM3/SM4 加密算法的支持，但纯 C 的 Api 非常不友好，且无注释，所以针对国密 sm2、sm4 加密做 OC 封装。

## 快速开始

在终端运行以下命令:

```ruby
git clone https://github.com/muzipiao/GMObjC.git

cd GMObjC/Example

pod install

open GMObjC.xcworkspace
```

## 环境需求

* GMOpenSSL.framework(openssl.framework)
* Foundation.framework

## 集成

### CocoaPods

CocoaPods 是最简单方便的集成方法，编辑 Podfile 文件，添加

```ruby
pod 'GMObjC'
```

然后执行 `pod install` 即可。

### 直接集成

从 Git 下载最新代码，找到和 README 同级的 GMObjC 文件夹，将 GMObjC 文件夹拖入项目即可，在需要使用的地方导入头文件 `GMSm2Utils.h` 即可使用 sm2 加解密。

集成 OpenSSL 的注意事项：

1. 工具类依赖 OpenSSL，可通过`pod GMOpenSSL`安装 OpenSSL，或者下载 [openssl.framework](https://github.com/muzipiao/GMOpenSSL)，找到`GMOpenSSL/openssl.framework`，拖入项目即可。
2. 如果需要自编译 OpenSSL，在 [GMOpenSSL](https://github.com/muzipiao/GMOpenSSL) 项目目录下有一个`OpenSSL_BUILD`文件夹，终端 cd 切换到该目录下，先执行`./build-libssl.sh`命令编译生成 .a 文件，等待结束后再执行`./create-openssl-framework.sh`命令打包为 framework，这时该目录下就出现了 openssl.framework。
3. 打包完成的静态库并未暴露国密的头文件，打开下载的源码，将 crypto/include/internal 路径下的 sm2.h、sm3.h，sm4.h 都拖到 openssl.framework/Headers 文件夹下即可。

## 用法

### sm2 加解密

sm2 加解密都很简单，加密传入待加密字符串和公钥，解密传入密文和私钥即可，代码：

```objc
// 公钥
NSString *gPubkey = @"0408E3FFF9505BCFAF9307E665E9229F4E1B3936437A870407EA3D97886BAFBC9C624537215DE9507BC0E2DD276CF74695C99DF42424F28E9004CDE4678F63D698";
// 私钥
NSString *gPrikey = @"90F3A42B9FE24AB196305FD92EC82E647616C3A3694441FB3422E7838E24DEAE"
// 待加密的字符串
NSString *pwd = @"123456";
// 加密
NSString *ctext = [GMSm2Utils encrypt:pwd PublicKey:gPubkey];
// 解密
NSString *plainText = [GMSm2Utils decrypt:encodeCtext PrivateKey:gPrikey];

```

注意：

1. OpenSSL 所用公钥是 04 开头的，后台返回公钥可能是不带 04 的，需要手动拼接。
2. 后台返回的解密结果可能是没有标准编码的原始密文，而 OpenSSL 的加解密都是需要标准 ASN1 编码格式，所以与后台交互过程中，可能需要 ASN1 编码解码。

### sm4 加解密

sm4 加解密都很简单，加密传入待加密字符串和密钥，解密传入密文和密钥即可，代码：

```objc
// 待加密字符串
NSString *pwd = @"123456";
// 生产 sm4 密钥，注意为 16 字节字母数字符号混合的字符串
NSString *sm4Key = [GMSm4Utils createSm4Key]; // 生成16位密钥
// sm4 加密
NSString *sm4Ctext = [GMSm4Utils encrypt:pwd Key:sm4Key];
// sm4 解密
NSString *sm4Ptext = [GMSm4Utils decrypt:sm4Ctext Key:sm4Key];
```

### ASN1 编码解码

OpenSSL 对 sm2 加密结果进行了 ASN1 编码，解密时也是要求密文编码格式为 ASN1 格式，其他平台加解密可能需要 C1C3C2 拼接的原始密文，所以需要编码解码，代码：

```objc
// ASN1 编码的密文
NSString *ctext = @"30:6F:02:21:00:D4:F1:B3:2E:29:50:1E:94:44:46:7F:9E:2E:51:36:1E:91:F5:EC:0B:96:F3:34:94:E5:50:82:9F:00:CC:B5:B7:02:20:04:42:83:DF:76:21:B2:9C:EB:7F:64:8B:B4:7A:3C:BF:FE:97:47:E4:D2:BD:47:44:C9:DA:1D:68:12:23:43:D6:04:20:45:F6:AB:54:22:71:63:93:95:3B:58:E3:8D:90:32:B7:A1:D8:76:2B:B8:16:F2:6A:83:51:77:44:2D:28:2C:D2:04:06:62:9F:38:6A:77:76";
// 对 ASN1 编码的密文解码
NSString *decodeStr = [GMSm2Utils decodeWithASN1:ctext];

// 原始密文(C1C3C2 直接拼接)
NSString *dCtext = @"D4F1B32E29501E9444467F9E2E51361E91F5EC0B96F33494E550829F00CCB5B7044283DF7621B29CEB7F648BB47A3CBFFE9747E4D2BD4744C9DA1D68122343D645F6AB5422716393953B58E38D9032B7A1D8762BB816F26A835177442D282CD2629F386A7776";
// 对 C1C3C2 直接拼接的原始密文 ASN1 编码
NSString *encodeStr = [GMSm2Utils encodeWithASN1:dCtext];

```

### 生成公私钥

基于 sm2 推荐曲线（素数域 256 位椭圆曲线），生成公私钥。

```objc
// 生成公私钥对，数组元素 1 为公钥，2 为私钥
NSArray *newKey = [GMSm2Utils createPublicAndPrivateKey];
// 公钥
NSString *pubKey = newKey[0];
// 私钥
NSString *priKey = newKey[1];
```

## 其他

如果您觉得有所帮助，请在 [GitHub GMObjC](https://github.com/muzipiao/GMObjC) 上赏个Star ⭐️，您的鼓励是我前进的动力
