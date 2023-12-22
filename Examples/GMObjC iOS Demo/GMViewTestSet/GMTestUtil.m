//
//  GMCryptoTestUtil.m
//  GMObjC iOS Demo
//
//  Created by lifei on 2023/7/28.
//

#import "GMTestUtil.h"
#import "GMObjC/GMObjC.h"

#define GMTestUtilBundle(name) [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:nil]

@implementation GMTestUtil

// MARK: - SM2 加解密
+ (GMTestModel *)testSm2EnDe {
    NSData *plainData = [@"123456" dataUsingEncoding:NSUTF8StringEncoding]; // 明文 123456 的 NSData 格式
    // 生成一对新的公私钥
    GMSm2Key *keyPair = [GMSm2Utils generateKey];
    NSString *pubKey = keyPair.publicKey; // 测试用 04 开头公钥，Hex 编码格式
    NSString *priKey = keyPair.privateKey; // 测试用私钥，Hex 编码格式
    NSData *encryptData = [GMSm2Utils encryptData:plainData publicKey:pubKey]; // 加密 NSData 类型数据
    NSData *decryptData = [GMSm2Utils decryptData:encryptData privateKey:priKey]; // 解密为 NSData 格式明文
    // 判断 sm2 加解密结果
    if ([decryptData isEqualToData:plainData]) {
        NSLog(@"sm2 加密解密成功");
    }else{
        NSLog(@"sm2 加密解密失败");
    }
    NSData *c1c3c2Data = [GMSm2Utils asn1DecodeToC1C3C2Data:encryptData hasPrefix:NO]; // ASN1 解码为 c1c3c2拼接的Data
    // 将解码后的密文顺序更改
    NSData *convertToC1C2C3 = [GMSm2Utils convertC1C3C2DataToC1C2C3:c1c3c2Data hasPrefix:NO];
    NSData *convertToC1C3C2 = [GMSm2Utils convertC1C2C3DataToC1C3C2:convertToC1C2C3 hasPrefix:NO];
    if ([convertToC1C3C2 isEqualToData:c1c3c2Data]) {
        NSLog(@"C1C3C2 顺序更改成功");
    } else {
        NSLog(@"C1C3C2 顺序更改失败");
    }
    // ASN1 编码
    NSData *asn1EncodeData = [GMSm2Utils asn1EncodeWithC1C3C2Data:c1c3c2Data hasPrefix:NO];
    // 判断 ASN1 解码编码结果，应相等
    if ([asn1EncodeData isEqualToData:encryptData]) {
        NSLog(@"ASN1 解码编码成功");
    }else{
        NSLog(@"ASN1 解码编码失败");
    }
    GMTestModel *model = [[GMTestModel alloc] initWithTitle:@"SM2加密与解密，ANS1编码与解码:"];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"生成SM2公钥" detail:pubKey]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"生成SM2私钥" detail:priKey]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"SM2加密密文" detail:encryptData.hexDesc]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"SM2解密结果" detail:decryptData.hexDesc]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"ASN1 解码SM2密文" detail:c1c3c2Data.hexDesc]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"C1C3C2 顺序SM2密文转为 C1C2C3 顺序" detail:convertToC1C2C3.hexDesc]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"ASN1编码SM2密文" detail:asn1EncodeData.hexDesc]];
    return model;
}

