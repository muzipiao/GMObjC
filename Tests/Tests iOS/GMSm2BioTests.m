//
//  GMSm2BioTests.m
//  GMObjC_Tests
//
//  Created by lif on 2021/4/26.
//  Copyright © 2021 lifei. All rights reserved.
//

#import "GMBaseTests.h"

@interface GMSm2BioTests : GMBaseTests

@property (nonatomic, strong) NSArray *publicPemList;   // PEM 格式公钥路径
@property (nonatomic, strong) NSArray *publicDerList;   // DER 格式公钥路径
@property (nonatomic, strong) NSArray *privatePemList;  // PEM 格式私钥路径
@property (nonatomic, strong) NSArray *privateDerList;  // DER 格式私钥路径
@property (nonatomic, strong) NSArray *private8PemList; // PKCS8-PEM 格式私钥路径

@end

@implementation GMSm2BioTests

- (void)setUp {
    [GMSm2Utils setCurveType:GMSm2CurveTypeSm2p256v1];
    
    NSMutableArray *m1 = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *m2 = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *m3 = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *m4 = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *m5 = [NSMutableArray arrayWithCapacity:10];
    for (NSInteger i = 1; i < 11; i++) {
        NSString *pubPem = [NSString stringWithFormat:@"sm2pub-%d.pem", (int)i];
        NSString *pubDer = [NSString stringWithFormat:@"sm2pub-%d.der", (int)i];
        NSString *priPem = [NSString stringWithFormat:@"sm2pri-%d.pem", (int)i];
        NSString *priDer = [NSString stringWithFormat:@"sm2pri-%d.der", (int)i];
        NSString *pri8Pem = [NSString stringWithFormat:@"sm2pri8-%d.pem", (int)i];
        
        NSString *pubPemPath = [[NSBundle bundleForClass:[self class]] pathForResource:pubPem ofType:nil];
        NSString *pubDerPath = [[NSBundle bundleForClass:[self class]] pathForResource:pubDer ofType:nil];
        NSString *priPemPath = [[NSBundle bundleForClass:[self class]] pathForResource:priPem ofType:nil];
        NSString *priDerPath = [[NSBundle bundleForClass:[self class]] pathForResource:priDer ofType:nil];
        NSString *pri8PemPath = [[NSBundle bundleForClass:[self class]] pathForResource:pri8Pem ofType:nil];
        XCTAssertTrue(pubPemPath.length > 0, @"文件地址不为空");
        XCTAssertTrue(pubDerPath.length > 0, @"文件地址不为空");
        XCTAssertTrue(priPemPath.length > 0, @"文件地址不为空");
        XCTAssertTrue(priDerPath.length > 0, @"文件地址不为空");
        XCTAssertTrue(pri8PemPath.length > 0, @"文件地址不为空");
        
        [m1 addObject:pubPemPath];
        [m2 addObject:pubDerPath];
        [m3 addObject:priPemPath];
        [m4 addObject:priDerPath];
        [m5 addObject:pri8PemPath];
    }
    self.publicPemList = m1.copy;
    self.publicDerList = m2.copy;
    self.privatePemList = m3.copy;
    self.privateDerList = m4.copy;
    self.private8PemList = m5.copy;
}

//MARK: - 椭圆曲线类型
- (void)testEllipticCurveType {
    int currentType = [GMSm2Utils curveType];
    XCTAssertTrue(currentType == GMSm2CurveTypeSm2p256v1, @"当前椭圆曲线应为 NID_sm2");
}

