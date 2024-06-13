# GMObjC

[![Build Status](https://github.com/muzipiao/GMObjC/actions/workflows/build.yml/badge.svg)](https://github.com/muzipiao/GMObjC/actions/workflows/build.yml)
[![Pod Version](https://img.shields.io/cocoapods/v/GMObjC.svg?style=flat)](https://cocoapods.org/pods/GMObjC)
[![Pod Platform](https://img.shields.io/cocoapods/p/GMObjC.svg?style=flat)](https://cocoapods.org/pods/GMObjC)
[![Pod License](https://img.shields.io/cocoapods/l/GMObjC.svg?style=flat)](https://cocoapods.org/pods/GMObjC)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/muzipiao/GMObjC)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![codecov](https://codecov.io/gh/muzipiao/GMObjC/branch/master/graph/badge.svg)](https://codecov.io/gh/muzipiao/GMObjC)

[简体中文 Readme 文档](https://github.com/muzipiao/GMObjC/blob/master/README-CN.md)

OpenSSL 1.1.1 and above adds support for chinese SM2/SM3/SM4 encryption algorithm, based on OpenSSL, SM2 asymmetric encryption, SM2 signature verification, ECDH key agreement, SM3 digest algorithm, and SM4 symmetric encryption are used for OC encapsulation.

## Getting Started

Run the following command in the terminal:

```ruby
git clone https://github.com/muzipiao/GMObjC.git

cd GMObjC

pod install

open GMObjC.xcworkspace
```

## Requirements

Depends on OpenSSL 1.1.1 or above, has been packaged as a Framework, and uploaded cocoapods, can be dragged into the project to install directly, or use cocoapods to configure the Podfile file `pod GMOpenSSL` installation; and import the system framework Security.framework.

* iOS 9.0 or later
* [GMOpenSSL.framework](https://github.com/muzipiao/GMOpenSSL)(openssl.framework)
* Security.framework

## Installation

The method of using GMObjC in the project is as follows:

* Use CocoaPods
* Use Carthage
* Compile to Framework/XCFramework
* Use Swift Package Manager
* Drag into the project source code

### CocoaPods

CocoaPods is the easiest and most convenient way to integrate. Edit Podfile, add

```ruby
pod'GMObjC'
```

Then execute `pod install`. GMObjC relies on OpenSSL 1.1.1 and above. CocoaPods does not support different versions of the same static library. If you encounter OpenSSL conflicts with third-party libraries, for example, Baidu MapKit depends on a lower version of the OpenSSL static library, a dependency conflict will occur. .

Common solutions to OpenSSL conflicts:

Method 1: Upgrade the third party library using OpenSSL to version 1.1.1 or higher. GMObjC directly shares this OpenSSL library. There is no need to add an OpenSSL dependent library for GMObjC separately, just manually integrate GMObjC;

Method 2: Compiling GMObjC into a dynamic library can resolve such conflicts. You can automatically compile GMObjC into a dynamic library through Carthage. See the next step for specific operations.

### Carthage

Carthage can automatically compile a third-party framework into a dynamic framework (Dynamic framework). If it is not installed, execute `brew update` and `brew install carthage` to install, and then create a file named Cartfile (similar to Podfile), edit and add The name of the compiled third party library is like `github "muzipiao/GMObjC"`, and then execute `carthage update --use-xcframeworks`.

```ruby
# Install carthage
brew update && brew install carthage
# Create Cartfile file and write it to github "muzipiao/GMObjC"
touch Cartfile && echo 'github "muzipiao/GMObjC"' >> Cartfile
# Pull and compile into a dynamic library, and you can find GMObjC.framework in Carthage/Build/iOS/ under the current command directory
carthage update --use-xcframeworks
```

After the compilation is successful, open Carthage to view the generated file directory. Carthage/Build/iOS/GMObjC.xcframework is the compiled dynamic library. Just drag the dynamic library into the project.

Note: GMObjC.xcframework is a dynamic library, you need to select the `Embed & Sign` mode, and you do not need to import the openssl.framework library separately. If Carthage fails to compile, download the project source code, open the project file in the GMObjCFramework folder, and execute `command + b` to compile manually.

### Swift Package Manager

GMObjC support SwiftPM from version 3.3.0. To use SwiftPM, you should use Xcode 11 to open your project. Click `File` -> `Swift Packages` -> `Add Package Dependency`, enter [GMObjC repo's URL](https://github.com/muzipiao/GMObjC.git). Or you can login Xcode with your GitHub account and just type `GMObjC` to search.

After select the package, you can choose the dependency type (tagged version, branch or commit). Then Xcode will setup all the stuff for you.

If you're a framework author and use GMObjC as a dependency, update your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/muzipiao/GMObjC.git", from: "3.3.0")
],
```

### Direct integration

Download the latest code from Git, find the GMObjC folder at the same level as the README, drag the GMObjC folder into the project, and import the header file `GMObjC.h` where you need to use SM2, SM4 encryption, decryption, and signature verification. Sign, calculate SM3 summary, etc.

Points to note when integrating OpenSSL:

1. Tools depend on OpenSSL. You can install OpenSSL through `pod GMOpenSSL`, or download [openssl.framework](https://github.com/muzipiao/GMOpenSSL), find `GMOpenSSL/openssl.framework`, and drag into the project. can.
2. If you need to self-compile OpenSSL, there is an `OpenSSL_BUILD` folder in the [GMOpenSSL](https://github.com/muzipiao/GMOpenSSL) project directory, terminal cd switch to this directory, first execute `./build -libssl.sh` command to compile and generate .a file, after waiting, execute `./create-openssl-framework.sh` command to package as framework, then openssl.framework appears in the directory.
3. The packaged static library does not expose the national secret header files. Open the downloaded source code and drag sm2.h, sm3.h, and sm4.h under the crypto/include/internal path to the openssl.framework/Headers file Just clip it.

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

### SM2 key file read-write (PEM/DER)

The SM2 public and private key format may be PEM or DER format, which can be operated with GMSm2Bio.

```objc
NSString *filePath = @"PEM or DER file address";
// Read SM2 public and private key from PEM file
NSString *pubPemKey = [GMSm2Bio readPublicKeyFromPemFile:filePath];
NSString *priPemKey = [GMSm2Bio readPrivateKeyFromPemFile:filePath];
// Read SM2 public and private key from DER file
NSString *pubDerKey = [GMSm2Bio readPublicKeyFromDerFile:filePath];
NSString *priDerKey = [GMSm2Bio readPrivateKeyFromDerFile:filePath];

NSString *savePath = @"Save SM2 public or private keys to the sandbox of the PEM/DER file";
// Save the public key string starting with 04 as a PEM or DER file, and return YES if the save is successful, otherwise NO
BOOL success1 = [GMSm2Bio savePublicKeyToPemFile:pubKey filePath:pubPemPath];
BOOL success2 = [GMSm2Bio savePublicKeyToDerFile:pubKey filePath:pubDerPath];
// Save the private key string as a PEM or DER file, return YES if saved successfully, otherwise NO
BOOL success3 = [GMSm2Bio savePrivateKeyToPemFile:priKey filePath:priPemPath];
BOOL success4 = [GMSm2Bio savePrivateKeyToDerFile:priKey filePath:priDerPath];

// Create a PEM or DER format key pair file, the array element 0 is the address of the public key file, and element 1 is the address of the private key file
NSArray<NSString *> *derFilesArray = [GMSm2Bio createDerKeyPairFiles];
NSArray<NSString *> *pemFilesArray = [GMSm2Bio createPemKeyPairFiles];
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

### SM3 Digest

Similar to md5、sha1，SM3 digest algorithm can perform digest calculation on text files, and the digest length is a 64-byte Hex encoding format string.

```objc
// Original
NSString *plaintext = @"123456"; // normal original text
NSData *plainData = [NSData dataWithBytes:"123456" length:6]; // NSData format original text

// String summary
NSString *textDigest = [GMSm3Utils hashWithString:plaintext];
// Summary of NSData
NSString *dataDigest = [GMSm3Utils hashWithData:plainData];
```

### HMAC calculation Digest

HMAC algorithm calculates the Digest, and the calculated Digest length is the same as that of the original Digest algorithm.

```objc
NSString *plaintext = @"123456"; // plaintext
NSString *randomKey = @"qwertyuiop1234567890"; // Key passed from the server
// HMAC uses SM3 digest algorithm
NSString *hmacSM3 = [GMSm3Utils hmacWithSm3:randomKey plaintext:plaintext];
// HMAC uses MD5 digest algorithm
NSString *hmacMD5 = [GMSm3Utils hmac:GMHashType_MD5 key:randomKey plaintext:plaintext];
// HMAC uses SHA1 digest algorithm
NSString *hmacSHA1 = [GMSm3Utils hmac:GMHashType_SHA1 key:randomKey plaintext:plaintext];
// HMAC uses SHA224 digest algorithm
NSString *hmacSHA224 = [GMSm3Utils hmac:GMHashType_SHA224 key:randomKey plaintext:plaintext];
// HMAC uses SHA256 digest algorithm
NSString *hmacSHA256 = [GMSm3Utils hmac:GMHashType_SHA256 key:randomKey plaintext:plaintext];
// HMAC uses SHA384 digest algorithm
NSString *hmacSHA384 = [GMSm3Utils hmac:GMHashType_SHA384 key:randomKey plaintext:plaintext];
// HMAC uses SHA512 digest algorithm
NSString *hmacSHA512 = [GMSm3Utils hmac:GMHashType_SHA512 key:randomKey plaintext:plaintext];
```

### ASN1 encoding and decoding

OpenSSL encodes the SM2 encryption results in ASN1 format. During decryption, the ciphertext encoding format is also required to be ASN1 format. After decoding, the original ciphertext spliced in c1c3c2 order is obtained.

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

### Ciphertext format conversion

After ASN1 decodes the ciphertext, the ciphertext sequence obtained is c1c3c2, and other platforms may need ciphertext in the order of c1c2c3; For example, the Java side uses bouncycastle for SM2 encryption, and the ciphertext may be the ciphertext beginning with **04** and arranged according to c1c2c3.

OpenSSL decryption requires the ciphertext to be arranged in c1c3c2 and ASN1 encoding format. Conversion is required in both cases. For the ciphertext encrypted by bouncycastle, the ciphertext format needs to be changed from c1c2c3 to c1c3c2, then ASN1 coding and decryption.

Generally, the ciphertext does not contain **ciphertext format identification**. As for whether it does, it can be confirmed by observation or with other platforms. The common identification at the beginning of the ciphertext.

* 02 or 03 compressed representation
* 04 uncompressed representation
* 06 or 07 mixed representation

```objc
NSString *ciphertext = @"C1C2C3 Sequential ciphertext";
// Change the ciphertext in c1c2c3 order to c1c3c2 order
NSString *c1c3c2 = [GMSm2Utils convertC1C2C3ToC1C3C2:c1c2c3 hasPrefix:NO];
// ASN1 encoding, encoding the ciphertext in c1c3c2 order into ASN1 format
NSString *asn1Result = [GMSm2Utils asn1EncodeWithC1C3C2:c1c3c2];
// Decrypt to plain text string
NSString *deResult1 = [GMSm2Utils decryptToText:asn1Result privateKey:priKey]; 
// If necessary, you can change the ciphertext in c1c3c2 order to c1c2c3 order
NSString *c1c2c3 = [GMSm2Utils convertC1C3C2ToC1C2C3:c1c3c2 hasPrefix:NO];
```

Ciphertext splitting principle: Assuming that the ciphertext without ASN1 coding is in hex coding (hexadecimal coding) format and arranged in the order of c1c2c3, it is known that C1 length is fixed at 128 bytes and C3 length is fixed at 64 bytes, then C2 length = total length of ciphertext string - C1 length 128 - C3 length, so C1, C2 and C3 strings are obtained respectively and spliced freely.

### Generate public and private keys

Based on the SM2 recommended curve (a 256-bit elliptic curve in the prime field), a public and private key is generated.

```objc
NSArray *keyPair = [GMSm2Utils createKeyPair];
NSString *pubKey = keyPair[0]; // The public key at the beginning of 04, Hex encoding format
NSString *priKey = keyPair[1]; // Private key, Hex encoding format
```
## SM2 Curves

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

## Possible errors

### The binary file was rejected due to signature review:

```text
ITMS-91065: Missing signature - Your app includes “Frameworks/OpenSSL.framework/OpenSSL”, which includes BoringSSL / openssl_grpc, an SDK that was identified in the documentation as a privacy-impacting third-party SDK. If a new app includes a privacy-impacting SDK, or an app update adds a new privacy-impacting SDK, the SDK must include a signature file. Please contact the provider of the SDK that includes this file to get an updated SDK version with a signature.
```

**Solution**, manually sign the specified binary file, please refer to [issues 92](https://github.com/muzipiao/GMObjC/issues/92).

```shell
# Check the signature, no signature is displayed code object is not signed at all
codesign -dv openssl.xcframework
# Copy the certificate name in the keychain and execute this command to sign.
xcrun codesign --timestamp -s "full name of certificate" openssl.xcframework
# Verify signature
xcrun codesign --verify --verbose openssl.xcframework
```

### Xcode compilation error 1:

```text
Building for iOS, but the linked and embedded framework 'GMObjC.framework' was built for iOS + iOS Simulator.
```

**Solution**, select the project path `Build Settings-Build Options-Validate Workspace` and change it to YES/NO, and change it once.

### Xcode compilation error 2:

```text
building for iOS Simulator, but linking in object file built for iOS, for architecture arm64
```

**Solution**, select the project path `Build Settings-Architectures-Excluded Architecture`, select `Any iOS Simulator SDK` to add arm64, refer to [stackoverflow solution](https://stackoverflow.com/questions/63607158/xcode-12-building-for-ios-simulator-but-linking-in-object-file-built-for-ios).

## Other

If you find it helpful, please give a Star ⭐️ on [GitHub GMObjC](https://github.com/muzipiao/GMObjC), your encouragement is my motivation