// MARK: - SM2 签名验签
+ (GMTestModel *)testSm2Sign {
    GMSm2Key *keyPair = [GMSm2Utils generateKey];
    NSString *pubKey = keyPair.publicKey; // 测试用 04 开头公钥，Hex 编码格式
    NSString *priKey = keyPair.privateKey; // 测试用私钥，Hex 编码格式
    NSData *plainData = [@"123456" dataUsingEncoding:NSUTF8StringEncoding]; // 明文 123456 的 NSData 格式
    // userID 传入 nil 或空时默认 1234567812345678；不为空时，签名和验签需要相同 ID
    NSString *userID = @"lifei_zdjl@qq.com"; // 普通字符串的 userID
    NSData *userData = [userID dataUsingEncoding:NSUTF8StringEncoding]; // NSData 格式的 userID
    // 签名结果是 RS 拼接的 128 字节 Hex 格式字符串，前 64 字节是 R，后 64 字节是 S
    NSString *signStr = [GMSm2Utils signData:plainData privateKey:priKey userData:userData];
    // 验证签名
    BOOL isOK = [GMSm2Utils verifyData:plainData signRS:signStr publicKey:pubKey userData:userData];
    if (isOK) {
        NSLog(@"SM2 签名验签成功");
    }else{
        NSLog(@"SM2 签名验签失败");
    }
    // 编码为 Der 格式
    NSString *derSign = [GMSm2Utils encodeDerWithSignRS:signStr];
    // 解码为 RS 字符串格式，RS 拼接的 128 字节 Hex 格式字符串，前 64 字节是 R，后 64 字节是 S
    NSString *rsStr = [GMSm2Utils decodeDerToSignRS:derSign];
    // Der 解码编码后与原文相同
    if ([rsStr isEqualToString:signStr]) {
        NSLog(@"SM2 Der 编码解码成功");
    }else{
        NSLog(@"SM2 Der 编码解码失败");
    }
    GMTestModel *model = [[GMTestModel alloc] initWithTitle:@"SM2签名与验签:"];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"SM2签名" detail:signStr]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"验签结果" detail:(isOK ? @"签名验签成功":@"签名验签失败")]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"Der编码格式SM2签名" detail:derSign]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"解码Der格式为RS拼接" detail:rsStr]];
    return model;
}

// MARK: - SM3 摘要计算
+ (GMTestModel *)testSm3 {
    NSData *plainData = [@"123456" dataUsingEncoding:NSUTF8StringEncoding]; // 明文 123456 的 NSData 格式
    // sm3 字符串摘要
    NSData *sm3DigPwd = [GMSm3Utils hashWithData:plainData];
    // sm4TestFile.txt 文件的摘要
    NSString *txtPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"sm4TestFile.txt" ofType:nil];
    NSData *fileData = [NSData dataWithContentsOfFile:txtPath];
    NSData *sm3DigFile = [GMSm3Utils hashWithData:fileData];
    
    GMTestModel *model = [[GMTestModel alloc] initWithTitle:@"SM3摘要(以字符串\"123456\"为例):"];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"字符串 123456 SM3摘要" detail:sm3DigPwd.hexDesc]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"文件 sm4TestFile.txt SM3摘要" detail:sm3DigFile.hexDesc]];
    NSString *keyStr = @"qwertyuiop1234567890"; // 服务端传过来的 key
    NSData *keyData = [keyStr dataUsingEncoding:NSUTF8StringEncoding];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"HMAC 计算摘要使用的 key" detail:keyStr]];
    NSData *hmacSM3 = [GMSm3Utils hmacWithData:plainData keyData:keyData];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"使用 SM3 计算 HMAC 摘要" detail:hmacSM3.hexDesc]];
    NSData *hmacMD5 = [GMSm3Utils hmacWithData:plainData keyData:keyData keyType:GMHashType_MD5];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"使用 MD5 计算 HMAC 摘要" detail:hmacMD5.hexDesc]];
    NSData *hmacSHA1 = [GMSm3Utils hmacWithData:plainData keyData:keyData keyType:GMHashType_SHA1];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"使用 SHA1 计算 HMAC 摘要" detail:hmacSHA1.hexDesc]];
    NSData *hmacSHA224 = [GMSm3Utils hmacWithData:plainData keyData:keyData keyType:GMHashType_SHA224];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"使用 SHA224 计算 HMAC 摘要" detail:hmacSHA224.hexDesc]];
    NSData *hmacSHA256 = [GMSm3Utils hmacWithData:plainData keyData:keyData keyType:GMHashType_SHA256];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"使用 SHA256 计算 HMAC 摘要" detail:hmacSHA256.hexDesc]];
    NSData *hmacSHA384 = [GMSm3Utils hmacWithData:plainData keyData:keyData keyType:GMHashType_SHA384];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"使用 SHA384 计算 HMAC 摘要" detail:hmacSHA384.hexDesc]];
    NSData *hmacSHA512 = [GMSm3Utils hmacWithData:plainData keyData:keyData keyType:GMHashType_SHA512];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"使用 SHA512 计算 HMAC 摘要" detail:hmacSHA512.hexDesc]];
    return model;
}