//MARK: - 测试NULL
- (void)testParameterNull {
    NSArray *strNilArray = @[[NSNull null], @""];
    NSArray *dataNilArray = @[[NSNull null], [NSData new]];
    
    for (NSInteger i = 0; i < 5; i++) {
        NSString *randStr = strNilArray[arc4random_uniform((uint32_t)strNilArray.count)];
        randStr = [randStr isKindOfClass:[NSNull class]] ? nil : randStr;
        NSData *randData = dataNilArray[arc4random_uniform((uint32_t)dataNilArray.count)];
        randData = [randData isKindOfClass:[NSNull class]] ? nil : randData;
        
        XCTAssertNil([GMSm2Bio readPublicKeyFromPemData:randData password:nil], @"空值返回nil");
        XCTAssertNil([GMSm2Bio readPrivateKeyFromPemData:randData password:nil], @"空值返回nil");
        
        XCTAssertNil([GMSm2Bio readPublicKeyFromDerData:randData], @"空值返回nil");
        XCTAssertNil([GMSm2Bio readPrivateKeyFromDerData:randData], @"空值返回nil");
    }
    // 空值密钥保存返回NO
    for (NSInteger i = 0; i < 5; i++) {
        NSString *randStr = strNilArray[arc4random_uniform((uint32_t)strNilArray.count)];
        randStr = [randStr isKindOfClass:[NSNull class]] ? nil : randStr;
        BOOL success1 = [GMSm2Bio savePublicKey:randStr toPemFileAtPath:randStr];
        BOOL success2 = [GMSm2Bio savePublicKey:randStr toDerFileAtPath:randStr];
        BOOL success3 = [GMSm2Bio savePrivateKey:randStr toPemFileAtPath:randStr];
        BOOL success4 = [GMSm2Bio savePrivateKey:randStr toDerFileAtPath:randStr];
        XCTAssertFalse(success1&&success2&&success3&&success4, @"空值密钥保存失败");
    }
    // 空值转换返回nil
    for (NSInteger i = 0; i < 5; i++) {
        NSData *randData = dataNilArray[arc4random_uniform((uint32_t)dataNilArray.count)];
        randData = [randData isKindOfClass:[NSNull class]] ? nil : randData;
        XCTAssertNil([GMSm2Bio convertPemToDer:randData isPublicKey:YES], @"空值转换返回nil");
        XCTAssertNil([GMSm2Bio convertPemToDer:randData isPublicKey:NO], @"空值转换返回nil");
        XCTAssertNil([GMSm2Bio convertDerToPem:randData isPublicKey:YES], @"空值转换返回nil");
        XCTAssertNil([GMSm2Bio convertDerToPem:randData isPublicKey:NO], @"空值转换返回nil");
    }
}

//MARK: - 密钥文件读取
- (void)testReadPemDerFiles {
    for (NSInteger i = 0; i < 10; i++) {
        NSString *pubPemPath = self.publicPemList[i];
        NSString *pubDerPath = self.publicDerList[i];
        NSString *priPemPath = self.privatePemList[i];
        NSString *priDerPath = self.privateDerList[i];
        NSString *pri8PemPath = self.private8PemList[i];
        // 读取文件内容，从字符串解析密钥
        NSData *pubPemData = [NSData dataWithContentsOfFile:pubPemPath];
        NSData *priPemData = [NSData dataWithContentsOfFile:priPemPath];
        NSData *pri8PemData = [NSData dataWithContentsOfFile:pri8PemPath];
        NSData *pubDerData = [NSData dataWithContentsOfFile:pubDerPath];
        NSData *priDerData = [NSData dataWithContentsOfFile:priDerPath];
        XCTAssertTrue(pubPemData.length > 0, @"从文件读取内容不为空");
        XCTAssertTrue(priPemData.length > 0, @"从文件读取内容不为空");
        XCTAssertTrue(pri8PemData.length > 0, @"从文件读取内容不为空");
        XCTAssertTrue(pubDerData.length > 0, @"从文件读取内容不为空");
        XCTAssertTrue(priDerData.length > 0, @"从文件读取内容不为空");
        
        NSString *pubPemStrKey = [GMSm2Bio readPublicKeyFromPemData:pubPemData password:nil];
        NSString *pubDerStrKey = [GMSm2Bio readPublicKeyFromDerData:pubDerData];
        NSString *priPemStrKey = [GMSm2Bio readPrivateKeyFromPemData:priPemData password:nil];
        NSString *priDerStrKey = [GMSm2Bio readPrivateKeyFromDerData:priDerData];
        NSString *pri8PemStrKey = [GMSm2Bio readPrivateKeyFromPemData:pri8PemData password:nil];
        XCTAssertTrue(pubPemStrKey.length > 0, @"解析字符串密钥不为空");
        XCTAssertTrue(pubDerStrKey.length > 0, @"解析字符串密钥不为空");
        XCTAssertTrue(priPemStrKey.length > 0, @"解析字符串密钥不为空");
        XCTAssertTrue(priDerStrKey.length > 0, @"解析字符串密钥不为空");
        XCTAssertTrue(pri8PemStrKey.length > 0, @"解析字符串密钥不为空");
        
        BOOL samePub1 = [pubDerStrKey isEqualToString:pubPemStrKey];
        BOOL samePri3 = [priDerStrKey isEqualToString:priPemStrKey];
        BOOL samePri4 = [pri8PemStrKey isEqualToString:priPemStrKey];
        XCTAssertTrue(samePub1&&samePri3&&samePri4, @"不同格式密钥字符结果应一致");
        // 测试这些密钥加解密正常
        NSData *plainData = [@"123456" dataUsingEncoding:NSUTF8StringEncoding];
        NSData *cipherData = [GMSm2Utils encryptData:plainData publicKey:pubPemStrKey];
        XCTAssertTrue(cipherData.length > 0, @"加密结果不为空");
        NSData *decryptData = [GMSm2Utils decryptToData:cipherData privateKey:priPemStrKey];
        XCTAssertTrue([decryptData isEqualToData:plainData], @"解密结果等于原文");
    }
}

