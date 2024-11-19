<div style="display: flex; justify-content: center; align-items: center; margin-bottom: 8px;">
  <img src="https://muzipiao.github.io/gmdocs/img/gmobjc-logo-rect.svg" width="50%">
</div>

[![Build Status](https://github.com/muzipiao/GMObjC/actions/workflows/build.yml/badge.svg)](https://github.com/muzipiao/GMObjC/actions/workflows/build.yml)
[![Pod Version](https://img.shields.io/cocoapods/v/GMObjC.svg?style=flat)](https://cocoapods.org/pods/GMObjC)
[![Platforms](https://img.shields.io/cocoapods/p/GMObjC.svg?style=flat)](https://cocoapods.org/pods/GMObjC)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/muzipiao/GMObjC)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![codecov](https://codecov.io/gh/muzipiao/GMObjC/branch/master/graph/badge.svg)](https://codecov.io/gh/muzipiao/GMObjC)

[English Readme](https://github.com/muzipiao/GMObjC/blob/master/README.md)

# GMObjC

**GMObjC** 是一个基于 OpenSSL 的国密（SM2、SM3、SM4）算法的 Objective-C 开源库，适用于 iOS 和 macOS 开发。它封装了中国国家密码管理局发布的多种加密算法，包括：

- **SM2**：支持基于椭圆曲线（ECC）的加解密，密钥协商（ECDH）和签名算法。
- **SM3**：类似 SHA 系列的国密哈希算法，包含 SM3 和 HMAC 等。
- **SM4**：实现对称分组加密算法。

## 文档

要查看详细文档，请访问 [https://muzipiao.github.io/gmdocs/zh/](https://muzipiao.github.io/gmdocs/zh/)。

## 尝试 Demo

在终端运行以下命令:

```ruby
git clone https://github.com/muzipiao/GMObjC.git

cd GMObjC

pod install

open GMObjC.xcworkspace
```

## SM2 密钥对

```objc
// 生成公私钥，公私钥都为 HEX 编码的字符串格式
GMSm2Key *keyPair = [GMSm2Utils generateKey];
// SM2 公钥 "0408E3FFF9505BCFAF9307E665...695C99DF42424F28E9004CDE4678F63D698"
NSString *pubKey = keyPair.publicKey;
// SM2 私钥 "90F3A42B9FE24AB196305FD92EC82E647616C3A3694441FB3422E7838E24DEAE"
NSString *priKey = keyPair.privateKey;
```

## SM2 加解密

```objc
// 明文（字符串类型）
NSString *plaintext = @"123456";

// SM2 加密字符串类型，结果为 ASN1 格式的密文，并编码为 HEX 格式
NSString *asn1Hex = [GMSm2Utils encryptText:plaintext publicKey:pubKey];
// 解密得到字符串明文 "123456"
NSString *plaintext = [GMSm2Utils decryptHex:asn1Hex privateKey:priKey];

// ASN1 解码为 C1C3C2 格式（HEX 编码格式）
NSString *c1c3c2Hex = [GMSm2Utils asn1DecodeToC1C3C2Hex:asn1Hex hasPrefix:NO];
// 密文顺序 C1C3C2 和 C1C2C3 可相互转换
NSString *c1c2c3Hex = [GMSm2Utils convertC1C3C2HexToC1C2C3:c1c3c2Hex hasPrefix:NO];
```

## SM2 签名验签

```objc
NSString *plaintext = @"123456";
// userID 传入 nil 或空时默认 1234567812345678；不为空时，签名和验签需要相同 ID
NSString *userID = @"lifei_zdjl@126.com";
// 签名结果是 RS 拼接的 128 字节 Hex 格式字符串，前 64 字节是 R，后 64 字节是 S
NSString *signRS = [GMSm2Utils signText:plaintext privateKey:priKey userText:userID];
// 验证签名，返回 YES 验签成功，否则验签失败
BOOL isOK = [GMSm2Utils verifyText:plaintext signRS:signRS publicKey:pubKey userText:userID];
```

## ECDH 密钥协商

1. 客户端随机生成一对公私钥 clientPubKey，clientPriKey；
2. 服务端随机生成一对公私钥 serverPubKey，serverPriKey；
3. 双方利用网络请求或其他方式交换公钥 clientPubKey 和 serverPubKey，私钥自己保存；
4. 双方各自计算出的 clientECDH 和 serverECDH 应该是相等的，这个 key 可以作为对称加密的密钥。

```objc
// 客户端client从服务端server获取公钥serverPubKey，client协商出32字节对称密钥clientECDH，转Hex后为64字节
NSString *clientECDH = [GMSm2Utils computeECDH:serverPubKey privateKey:clientPriKey];
// 客户端client将公钥clientPubKey发送给服务端server，server协商出32字节对称密钥serverECDH，转Hex后为64字节
NSString *serverECDH = [GMSm2Utils computeECDH:clientPubKey privateKey:serverPriKey];

// 在全部明文传输的情况下，client与server协商出相等的对称密钥，clientECDH==serverECDH 成立
if ([clientECDH isEqualToString:serverECDH]) {
    NSLog(@"ECDH 密钥协商成功，协商出的对称密钥为：\n%@", clientECDH);
}else{
    NSLog(@"ECDH 密钥协商失败");
}
```

## SM3 摘要

SM3 摘要算法可对文本和文件进行摘要计算，SM3 摘要长度为 64 字节的 HEX 编码格式字符串。

```objc
// 字符串输入，返回十六进制摘要
NSString *digest = [GMSm3Utils hashWithText:@"Hello, SM3!"];

// 默认使用 SM3 计算 HMAC 摘要，同时支持 MD5、SHA1、SHA224/256/384/512 等其他算法
NSString *hmac = [GMSm3Utils hmacWithText:@"Message" keyText:@"SecretKey"];
```

## SM4 加解密

SM4 对称加密较简单，支持 ECB 和 CBC 两种加密模式。

- ECB 电子密码本模式，密文分割成长度相等的块（不足补齐），逐个块加密。
- CBC 密文分组链接模式，前一个分组的密文和当前分组的明文异或或操作后再加密。

```objc
// 字符串加解密，HEX 编码格式密钥长度为 32 字节
NSString *sm4KeyHex = @"0123456789abcdef0123456789abcdef";
NSString *plaintext = @"Hello, SM4!";

// ECB加密。密文为 HEX 编码格式
NSString *ciphertext = [GMSm4Utils encryptTextWithECB:plaintext keyHex:sm4KeyHex];
// 解密。解密结果为 "Hello, SM4!"
NSString *decrypted = [GMSm4Utils decryptTextWithECB:ciphertext keyHex:sm4KeyHex];

// CBC 模式需要 16 字节（HEX 编码格式为 32 字节）初始化向量(IV)
NSString *ivecHex = @"0123456789abcdef0123456789abcdef";
// 加密。密文为 HEX 编码格式
NSString *ciphertext = [GMSm4Utils encryptTextWithCBC:plaintext keyHex:sm4KeyHex ivecHex:ivecHex];
// 解密。解密结果为 "Hello, SM4!"
NSString *decrypted = [GMSm4Utils decryptTextWithCBC:ciphertext keyHex:sm4KeyHex ivecHex:ivecHex];
```

## 版本记录

**警告**：版本 4.0.0 改动较大，与 3.x.x 的 API 名称不兼容，如需升级请留意编译错误。

| GMObjC 版本 |   支持架构   | 兼容平台 |         兼容版本          |
| :---------: | :----------: | :------: | :-----------------------: |
|    4.0.0    | x86_64 arm64 | iOS OSX  | iOS>= iOS 9.0, OSX>=10.13 |
|    3.3.8    | x86_64 arm64 |   iOS    |        >= iOS 9.0         |

## License

GMObjC 在 MIT 许可下发布，详见 [LICENSE](https://github.com/muzipiao/GMObjC/blob/master/LICENSE)。