// MARK: - SM4 加解密
+ (GMTestModel *)testSm4 {
    NSData *sm4KeyData = [GMSm4Utils generateKey]; //  生成 16 字节密钥
    NSData *plainData = [@"123456" dataUsingEncoding:NSUTF8StringEncoding];
    // ECB 加解密模式
    NSData *sm4EcbCiperData = [GMSm4Utils encryptDataWithECB:plainData keyData:sm4KeyData];
    NSData *sm4EcbPlaintext = [GMSm4Utils decryptDataWithECB:sm4EcbCiperData keyData:sm4KeyData];
    
    GMTestModel *model = [[GMTestModel alloc] initWithTitle:@"SM4加密与解密:"];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"SM4密钥" detail:sm4KeyData.hexDesc]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"ECB 模式加密密文" detail:sm4EcbCiperData.hexDesc]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"ECB模式解密结果" detail:sm4EcbPlaintext.hexDesc]];
    
    // CBC 加解密模式
    NSData *ivecData = [GMSm4Utils generateKey]; // 生成 16 字节初始化向量
    NSData *sm4CbcCiperData = [GMSm4Utils encryptDataWithCBC:plainData keyData:sm4KeyData ivecData:ivecData];
    NSData *sm4CbcPlainData = [GMSm4Utils decryptDataWithCBC:sm4CbcCiperData keyData:sm4KeyData ivecData:ivecData];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"CBC模式需要的16字节向量" detail:ivecData.hexDesc]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"CBC模式加密密文" detail:sm4CbcCiperData.hexDesc]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"CBC模式解密结果" detail:sm4CbcPlainData.hexDesc]];
    
    // 加解密文件，任意文件可读取为 NSData 格式
    NSString *txtPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"sm4TestFile.txt" ofType:nil];
    NSData *fileData = [NSData dataWithContentsOfFile:txtPath];
    // 读取的文本文件
    NSString *orginStr = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    // ECB 模式加解密
    NSData *ecbCipherData = [GMSm4Utils encryptDataWithECB:fileData keyData:sm4KeyData];
    NSData *ecbDecryptData = [GMSm4Utils decryptDataWithECB:ecbCipherData keyData:sm4KeyData];
    // CBC 模式加解密
    NSData *cbcCipherData = [GMSm4Utils encryptDataWithCBC:fileData keyData:sm4KeyData ivecData:ivecData];
    NSData *cbcDecryptData = [GMSm4Utils decryptDataWithCBC:cbcCipherData keyData:sm4KeyData ivecData:ivecData];
    // 加解密后台文本不变
    NSString *sm4EcbFileStr = [[NSString alloc] initWithData:ecbDecryptData encoding:NSUTF8StringEncoding];
    NSString *sm4CbcFileStr = [[NSString alloc] initWithData:cbcDecryptData encoding:NSUTF8StringEncoding];
    
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"sm4TestFile.txt 文本文件原文" detail:orginStr]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"SM4 ECB 模式加密文件结果" detail:ecbCipherData.hexDesc]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"SM4 ECB 模式解密文件结果" detail:sm4EcbFileStr]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"SM4 CBC 模式加密文件结果" detail:cbcCipherData.hexDesc]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"SM4 CBC 模式解密文件结果" detail:sm4CbcFileStr]];
    
    return model;
}

// MARK: - ECDH 密钥协商
+ (GMTestModel *)testECDH {
    // 客户端client生成一对公私钥
    GMSm2Key *clientKey = [GMSm2Utils generateKey];
    NSString *cPubKey = clientKey.publicKey;
    NSString *cPriKey = clientKey.privateKey;
    
    // 服务端server生成一对公私钥
    GMSm2Key *serverKey = [GMSm2Utils generateKey];
    NSString *sPubKey = serverKey.publicKey;
    NSString *sPriKey = serverKey.privateKey;
    
    // 客户端client从服务端server获取公钥sPubKey，client协商出32字节对称密钥clientECDH，转Hex后为64字节
    NSString *clientECDH = [GMSm2Utils computeECDH:sPubKey privateKey:cPriKey];
    // 客户端client将公钥cPubKey发送给服务端server，server协商出32字节对称密钥serverECDH，转Hex后为64字节
    NSString *serverECDH = [GMSm2Utils computeECDH:cPubKey privateKey:sPriKey];
    
    // 在全部明文传输的情况下，client与server协商出相等的对称密钥，clientECDH==serverECDH 成立
    NSString *ecdhResult = [clientECDH isEqualToString:serverECDH] ? @"ECDH 密钥协商成功" : @"ECDH 密钥协商失败";
    GMTestModel *model = [[GMTestModel alloc] initWithTitle:@"ECDH 密钥协商:"];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"密钥协商结果" detail:ecdhResult]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"客户端计算的ECDH" detail:clientECDH]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"服务端计算的ECDH" detail:serverECDH]];
    return model;
}

