# GMObjC

[![CI Status](https://img.shields.io/travis/muzipiao/GMObjC.svg?style=flat)](https://travis-ci.org/muzipiao/GMObjC)
[![codecov](https://codecov.io/gh/muzipiao/GMObjC/branch/master/graph/badge.svg)](https://codecov.io/gh/muzipiao/GMObjC)
[![Version](https://img.shields.io/cocoapods/v/GMObjC.svg?style=flat)](https://cocoapods.org/pods/GMObjC)
[![License](https://img.shields.io/cocoapods/l/GMObjC.svg?style=flat)](https://cocoapods.org/pods/GMObjC)
[![Platform](https://img.shields.io/cocoapods/p/GMObjC.svg?style=flat)](https://cocoapods.org/pods/GMObjC)

[简体中文](https://github.com/muzipiao/GMObjC/blob/master/README-CN.md)

OpenSSL 1.1.1 and above adds support for chinese SM2/SM3/SM4 encryption algorithm, based on OpenSSL, SM2 asymmetric encryption, SM2 signature verification, ECDH key agreement, SM3 digest algorithm, and SM4 symmetric encryption are used for OC encapsulation.

## Getting Started

Run the following command in the terminal:

```ruby
git clone https://github.com/muzipiao/GMObjC.git

cd GMObjC/Example

pod install

open GMObjC.xcworkspace
```

## Requirements

Depends on OpenSSL 1.1.1 or above, has been packaged as a Framework, and uploaded cocoapods, can be dragged into the project to install directly, or use cocoapods to configure the Podfile file `pod GMOpenSSL` installation; and import the system framework Security.framework.

* [GMOpenSSL.framework](https://github.com/muzipiao/GMOpenSSL)(openssl.framework)
* Security.framework

## Installation

There are three ways to use GMObjC in your project:

* using CocoaPods
* using Carthage
* manual install (build frameworks or embed Xcode Project)

### CocoaPods

CocoaPods is the easiest and most convenient way to integrate. Edit Podfile, add

```ruby
pod'GMObjC'
```

Then execute `pod install`. GMObjC relies on OpenSSL 1.1.1 and above. CocoaPods does not support different versions of the same static library. If you encounter OpenSSL conflicts with third-party libraries, for example, Baidu MapKit depends on a lower version of the OpenSSL static library, a dependency conflict will occur. .

Common solutions to OpenSSL conflicts:

Method 1: Upgrade the third party library using OpenSSL to version 1.1.1 or higher. GMObjC directly shares this OpenSSL library. There is no need to add an OpenSSL dependent library for GMObjC separately, just manually integrate GMObjC;

Method 2: Compiling GMObjC into a dynamic library can resolve such conflicts. The dynamic library project is in the GMObjCFramework folder, open the project and execute `command + b` to compile it into a real machine/emulator version dynamic library, and merge as needed; you can also automatically compile GMObjC into a dynamic library through Carthage. See the next step for specific operations.

### Carthage

Carthage can automatically compile a third-party framework into a dynamic framework (Dynamic framework). If it is not installed, execute `brew update` and `brew install carthage` to install, and then create a file named Cartfile (similar to Podfile), edit and add The name of the compiled third party library is like `github "muzipiao/GMObjC"`, and then execute `carthage update`.

```ruby
# Install carthage
brew update && brew install carthage
# Create Cartfile file and write it to github "muzipiao/GMObjC"
touch Cartfile && echo'github "muzipiao/GMObjC"' >> Cartfile
# Pull and compile into a dynamic library, and you can find GMObjC.framework in Carthage/Build/iOS/ under the current command directory
carthage update
```

After the compilation is successful, open Carthage to view the generated file directory. Carthage/Build/iOS/GMObjC.framework is the compiled dynamic library. Just drag the dynamic library into the project.

Note: GMObjC.framework is a dynamic library, you need to select the `Embed & Sign` mode, and you do not need to import the openssl.framework library separately. If Carthage fails to compile, download the project source code, open the project file in the GMObjCFramework folder, and execute `command + b` to compile manually.

### Direct integration

Download the latest code from Git, find the GMObjC folder at the same level as the README, drag the GMObjC folder into the project, and import the header file `GMObjC.h` where you need to use SM2, SM4 encryption, decryption, and signature verification. Sign, calculate SM3 summary, etc.

Points to note when integrating OpenSSL:

1. Tools depend on OpenSSL. You can install OpenSSL through `pod GMOpenSSL`, or download [openssl.framework](https://github.com/muzipiao/GMOpenSSL), find `GMOpenSSL/openssl.framework`, and drag into the project. can.
2. If you need to self-compile OpenSSL, there is an `OpenSSL_BUILD` folder in the [GMOpenSSL](https://github.com/muzipiao/GMOpenSSL) project directory, terminal cd switch to this directory, first execute `./build -libssl.sh` command to compile and generate .a file, after waiting, execute `./create-openssl-framework.sh` command to package as framework, then openssl.framework appears in the directory.
3. The packaged static library does not expose the national secret header files. Open the downloaded source code and drag sm2.h, sm3.h, and sm4.h under the crypto/include/internal path to the openssl.framework/Headers file Just clip it.

### Xcode compilation errors that may be encountered during integration

Error 1：

```text
Building for iOS, but the linked and embedded framework 'GMObjC.framework' was built for iOS + iOS Simulator.
```

As a solution, select the project path `Build Settings-Build Options-Validate Workspace` and change it to YES/NO, and change it once.

Error 2：

```text
building for iOS Simulator, but linking in object file built for iOS, for architecture arm64
```
The solution, select the project path `Build Settings-Architectures-Excluded Architecture`, select `Any iOS Simulator SDK` to add arm64, refer to [stackoverflow solution](https://stackoverflow.com/questions/63607158/xcode-12-building-for-ios-simulator-but-linking-in-object-file-built-for-ios)。

## How To Use

### SM2 encryption and decryption

SM2 encryption and decryption are very simple, encrypt the incoming plaintext and public key to be encrypted, and decrypt the incoming ciphertext and private key. The code:

```objc
// public key
NSString *pubKey = @"0408E3FFF9505BCFAF9307E665E9229F4E1B3936437A870407EA3D97886BAFBC9"
                    "C624537215DE9507BC0E2DD276CF74695C99DF42424F28E9004CDE4678F63D698";
// private key
NSString *prikey = @"90F3A42B9FE24AB196305FD92EC82E647616C3A3694441FB3422E7838E24DEAE";

// plaintext
NSString *plaintext = @"123456"; // ordinary plaintext
NSString *plainHex = @"313233343536"; // Hex format character plain text (The Hex code of 123456 is 313233343536)
NSData *plainData = [NSData dataWithBytes:"123456" length:6]; // NSData format plain text

// sm2 encryption
NSString *enResult1 = [GMSm2Utils encryptText:plaintext publicKey:pubKey]; // encrypt ordinary string
NSString *enResult2 = [GMSm2Utils encryptHex:plainHex publicKey:pubKey]; // Encrypted Hex encoding format string
NSData *enResult3 = [GMSm2Utils encryptData:plainData publicKey:pubKey]; // Encrypt NSData type data

// sm2 decrypt
NSString *deResult1 = [GMSm2Utils decryptToText:enResult1 privateKey:priKey]; // Decrypt to plain text of ordinary string
NSString *deResult2 = [GMSm2Utils decryptToHex:enResult2 privateKey:priKey]; // Decrypt to plain text in Hex format
NSData *deResult3 = [GMSm2Utils decryptToData:enResult3 privateKey:priKey]; // Decrypt to plain text in NSData format
```

**note:**

1. The public key used by OpenSSL starts with 04, which means the uncompressed public key format. The public key returned in the background may not carry 04, and manual splicing is required.
2. The decryption result returned by the background may be the original ciphertext C1C3C2 format without standard encoding, and the encryption and decryption of OpenSSL requires the ASN1 encoding format, so in the process of interacting with the background, ASN1 encoding and decoding may be required.

### SM2 Signature Verification

SM2 private key signature, public key verification, anti-tampering or identity verification. Pass in plain text, private key and user ID when signing; pass in plain text, signature, public key and user ID when signing, code:

```objc
// public key
NSString *pubKey = @"0408E3FFF9505BCFAF9307E665E9229F4E1B3936437A870407EA3D97886BAFBC9"
                    "C624537215DE9507BC0E2DD276CF74695C99DF42424F28E9004CDE4678F63D698";
// private key
NSString *prikey = @"90F3A42B9FE24AB196305FD92EC82E647616C3A3694441FB3422E7838E24DEAE";

// plaintext
NSString *plaintext = @"123456"; // ordinary plaintext
NSString *plainHex = @"313233343536"; // Hex format character plain text (The Hex code of 123456 is 313233343536)
NSData *plainData = [NSData dataWithBytes:"123456" length:6]; // NSData format plain text

// When userID is passed in nil or empty, the default is 1234567812345678; when it is not empty, the signature and verification need the same ID
NSString *userID = @"lifei_zdjl@126.com"; // userID of ordinary string
NSString *userHex = [GMUtils stringToHex:userID]; // userID in Hex format
NSData *userData = [userID dataUsingEncoding:NSUTF8StringEncoding]; // userID in NSData format

// The signature result is a 128-byte Hex format string spliced ​​by RS, the first 64 bytes are R, and the last 64 bytes are S
NSString *signStr1 = [GMSm2Utils signText:plaintext privateKey:priKey userID:userID];
NSString *signStr2 = [GMSm2Utils signHex:plainHex privateKey:priKey userHex:userHex];
NSString *signStr3 = [GMSm2Utils signData:plainData priKey:priKey userData:userData];

// Verify the signature, YES means the verification passed
BOOL isOK1 = [GMSm2Utils verifyText:plaintext signRS:signStr1 publicKey:pubKey userID:userID];
BOOL isOK2 = [GMSm2Utils verifyHex:plainHex signRS:signStr2 publicKey:pubKey userHex:userHex];
BOOL isOK3 = [GMSm2Utils verifyData:plainData signRS:signStr3 pubKey:pubKey userData:userData];

// Encoded in Der format, Der encoding and decoding should be the same as the original value
NSString *derSign1 = [GMSm2Utils derEncode:signStr1];
NSString *derSign2 = [GMSm2Utils derEncode:signStr2];
NSString *derSign3 = [GMSm2Utils derEncode:signStr3];

// Decode into RS string format, RS spliced ​​128-byte Hex format string, the first 64 bytes are R, the last 64 bytes are S
NSString *rs1 = [GMSm2Utils derDecode:derSign1];
NSString *rs2 = [GMSm2Utils derDecode:derSign2];
NSString *rs3 = [GMSm2Utils derDecode:derSign3];
```

note:

1. The user ID can be passed a null value. When passing a null value, the OpenSSL default user ID is used. The default user definition in OpenSSL is `#define SM2_DEFAULT_USERID "1234567812345678"`. The client and server user IDs must be consistent.
2. During the interaction between the client and the background, assuming the background signature, the client verifies the signature, and the signature returned by the background is in DER encoding format, the signature needs to be DER decoded first, and then the signature is verified. In the same way, if the client signs, the background verifies the signature, and encodes and decodes according to whether the background requires RS splicing format signature or DER format.

### ECDH key agreement

The `ECDH_compute_key()` in OpenSSL performs elliptic curve Diffie-Hellman key agreement, which can negotiate the same key when both parties are transmitting in plain text.

Negotiation process:

1. The client randomly generates a pair of public and private keys clientPublicKey, clientPrivateKey;
2. The server randomly generates a pair of public and private keys serverPublicKey, serverPrivateKey;
3. The two parties exchange public keys clientPublicKey and serverPublicKey using network requests or other methods, and the private keys are kept by themselves;
4. Client calculation `clientKey = ECDH_compute_key(clientPrivateKey, serverPublicKey)`;
5. Server-side calculation `serverKey = ECDH_compute_key(serverPrivateKey, clientPublicKey)`;
6. The clientKey and serverKey calculated by both parties should be equal, and this key can be used as the key for symmetric encryption.

```objc
// The client generates a pair of public and private keys
NSArray *clientKey = [GMSm2Utils createKeyPair];
NSString *cPubKey = clientKey[0];
NSString *cPriKey = clientKey[1];

// The server generates a pair of public and private keys
NSArray *serverKey = [GMSm2Utils createKeyPair];
NSString *sPubKey = serverKey[0];
NSString *sPriKey = serverKey[1];

// The client obtains the public key sPubKey from the server, and the client negotiates a 32-byte symmetric key clientECDH, which is 64 bytes after being converted to Hex
NSString *clientECDH = [GMSm2Utils computeECDH:sPubKey privateKey:cPriKey];
// The client sends the public key cPubKey to the server, and the server negotiates a 32-byte symmetric key serverECDH, which is 64 bytes after being converted to Hex
NSString *serverECDH = [GMSm2Utils computeECDH:cPubKey privateKey:sPriKey];

// In the case of all plaintext transmission, the client and the server negotiate an equal symmetric key, clientECDH==serverECDH is established
if ([clientECDH isEqualToString:serverECDH]) {
    NSLog(@"ECDH key negotiation is successful, the negotiated symmetric key is:\n%@", clientECDH);
}else{
    NSLog(@"ECDH key negotiation failed");
}
```

### SM4 encryption and decryption

SM4 encryption and decryption are very simple, encrypt the incoming string and key to be encrypted, and decrypt the incoming ciphertext and key, the code:

* ECB electronic codebook mode, the ciphertext is divided into blocks of equal length (not enough to fill), and block by block is encrypted.
* CBC ciphertext grouping link mode, the ciphertext of the previous group and the plaintext of the current group are XORed and then encrypted.

```objc

NSString *sm4Key = @"EA4EBDC1DCEAEC733FFD358BA15E8DCD"; // 32-byte Hex encoding format string key
NSString *ivec = @"1AFE5CC82D2DE304343FED0AF5FDE7FA"; // 32-byte initialization vector, required for CBC encryption mode

// plaintext
NSString *plaintext = @"123456"; // ordinary plaintext
NSData *plainData = [NSData dataWithBytes:"123456" length:6]; // NSData format plain text

// ECB encryption mode
NSString *ecbCipertext = [GMSm4Utils ecbEncryptText:plaintext key:sm4Key]; // Encrypt plain text of ordinary string
NSData *ecbCipherData = [GMSm4Utils ecbEncryptData:plainData key:sm4Key]; // Encrypt NSData type plaintext
// ECB decryption mode
NSString *ecbPlaintext = [GMSm4Utils ecbDecryptText:ecbCipertext key:sm4Key];
NSData *ecbDecryptData = [GMSm4Utils ecbDecryptData:ecbCipherData key:sm4Key];

// CBC encryption mode
NSString *cbcCipertext = [GMSm4Utils cbcEncryptText:plaintext key:sm4Key IV:ivec];
NSData *cbcCipherData = [GMSm4Utils cbcEncryptData:plainData key:sm4Key IV:ivec];
// CBC decryption mode
NSString *cbcPlaintext = [GMSm4Utils cbcDecryptText:cbcCipertext key:sm4Key IV:ivec];
NSData *cbcDecryptData = [GMSm4Utils cbcDecryptData:cbcCipherData key:sm4Key IV:ivec];
```

### SM3 Summary

Similar to hash and md5, SM3 digest algorithm can perform digest calculation on text files, and the digest length is a 64-byte Hex encoding format string.

```objc
// Original
NSString *plaintext = @"123456"; // normal original text
NSData *plainData = [NSData dataWithBytes:"123456" length:6]; // NSData format original text

// String summary
NSString *textDigest = [GMSm3Utils hashWithString:plaintext];
// Summary of NSData
NSString *dataDigest = [GMSm3Utils hashWithData:plainData];
```

### ASN1 encoding and decoding

OpenSSL performs ASN1 encoding on the SM2 encryption result, and the ciphertext encoding format is also required to be ASN1 format when decrypting. Encryption and decryption on other platforms may require the original ciphertext spliced ​​by C1C3C2, so encoding and decoding is required. Individual back-end encryption and decryption are spliced ​​according to C1C2C3, or other orders. If encryption and decryption is not possible, confirm the splicing order with the background and splice by yourself.

```objc
// public key
NSString *pubKey = @"0408E3FFF9505BCFAF9307E665E9229F4E1B3936437A870407EA3D97886BAFBC9"
                    "C624537215DE9507BC0E2DD276CF74695C99DF42424F28E9004CDE4678F63D698";
// private key
NSString *prikey = @"90F3A42B9FE24AB196305FD92EC82E647616C3A3694441FB3422E7838E24DEAE";

// plaintext
NSString *plaintext = @"123456"; // ordinary plaintext
NSString *plainHex = @"313233343536"; // Hex format character plain text (The Hex code of 123456 is 313233343536)
NSData *plainData = [NSData dataWithBytes:"123456" length:6]; // NSData format plain text

// sm2 encryption result, ASN1 encoded cipher text
NSString *enResult1 = [GMSm2Utils encryptText:plaintext publicKey:pubKey]; // encrypt ordinary string
NSString *enResult2 = [GMSm2Utils encryptHex:plainHex publicKey:pubKey]; // Encrypted Hex encoding format string
NSData *enResult3 = [GMSm2Utils encryptData:plainData publicKey:pubKey]; // Encrypt NSData type data

// ASN1 decoding, decode the ciphertext in ASN1 encoding format string, array or NSData
NSString *c1c3c2Result1 = [GMSm2Utils asn1DecodeToC1C3C2:enResult1]; // Decode to c1c3c2 string
NSArray<NSString *> *c1c3c2Result2 = [GMSm2Utils asn1DecodeToC1C3C2Array:enResult2]; // decoded as @[c1,c3,c2]
NSData *c1c3c2Result3 = [GMSm2Utils asn1DecodeToC1C3C2Data:enResult3]; // decoded as data spliced ​​by c1c3c2

// ASN1 encoding, re-encoding the decoded c1c3c2 ciphertext into ASN1 format, which should be exactly the same as enResult1, enResult2, and enResult3
NSString *asn1Result1 = [GMSm2Utils asn1EncodeWithC1C3C2:c1c3c2Result1];
NSString *asn1Result2 = [GMSm2Utils asn1EncodeWithC1C3C2Array:c1c3c2Result2];
NSData *asn1Result3 = [GMSm2Utils asn1EncodeWithC1C3C2Data:c1c3c2Result3];
```

How to split a ciphertext string? Assuming that the Hex code (hexadecimal code) format ciphertext is arranged according to C1C2C3, it is known that the length of C1 is fixed to 128 bytes, and the length of C3 is fixed to 64 bytes, then C2 length = total length of ciphertext string-C1 length 128 -C3 length, in this way, C1, C2, and C3 strings are obtained respectively, which can be spliced ​​freely.

Assuming that the ciphertext of the Hex encoding format is arranged in C1C2C3, C1, C2, and C3 can be split in the following way.

```objc
// Hex encoding format ciphertext must be greater than 192, pay attention to judge the length before intercepting the string
NSString *C1C2C3 = @"1C03C16FEFB1...Assuming here is the ciphertext arranged in C1C2C3...0B8ECAE42AD68B";
// Random point C1 of elliptic curve has a fixed length of 128 (Hex encoding format)
NSString *C1 = [C1C2C3 substringToIndex:128];
// The ciphertext digest value C3 has a fixed length of 64 (Hex encoding format)
NSString *C3 = [C1C2C3 substringFromIndex:(C1C2C3.length-64)];
// Length of C2 in ciphertext = total length of ciphertext string-C1 length (128)-C3 length (64)
NSString *C2 = [C1C2C3 substringWithRange:NSMakeRange(128, C1C2C3.length-C1.length-C3.length)];
```

### Generate public and private keys

Based on the SM2 recommended curve (a 256-bit elliptic curve in the prime field), a public and private key is generated.

```objc
NSArray *keyPair = [GMSm2Utils createKeyPair];
NSString *pubKey = keyPair[0]; // The public key at the beginning of 04, Hex encoding format
NSString *priKey = keyPair[1]; // Private key, Hex encoding format
```
## SM2 曲线

1. GM/T 0003-2012 standard recommended parameters sm2p256v1 (NID_sm2);
2. SM2 If you need to use other curves, call `[GMSm2Utils setEllipticCurveType:*]` and pass in the int type;
3. How to find the required curve, the three most common curves sm2p256v1, secp256k1, secp256r1 are listed in the GMSm2Utils header file enumeration;
4. If it is another curve, you can find it in the OpenSSL source code crypto/ec/ec_curve.c and input the int type.

GMCurveType in GMSm2Utils.h file corresponds to curve parameters:

```text
ECC recommended parameters: sm2p256v1 (corresponding to NID_sm2 in OpenSSL)
p   = FFFFFFFE FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF 00000000 FFFFFFFF FFFFFFFF
a   = FFFFFFFE FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF 00000000 FFFFFFFF FFFFFFFC
b   = 28E9FA9E 9D9F5E34 4D5A9E4B CF6509A7 F39789F5 15AB8F92 DDBCBD41 4D940E93
n   = FFFFFFFE FFFFFFFF FFFFFFFF FFFFFFFF 7203DF6B 21C6052B 53BBF409 39D54123
Gx =  32C4AE2C 1F198119 5F990446 6A39C994 8FE30BBF F2660BE1 715A4589 334C74C7
Gy =  BC3736A2 F4F6779C 59BDCEE3 6B692153 D0A9877C C62A4740 02DF32E5 2139F0A0

ECC recommended parameters: secp256k1 (corresponding to NID_secp256k1 in OpenSSL)
p   = FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE FFFFFC2F
a   = 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
b   = 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000007
n   = FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE BAAEDCE6 AF48A03B BFD25E8C D0364141
Gx =  79BE667E F9DCBBAC 55A06295 CE870B07 029BFCDB 2DCE28D9 59F2815B 16F81798
Gy =  483ADA77 26A3C465 5DA4FBFC 0E1108A8 FD17B448 A6855419 9C47D08F FB10D4B8

ECC recommended parameters: secp256r1 (corresponding to NID_X9_62_prime256v1 in OpenSSL)
p   = FFFFFFFF 00000001 00000000 00000000 00000000 FFFFFFFF FFFFFFFF FFFFFFFF
a   = FFFFFFFF 00000001 00000000 00000000 00000000 FFFFFFFF FFFFFFFF FFFFFFFC
b   = 5AC635D8 AA3A93E7 B3EBBD55 769886BC 651D06B0 CC53B0F6 3BCE3C3E 27D2604B
n   = FFFFFFFF 00000000 FFFFFFFF FFFFFFFF BCE6FAAD A7179E84 F3B9CAC2 FC632551
Gx  = 6B17D1F2 E12C4247 F8BCE6E5 63A440F2 77037D81 2DEB33A0 F4A13945 D898C296
Gy  = 4FE342E2 FE1A7F9B 8EE7EB4A 7C0F9E16 2BCE3357 6B315ECE CBB64068 37BF51F5
```

## Other

If you find it helpful, please give a Star ⭐️ on [GitHub GMObjC](https://github.com/muzipiao/GMObjC), your encouragement is my motivation
