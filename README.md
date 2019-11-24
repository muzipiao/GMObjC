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

* [GMOpenSSL.framework](https://github.com/muzipiao/GMOpenSSL)(openssl.framework)
* Foundation.framework

## 集成

### CocoaPods

CocoaPods 是最简单方便的集成方法，编辑 Podfile 文件，添加

```ruby
pod 'GMObjC'
```

然后执行 `pod install` 即可。

### 直接集成

从 Git 下载最新代码，找到和 README 同级的 GMObjC 文件夹，将 GMObjC 文件夹拖入项目即可，在需要使用的地方导入头文件 `GMObjC.h` 即可使用 SM2、SM4 加解密。

集成 OpenSSL 的注意事项：

1. 工具类依赖 OpenSSL，可通过`pod GMOpenSSL`安装 OpenSSL，或者下载 [openssl.framework](https://github.com/muzipiao/GMOpenSSL)，找到`GMOpenSSL/openssl.framework`，拖入项目即可。
2. 如果需要自编译 OpenSSL，在 [GMOpenSSL](https://github.com/muzipiao/GMOpenSSL) 项目目录下有一个`OpenSSL_BUILD`文件夹，终端 cd 切换到该目录下，先执行`./build-libssl.sh`命令编译生成 .a 文件，等待结束后再执行`./create-openssl-framework.sh`命令打包为 framework，这时该目录下就出现了 openssl.framework。
3. 打包完成的静态库并未暴露国密的头文件，打开下载的源码，将 crypto/include/internal 路径下的 sm2.h、sm3.h，sm4.h 都拖到 openssl.framework/Headers 文件夹下即可。

## 用法

### SM2 加解密

SM2 加解密都很简单，加密传入待加密字符串和公钥，解密传入密文和私钥即可，代码：

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
NSString *plaintext = [GMSm2Utils decrypt:encodeCtext PrivateKey:gPrikey];
```

注意：

1. OpenSSL 所用公钥是 04 开头的，后台返回公钥可能是不带 04 的，需要手动拼接。
2. 后台返回的解密结果可能是没有标准编码的原始密文，而 OpenSSL 的加解密都是需要 ASN1 编码格式，所以与后台交互过程中，可能需要 ASN1 编码解码。

### SM2 签名验签

SM2 私钥签名，公钥验签，可防篡改或验证身份。签名时传入明文、私钥和用户 ID；验签时传入明文、签名、公钥和用户 ID，代码：

```objc
// 公钥
NSString *gPubkey = @"0408E3FFF9505BCFAF9307E665E9229F4E1B3936437A870407EA3D97886BAFBC9C624537215DE9507BC0E2DD276CF74695C99DF42424F28E9004CDE4678F63D698";
// 私钥
NSString *gPrikey = @"90F3A42B9FE24AB196305FD92EC82E647616C3A3694441FB3422E7838E24DEAE"

// 待签名的原文
NSString *pwd = @"123456";
// 这里传入自定义 ID，和服务器保持两端一致即可。
NSString *userID = @"lifei_zdjl@126.com";
// 签名结果(r+s)拼接的 16 进制字符
NSString *signStr = [GMSm2Utils sign:pwd PrivateKey:gPrikey UserID:userID];
// 验签，isOK 为 YES 验签通过，NO 为未通过
BOOL isOK = [GMSm2Utils verify:pwd Sign:signStr PublicKey:self.gPubkey UserID:userID];
// 对签名结果 Der 编码
NSString *derSign = [GMSm2Utils encodeWithDer:signStr];
// 对 Der 编码解码
NSString *originStr = [GMSm2Utils decodeWithDer:derSign];
```

注意：

1. 用户 ID 可传空值，当传空值时使用 OpenSSL 默认用户 ID，OpenSSL 中默认用户定义为`#define SM2_DEFAULT_USERID "1234567812345678"` ，客户端和服务端用户 ID 要保持一致。
2. 客户端和后台交互的过程中，假设后台签名，客户端验签，后台返回的签名是 DER 编码格式，就需要先对签名进行 DER 解码，然后再进行验签。同理，若客户端签名，后台验签，根据后台是需要 (r, s) 拼接格式签名，还是 DER 格式，进行编码解码。

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
NSArray *clientKey = [GMSm2Utils createPublicAndPrivateKey];
NSString *cPubKey = clientKey[0];
NSString *cPriKey = clientKey[1];

// 服务端server生成一对公私钥
NSArray *serverKey = [GMSm2Utils createPublicAndPrivateKey];
NSString *sPubKey = serverKey[0];
NSString *sPriKey = serverKey[1];

// 客户端client从服务端server获取公钥sPubKey，client协商出32字节对称密钥clientECDH，转Hex后为64字节
NSString *clientECDH = [GMSm2Utils computeECDH:sPubKey PrivateKey:cPriKey];
// 客户端client将公钥cPubKey发送给服务端server，server协商出32字节对称密钥serverECDH，转Hex后为64字节
NSString *serverECDH = [GMSm2Utils computeECDH:cPubKey PrivateKey:sPriKey];

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
// 待加密字符串
NSString *pwd = @"123456";
// 生产 SM4 密钥，注意为 16 字节字母数字符号混合的字符串
NSString *sm4Key = [GMSm4Utils createSm4Key]; // 生成16位密钥
// SM4 ECB 模式加密
NSString *sm4EnByECB = [GMSm4Utils encrypt:pwd Key:sm4Key];
// SM4 ECB 模式解密
NSString *sm4DeByECB = [GMSm4Utils decrypt:sm4EnByECB Key:sm4Key];

// CBC 模式加密需要一个 16 字节的字符串，解密需要相同的字符串
NSString *ivec = [GMSm4Utils createSm4Key]; // 生成16位初始化向量
// SM4 CBC 模式加密
NSString *sm4EnByCBC = [GMSm4Utils cbcEncrypt:pwd Key:sm4Key IV:ivec];
// SM4 CBC 模式解密
NSString *sm4DeByCBC = [GMSm4Utils cbcDecrypt:sm4EnByCBC Key:sm4Key IV:ivec];
```

### SM3 摘要

类似于 hash、md5，SM3 摘要算法可对文本文件进行摘要计算，摘要长度为 64 个字符的字符串格式。

```objc
// 待提取摘要的字符串
NSString *pwd = @"123456";
// 字符串的摘要
NSString *pwdDigest = [GMSm3Utils hashWithString:plaintext];

// 对文件进行摘要计算，传入 NSData 即可
NSString *txtPath = [[NSBundle mainBundle] pathForResource:@"sm4TestFile.txt" ofType:nil];
NSData *fileData = [NSData dataWithContentsOfFile:txtPath];
// 文件的摘要值
NSString *fileDigest = [GMSm3Utils hashWithData:self.fileData];
```

### ASN1 编码解码

重要：个别后端加解密是按照 C1C2C3 来拼接的，也可能是其他顺序，若无法加解密，与后台确认拼接顺序。

c1c3c2 原始密文长度计算规则：密文长度= 192 + 明文长度*2，例如明文是 123456 ，那加密的密文长度应该为 192 + 6*2 = 204

OpenSSL 对 SM2 加密结果进行了 ASN1 编码，解密时也是要求密文编码格式为 ASN1 格式，其他平台加解密可能需要 C1C3C2 拼接的原始密文，所以需要编码解码，代码：

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

基于 SM2 推荐曲线（素数域 256 位椭圆曲线），生成公私钥。

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