// MARK: - PEM/DER文件
+ (GMTestModel *)testReadPemDerFiles {
    GMTestModel *model = [[GMTestModel alloc] initWithTitle:@"PEM/DER密钥读取:"];
    // PEM/DER文件路径
    NSString *publicPemPath = GMTestUtilBundle(@"sm2pub-1.pem");
    NSString *publicDerPath = GMTestUtilBundle(@"sm2pub-1.der");
    NSString *privatePemPath = GMTestUtilBundle(@"sm2pri-1.pem");
    NSString *privateDerPath = GMTestUtilBundle(@"sm2pri-1.der");
    NSString *private8PemPath = GMTestUtilBundle(@"sm2pri8-1.pem");
    // 读取文件到 Data
    NSData *publicPemData = [NSData dataWithContentsOfFile:publicPemPath];
    NSData *publicDerData = [NSData dataWithContentsOfFile:publicDerPath];
    NSData *privatePemData = [NSData dataWithContentsOfFile:privatePemPath];
    NSData *privateDerData = [NSData dataWithContentsOfFile:privateDerPath];
    NSData *private8PemData = [NSData dataWithContentsOfFile:private8PemPath];
    // 从PEM/DER文件中读取公私钥publicDerPath
    NSString *publicFromPem = [GMSm2Bio readPublicKeyFromPemData:publicPemData password:nil];
    NSString *publicFromDer = [GMSm2Bio readPublicKeyFromDerData:publicDerData];
    NSString *privateFromPem = [GMSm2Bio readPrivateKeyFromPemData:privatePemData password:nil];
    NSString *privateFromDer = [GMSm2Bio readPrivateKeyFromDerData:privateDerData];
    NSString *private8FromPem = [GMSm2Bio readPrivateKeyFromPemData:private8PemData password:nil];
    // 同一密钥不同格式，读取结果相同
    BOOL samePublic = [publicFromPem isEqualToString:publicFromDer];
    BOOL samePrivate1 = [privateFromPem isEqualToString:privateFromDer];
    BOOL samePrivate2 = [private8FromPem isEqualToString:privateFromDer];
    
    NSString *readResult = (samePublic && samePrivate1 && samePrivate2) ? @"Success：不同格式密钥文件读取结果一致" : @"Error: 不同格式密钥文件读取结果不一致";
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"不同格式密钥文件读取结果" detail:readResult]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"PEM格式公钥" detail:publicFromPem]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"DER格式公钥" detail:publicFromDer]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"PEM格式私钥" detail:privateFromPem]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"DER格式私钥" detail:privateFromDer]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"PKCS8-PEM格式私钥" detail:private8FromPem]];
    return model;
}