//MARK: - 密钥保存至文件
- (void)testSaveToPemDerFiles {
    NSString *tmpDir = NSTemporaryDirectory();
    for (NSInteger i = 0; i < 100; i++) {
        GMSm2Key *keyPair = [GMSm2Utils generateKey];
        NSString *pubKey = keyPair.publicKey; // 测试用 04 开头公钥，Hex 编码格式
        NSString *priKey = keyPair.privateKey; // 测试用私钥，Hex 编码格式
        XCTAssertTrue(pubKey.length > 0 && priKey.length > 0, @"生成密钥不应为空");
        // 保存公私钥的文件路径
        NSString *pubPemName = [NSString stringWithFormat:@"t-pub-%d.pem", (int)i];
        NSString *pubDerName = [NSString stringWithFormat:@"t-pub-%d.der", (int)i];
        NSString *priPemName = [NSString stringWithFormat:@"t-pri-%d.pem", (int)i];
        NSString *priDerName = [NSString stringWithFormat:@"t-pri-%d.der", (int)i];
        
        NSString *pubPemPath = [tmpDir stringByAppendingPathComponent:pubPemName];
        NSString *pubDerPath = [tmpDir stringByAppendingPathComponent:pubDerName];
        NSString *priPemPath = [tmpDir stringByAppendingPathComponent:priPemName];
        NSString *priDerPath = [tmpDir stringByAppendingPathComponent:priDerName];
        // 将公私钥写入PEM/DER文件
        BOOL success1 = [GMSm2Bio savePublicKey:pubKey toPemFileAtPath:pubPemPath];
        BOOL success2 = [GMSm2Bio savePublicKey:pubKey toDerFileAtPath:pubDerPath];
        BOOL success3 = [GMSm2Bio savePrivateKey:priKey toPemFileAtPath:priPemPath];
        BOOL success4 = [GMSm2Bio savePrivateKey:priKey toDerFileAtPath:priDerPath];
        // 保存成功返回YES，失败NO
        XCTAssertTrue(success1 && success2 && success3 && success4, @"保存成功返回YES");
        // 读取保存的PEM/DER密钥，和传入的公私钥一致
        NSData *pubPemData = [NSData dataWithContentsOfFile:pubPemPath];
        NSData *pubDerData = [NSData dataWithContentsOfFile:pubDerPath];
        NSData *priPemData = [NSData dataWithContentsOfFile:priPemPath];
        NSData *priDerData = [NSData dataWithContentsOfFile:priDerPath];
        NSString *pubFromPem = [GMSm2Bio readPublicKeyFromPemData:pubPemData password:nil];
        NSString *pubFromDer = [GMSm2Bio readPublicKeyFromDerData:pubDerData];
        NSString *priFromPem = [GMSm2Bio readPrivateKeyFromPemData:priPemData password:nil];
        NSString *priFromDer = [GMSm2Bio readPrivateKeyFromDerData:priDerData];
        XCTAssertTrue(pubFromPem.length > 0, @"保存密钥文件内容不应为空");
        XCTAssertTrue(pubFromDer.length > 0, @"保存密钥文件内容不应为空");
        XCTAssertTrue(priFromPem.length > 0, @"保存密钥文件内容不应为空");
        XCTAssertTrue(priFromDer.length > 0, @"保存密钥文件内容不应为空");
        
        BOOL samePub1 = [pubFromPem isEqualToString:pubKey];
        BOOL samePub2 = [pubFromDer isEqualToString:pubKey];
        BOOL samePri1 = [priFromPem isEqualToString:priKey];
        BOOL samePri2 = [priFromDer isEqualToString:priKey];
        XCTAssertTrue(samePub1&&samePub2&&samePri1&&samePri2, @"保存读取结果应一致");
    }
}

