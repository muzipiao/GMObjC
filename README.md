<p align="center">
  <img src="https://muzipiao.github.io/gmdocs/img/gmobjc-logo-rect.svg" width="50%">
</p>

<div align="center">

[![简体中文 README](https://img.shields.io/badge/%F0%9F%91%89%20%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87%20README%F0%9F%91%88-8A2BE2)](https://github.com/muzipiao/GMObjC/blob/master/README-CN.md)
[![Build Status](https://github.com/muzipiao/GMObjC/actions/workflows/build.yml/badge.svg)](https://github.com/muzipiao/GMObjC/actions/workflows/build.yml)
[![Pod Version](https://img.shields.io/cocoapods/v/GMObjC.svg?style=flat)](https://cocoapods.org/pods/GMObjC)
[![Platforms](https://img.shields.io/cocoapods/p/GMObjC.svg?style=flat)](https://cocoapods.org/pods/GMObjC)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/muzipiao/GMObjC)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![codecov](https://codecov.io/gh/muzipiao/GMObjC/branch/master/graph/badge.svg)](https://codecov.io/gh/muzipiao/GMObjC)

</div>

**GMObjC** is an Objective-C open source library based on OpenSSL's national secret (SM2, SM3, SM4) algorithms, suitable for iOS and macOS development. It encapsulates multiple encryption algorithms released by the State Cryptography Administration of China, including:

- **SM2**: Supports encryption and decryption based on elliptic curves (ECC), key negotiation (ECDH) and signature algorithms.
- **SM3**: A national secret hash algorithm similar to the SHA series, including SM3 and HMAC.
- **SM4**: Implements symmetric block encryption algorithms.

## Documentation

For detailed documentation, please visit [https://muzipiao.github.io/gmdocs/](https://muzipiao.github.io/gmdocs/).

## Try Demo

Run the following command in the terminal:

```ruby
git clone https://github.com/muzipiao/GMObjC.git

cd GMObjC

pod install

open GMObjC.xcworkspace
```

## SM2 key pair

```objc
// Generate public and private keys, both of which are in HEX-encoded string format
GMSm2Key *keyPair = [GMSm2Utils generateKey];
// SM2 public key "0408E3FFF9505BCFAF9307E665...695C99DF42424F28E9004CDE4678F63D698"
NSString *pubKey = keyPair.publicKey;
// SM2 private key "90F3A42B9FE24AB196305FD92EC82E647616C3A3694441FB3422E7838E24DEAE"
NSString *priKey = keyPair.privateKey;
```

## SM2 encryption and decryption

```objc
// Plain text (string type)
NSString *plaintext = @"123456";

// SM2 encryption string type, the result is ASN1 format ciphertext, and encoded in HEX format
NSString *asn1Hex = [GMSm2Utils encryptText:plaintext publicKey:pubKey];
// Decrypt to get the string plain text "123456"
NSString *plaintext = [GMSm2Utils decryptHex:asn1Hex privateKey:priKey];

// ASN1 decoded to C1C3C2 format (HEX encoding format)
NSString *c1c3c2Hex = [GMSm2Utils asn1DecodeToC1C3C2Hex:asn1Hex hasPrefix:NO];
// Ciphertext order C1C3C2 and C1C2C3 can be converted to each other
NSString *c1c2c3Hex = [GMSm2Utils convertC1C3C2HexToC1C2C3:c1c3c2Hex hasPrefix:NO];
```

## SM2 signature verification

```objc
NSString *plaintext = @"123456";
// When userID is nil or empty, the default is 1234567812345678; when it is not empty, the signature and verification need the same ID
NSString *userID = @"lifei_zdjl@126.com";
// The signature result is a 128-byte Hex string concatenated by RS, the first 64 bytes are R, and the last 64 bytes are S
NSString *signRS = [GMSm2Utils signText:plaintext privateKey:priKey userText:userID];
// Verify the signature, return YES if the verification is successful, otherwise the verification fails
BOOL isOK = [GMSm2Utils verifyText:plaintext signRS:signRS publicKey:pubKey userText:userID];
```

## ECDH key negotiation

1. The client randomly generates a pair of public and private keys clientPubKey and clientPriKey;
2. The server randomly generates a pair of public and private keys serverPubKey and serverPriKey;
3. Both parties use network requests or other methods to exchange public keys clientPubKey and serverPubKey, and keep the private keys themselves;
4. The clientECDH and serverECDH calculated by both parties They should be equal, and this key can be used as the key for symmetric encryption.

```objc
// The client client obtains the public key serverPubKey from the server, and the client negotiates a 32-byte symmetric key clientECDH, which is 64 bytes after conversion to Hex
NSString *clientECDH = [GMSm2Utils computeECDH:serverPubKey privateKey:clientPriKey];
// The client client sends the public key clientPubKey to the server, and the server negotiates a 32-byte symmetric key serverECDH, which is 64 bytes after conversion to Hex
NSString *serverECDH = [GMSm2Utils computeECDH:clientPubKey privateKey:serverPriKey];

// In the case of all plaintext transmission, the client and server negotiate an equal symmetric key, and clientECDH==serverECDH holds
if ([clientECDH isEqualToString:serverECDH]) {
    NSLog(@"ECDH key negotiation is successful, and the negotiated symmetric key is:\n%@", clientECDH);
}else{
    NSLog(@"ECDH Key negotiation failed");
}
```

## SM3 digest

The SM3 digest algorithm can calculate digests for text and files. The length of the SM3 digest is a 64-byte HEX-encoded format string.

```objc
// String input, return hexadecimal digest
NSString *digest = [GMSm3Utils hashWithText:@"Hello, SM3!"];

// SM3 is used to calculate HMAC digest by default, and other algorithms such as MD5, SHA1, SHA224/256/384/512 are also supported
NSString *hmac = [GMSm3Utils hmacWithText:@"Message" keyText:@"SecretKey"];
```

## SM4 encryption and decryption

SM4 symmetric encryption is relatively simple and supports two encryption modes: ECB and CBC.

- ECB electronic codebook mode, the ciphertext is divided into blocks of equal length (filled if insufficient), and encrypted block by block.
- CBC ciphertext block chaining mode, the ciphertext of the previous block and the plaintext of the current block are XORed and then encrypted.

```objc
// String encryption and decryption, the key length of HEX encoding format is 32 bytes
NSString *sm4KeyHex = @"0123456789abcdef0123456789abcdef";
NSString *plaintext = @"Hello, SM4!";

// ECB encryption. The ciphertext is in HEX encoding format
NSString *ciphertext = [GMSm4Utils encryptTextWithECB:plaintext keyHex:sm4KeyHex];
// Decryption. The decrypted result is "Hello, SM4!"
NSString *decrypted = [GMSm4Utils decryptTextWithECB:ciphertext keyHex:sm4KeyHex];

// CBC mode requires 16 bytes (32 bytes in HEX encoding format) initialization vector (IV)
NSString *ivecHex = @"0123456789abcdef0123456789abcdef";
// Encryption. The ciphertext is in HEX encoding format
NSString *ciphertext = [GMSm4Utils encryptTextWithCBC:plaintext keyHex:sm4KeyHex ivecHex:ivecHex];
// Decryption. The decrypted result is "Hello, SM4!"
NSString *decrypted = [GMSm4Utils decryptTextWithCBC:ciphertext keyHex:sm4KeyHex ivecHex:ivecHex];
```

## Version History

**Warning**: Version 4.0.0 has major changes and is incompatible with the API names of 3.x.x. Please pay attention to compilation errors if you need to upgrade.

| GMObjC Version | Supported Architecture | Compatible Platforms |    Compatible Versions    |
| :------------: | :--------------------: | :------------------: | :-----------------------: |
|     4.0.0      |      x86_64 arm64      |       iOS OSX        | iOS>= iOS 9.0, OSX>=10.13 |
|     3.3.8      |      x86_64 arm64      |         iOS          |        >= iOS 9.0         |

## License

GMObjC is released under the MIT license, see [LICENSE](https://github.com/muzipiao/GMObjC/blob/master/LICENSE) for details.