+ (GMTestModel *)testSaveToPemDerFiles {
    GMTestModel *model = [[GMTestModel alloc] initWithTitle:@"PEM/DER格式密钥文件保存:"];
    
    GMSm2Key *keyPair = [GMSm2Utils generateKey];
    NSString *pubKey = keyPair.publicKey; // 测试用 04 开头公钥，Hex 编码格式
    NSString *priKey = keyPair.privateKey; // 测试用私钥，Hex 编码格式
    // 保存公私钥的文件路径
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *publicPemPath = [tmpDir stringByAppendingPathComponent:@"t-public.pem"];
    NSString *publicDerPath = [tmpDir stringByAppendingPathComponent:@"t-public.der"];
    NSString *privatePemPath = [tmpDir stringByAppendingPathComponent:@"t-private.pem"];
    NSString *privateDerPath = [tmpDir stringByAppendingPathComponent:@"t-private.der"];
    // 将公私钥写入PEM/DER文件
    BOOL success1 = [GMSm2Bio savePublicKey:pubKey toPemFileAtPath:publicPemPath];
    BOOL success2 = [GMSm2Bio savePublicKey:pubKey toDerFileAtPath:publicDerPath];
    BOOL success3 = [GMSm2Bio savePrivateKey:priKey toPemFileAtPath:privatePemPath];
    BOOL success4 = [GMSm2Bio savePrivateKey:priKey toDerFileAtPath:privateDerPath];
    // 保存成功返回YES，失败NO
    if (success1 && success2 && success3 && success4) {
        NSLog(@"密钥保存为PEM/DER格式文件成功!");
    }
    // 读取文件到 Data
    NSData *publicPemData = [NSData dataWithContentsOfFile:publicPemPath];
    NSData *publicDerData = [NSData dataWithContentsOfFile:publicDerPath];
    NSData *privatePemData = [NSData dataWithContentsOfFile:privatePemPath];
    NSData *privateDerData = [NSData dataWithContentsOfFile:privateDerPath];
    // 测试：读取保存的PEM/DER密钥，和传入的公私钥一致
    NSString *publicFromPem = [GMSm2Bio readPublicKeyFromPemData:publicPemData password:nil];
    NSString *publicFromDer = [GMSm2Bio readPublicKeyFromDerData:publicDerData];
    NSString *privateFromPem = [GMSm2Bio readPrivateKeyFromPemData:privatePemData password:nil];
    NSString *privateFromDer = [GMSm2Bio readPrivateKeyFromDerData:privateDerData];
    
    BOOL samePublic1 = [publicFromPem isEqualToString:pubKey];
    BOOL samePublic2 = [publicFromDer isEqualToString:pubKey];
    BOOL samePrivate1 = [privateFromPem isEqualToString:priKey];
    BOOL samePrivate2 = [privateFromDer isEqualToString:priKey];
    
    NSString *saveResult = @"";
    if (samePublic1 && samePublic2 && samePrivate1 && samePrivate2) {
        saveResult = @"Success：密钥保存为PEM/DER格式文件，读取与原密钥一致";
    }else{
        saveResult = @"Error：密钥保存为PEM/DER格式文件，读取与原密钥不一致";
    }
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"密钥保存为PEM/DER格式文件结果" detail:saveResult]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"生成的公钥" detail:pubKey]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"保存后读取的公钥" detail:publicFromPem]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"生成的私钥" detail:priKey]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"保存后读取的私钥" detail:privateFromPem]];
    
    return model;
}

// 生成密钥
+ (GMTestModel *)testCreateKeyPairFiles {
    GMTestModel *model = [[GMTestModel alloc] initWithTitle:@"PEM/DER格式密钥文件创建:"];
    
    GMSm2KeyFiles *pemKeyFiles = [GMSm2Bio generatePemKeyFiles];
    GMSm2KeyFiles *derKeyFiles = [GMSm2Bio generateDerKeyFiles];
    // 读取文件到 Data
    NSData *publicPemData = [NSData dataWithContentsOfFile:pemKeyFiles.publicKeyPath];
    NSData *publicDerData = [NSData dataWithContentsOfFile:derKeyFiles.publicKeyPath];
    NSData *privatePemData = [NSData dataWithContentsOfFile:pemKeyFiles.privateKeyPath];
    NSData *privateDerData = [NSData dataWithContentsOfFile:derKeyFiles.privateKeyPath];
    
    NSString *publicFromPem = [GMSm2Bio readPublicKeyFromPemData:publicPemData password:nil];
    NSString *publicFromDer = [GMSm2Bio readPublicKeyFromDerData:publicDerData];
    NSString *privateFromPem = [GMSm2Bio readPrivateKeyFromPemData:privatePemData password:nil];
    NSString *privateFromDer = [GMSm2Bio readPrivateKeyFromDerData:privateDerData];
    
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"生成的PEM公钥" detail:publicFromPem]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"生成的PEM私钥" detail:privateFromPem]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"生成的DER公钥" detail:publicFromDer]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"生成的DER私钥" detail:privateFromDer]];
    return model;
}