//MARK: - PEM & DER 转换
- (void)testConvertPemAndDer {
    for (NSInteger i = 0; i < 10; i++) {
        NSString *pubPemPath = self.publicPemList[i];
        NSString *pubDerPath = self.publicDerList[i];
        NSString *priPemPath = self.privatePemList[i];
        NSString *priDerPath = self.privateDerList[i];
        // 从文件读取密钥 KEY
        NSData *pubPemData = [NSData dataWithContentsOfFile:pubPemPath];
        NSData *priPemData = [NSData dataWithContentsOfFile:priPemPath];
        NSData *pubDerData = [NSData dataWithContentsOfFile:pubDerPath];
        NSData *priDerData = [NSData dataWithContentsOfFile:priDerPath];
        NSString *pubPemKey = [GMSm2Bio readPublicKeyFromPemData:pubPemData password:nil];
        NSString *priPemKey = [GMSm2Bio readPrivateKeyFromPemData:priPemData password:nil];
        NSString *pubDerKey = [GMSm2Bio readPublicKeyFromDerData:pubDerData];
        NSString *priDerKey = [GMSm2Bio readPrivateKeyFromDerData:priDerData];
        XCTAssertTrue(pubPemKey.length > 0, @"读取密钥不为空");
        XCTAssertTrue(priPemKey.length > 0, @"读取密钥不为空");
        XCTAssertTrue(pubDerKey.length > 0, @"读取密钥不为空");
        XCTAssertTrue(priDerKey.length > 0, @"读取密钥不为空");
        // 将 PEM & DER 格式互转
        NSData *pubPemToDerData = [GMSm2Bio convertPemToDer:pubPemData isPublicKey:YES];
        NSData *priPemToDerData = [GMSm2Bio convertPemToDer:priPemData isPublicKey:NO];
        NSData *pubDerToPemData = [GMSm2Bio convertDerToPem:pubDerData isPublicKey:YES];
        NSData *priDerToPemData = [GMSm2Bio convertDerToPem:priDerData isPublicKey:NO];
        // 从转换的格式后数据读取密钥 KEY，与原始密钥对比
        NSString *pubPemKey1 = [GMSm2Bio readPublicKeyFromDerData:pubPemToDerData];
        NSString *priPemKey1 = [GMSm2Bio readPrivateKeyFromDerData:priPemToDerData];
        NSString *pubDerKey1 = [GMSm2Bio readPublicKeyFromPemData:pubDerToPemData password:nil];
        NSString *priDerKey1 = [GMSm2Bio readPrivateKeyFromPemData:priDerToPemData password:nil];
        // 转换后结果相同
        BOOL samePub1 = [pubPemKey1 isEqualToString:pubPemKey];
        BOOL samePub2 = [pubDerKey1 isEqualToString:pubDerKey];
        BOOL samePri1 = [priPemKey1 isEqualToString:priPemKey];
        BOOL samePri2 = [priDerKey1 isEqualToString:priDerKey];
        XCTAssertTrue(samePub1&&samePub2&&samePri1&&samePri2, @"转换结果应一致");
    }
}

//MARK: - 创建密钥对文件
- (void)testCreateKeyPairFiles {
    for (NSInteger i = 0; i < 100; i++) {
        GMSm2KeyFiles *derArray = [GMSm2Bio generateDerKeyFiles];
        GMSm2KeyFiles *pemArray = [GMSm2Bio generatePemKeyFiles];
        XCTAssertTrue(derArray.publicKeyPath.length > 0 && pemArray.publicKeyPath.length > 0, @"生成密钥不应为空");
        
        NSString *pubPemPath = pemArray.publicKeyPath;
        NSString *priPemPath = pemArray.privateKeyPath;
        NSString *pubDerPath = derArray.publicKeyPath;
        NSString *priDerPath = derArray.privateKeyPath;
        NSData *pubPemData = [NSData dataWithContentsOfFile:pubPemPath];
        NSData *priPemData = [NSData dataWithContentsOfFile:priPemPath];
        NSData *pubDerData = [NSData dataWithContentsOfFile:pubDerPath];
        NSData *priDerData = [NSData dataWithContentsOfFile:priDerPath];
        // 读取生成的PEM/DER密钥，确定生成成功
        NSString *pubFromPem = [GMSm2Bio readPublicKeyFromPemData:pubPemData password:nil];
        NSString *priFromPem = [GMSm2Bio readPrivateKeyFromPemData:priPemData password:nil];
        NSString *pubFromDer = [GMSm2Bio readPublicKeyFromDerData:pubDerData];
        NSString *priFromDer = [GMSm2Bio readPrivateKeyFromDerData:priDerData];
        XCTAssertTrue(pubFromPem.length > 0, @"生成密钥文件内容不应为空");
        XCTAssertTrue(priFromPem.length > 0, @"生成密钥文件内容不应为空");
        XCTAssertTrue(priFromDer.length > 0, @"生成密钥文件内容不应为空");
        XCTAssertTrue(pubFromDer.length > 0, @"生成密钥文件内容不应为空");
    }
}

@end