// MARK: - 压缩/解压公钥
+ (GMTestModel *)testCompressPublicKey {
    GMSm2Key *keyPair = [GMSm2Utils generateKey];
    NSString *pubKey = keyPair.publicKey; // 测试用 04 开头公钥，Hex 编码格式
    NSString *compressKey = [GMSm2Utils compressPublicKey:pubKey];  // 压缩公钥
    NSString *decompressKey = [GMSm2Utils decompressPublicKey:compressKey]; // 解压公钥
    GMTestModel *model = [[GMTestModel alloc] initWithTitle:@"公钥压缩与解压:"];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"生成的SM2非压缩公钥" detail:pubKey]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"SM2公钥压缩后" detail:compressKey]];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"SM2公钥解压后" detail:decompressKey]];
    return model;
}

// MARK: - PEM与DER格式密钥互转
+ (GMTestModel *)testConvertPemAndDer {
    GMSm2Key *keyPair = [GMSm2Utils generateKey];
    NSString *pubKey = keyPair.publicKey; // 测试用 04 开头公钥，Hex 编码格式
    NSString *priKey = keyPair.privateKey; // 测试用私钥，Hex 编码格式
    // 保存公私钥的文件路径
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *pubPemPath = [tmpDir stringByAppendingPathComponent:@"t-public.pem"];
    NSString *priPemPath = [tmpDir stringByAppendingPathComponent:@"t-private.pem"];
    // 将公私钥写入PEM/DER文件
    [GMSm2Bio savePublicKey:pubKey toPemFileAtPath:pubPemPath];
    [GMSm2Bio savePrivateKey:priKey toPemFileAtPath:priPemPath];
    // 从文件读取密钥 KEY
    NSData *pubPemData = [NSData dataWithContentsOfFile:pubPemPath];
    NSData *priPemData = [NSData dataWithContentsOfFile:priPemPath];
    NSString *pubPemKey = [GMSm2Bio readPublicKeyFromPemData:pubPemData password:nil];
    NSString *priPemKey = [GMSm2Bio readPrivateKeyFromPemData:priPemData password:nil];
    // 将 PEM & DER 格式互转
    NSData *pubPemToDerData = [GMSm2Bio convertPemToDer:pubPemData isPublicKey:YES];
    NSData *priPemToDerData = [GMSm2Bio convertPemToDer:priPemData isPublicKey:NO];
    NSData *pubDerToPemData = [GMSm2Bio convertDerToPem:pubPemToDerData isPublicKey:YES];
    NSData *priDerToPemData = [GMSm2Bio convertDerToPem:priPemToDerData isPublicKey:NO];
    GMTestModel *model = [[GMTestModel alloc] initWithTitle:@"PEM与DER格式密钥互转:"];
    NSString *originKeys = [NSString stringWithFormat:@"公钥：%@\n私钥：%@", pubKey, priKey];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"创建的公钥与私钥" detail:originKeys]];
    NSString *pemKeys = [NSString stringWithFormat:@"公钥：%@\n私钥：%@", pubPemKey, priPemKey];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"存入PEM文件后公钥与私钥" detail:pemKeys]];
    NSString *pem2DerKeys = [NSString stringWithFormat:@"公钥：%@\n私钥：%@", pubPemToDerData.hexDesc, priPemToDerData.hexDesc];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"PEM转DER格式后公钥与私钥" detail:pem2DerKeys]];
    NSString *der2PemKeys = [NSString stringWithFormat:@"公钥：%@\n私钥：%@", pubDerToPemData.hexDesc, priDerToPemData.hexDesc];
    [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:@"DER转PEM格式后公钥与私钥" detail:der2PemKeys]];
    return model;
}

// MARK: - X509 格式证书读取
+ (GMTestModel *)testReadX509FileInfo {
    NSArray *x509List = @[@"bing-base64-chain.cer", @"bing-base64-single.cer", @"bing-der-single.cer",
                          @"github-base64-chain.cer", @"github-base64-single.cer", @"github-der-single.cer"];
    GMTestModel *model = [[GMTestModel alloc] initWithTitle:@"不同类型X509格式信息读取:"];
    for (NSString *fileName in x509List) {
        NSString *filePath = GMTestUtilBundle(fileName);
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        GMSm2X509Info *fileInfo = [GMSm2Bio readX509InfoFromData:fileData password:nil];
        [model.itemList addObject:[[GMTestItemModel alloc] initWithTitle:fileName detail:fileInfo.description]];
    }
    return model;
}

@end
