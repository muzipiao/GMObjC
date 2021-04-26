//
//  GMSm2BioTests.m
//  GMObjC_Tests
//
//  Created by lif on 2021/4/26.
//  Copyright © 2021 lifei. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface GMSm2BioTests : GMBaseTests

@property (nonatomic, strong) NSArray *publicPemList;   // PEM 格式公钥路径
@property (nonatomic, strong) NSArray *publicDerList;   // DER 格式公钥路径
@property (nonatomic, strong) NSArray *privatePemList;  // PEM 格式私钥路径
@property (nonatomic, strong) NSArray *privateDerList;  // DER 格式私钥路径
@property (nonatomic, strong) NSArray *private8PemList; // PKCS8-PEM 格式私钥路径

@end

@implementation GMSm2BioTests

- (void)setUp {
    [GMSm2Bio setEllipticCurveType:GMCurveType_sm2p256v1];
    
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
        
        NSString *pubPemPath = [[NSBundle mainBundle] pathForResource:pubPem ofType:nil];
        NSString *pubDerPath = [[NSBundle mainBundle] pathForResource:pubDer ofType:nil];
        NSString *priPemPath = [[NSBundle mainBundle] pathForResource:priPem ofType:nil];
        NSString *priDerPath = [[NSBundle mainBundle] pathForResource:priDer ofType:nil];
        NSString *pri8PemPath = [[NSBundle mainBundle] pathForResource:pri8Pem ofType:nil];
        XCTAssertTrue(pubPemPath&&pubDerPath&&priPemPath&&priDerPath&&pri8PemPath, @"不为空");
        
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

///MARK: - 椭圆曲线类型
- (void)testEllipticCurveType {
    int currentType = [GMSm2Utils ellipticCurveType];
    XCTAssertTrue(currentType == GMCurveType_sm2p256v1, @"当前椭圆曲线应为 NID_sm2");
}

///MARK: - NULL
- (void)testParameterNull {
    NSArray *strNilArray = @[[NSNull null], @""];
    NSArray *dataNilArray = @[[NSNull null], [NSData new]];
    
    for (NSInteger i = 0; i < 5; i++) {
        NSString *randStr = strNilArray[arc4random_uniform((uint32_t)strNilArray.count)];
        randStr = [randStr isKindOfClass:[NSNull class]] ? nil : randStr;
        XCTAssertNil([GMSm2Bio readPublicKeyFromPemFile:randStr], @"空值返回nil");
        XCTAssertNil([GMSm2Bio readPublicKeyFromDerFile:randStr], @"空值返回nil");
        XCTAssertNil([GMSm2Bio readPublicKeyFromPemString:randStr], @"空值返回nil");
        XCTAssertNil([GMSm2Bio readPrivateKeyFromPemFile:randStr], @"空值返回nil");
        XCTAssertNil([GMSm2Bio readPrivateKeyFromDerFile:randStr], @"空值返回nil");
        XCTAssertNil([GMSm2Bio readPrivateKeyFromPemString:randStr], @"空值返回nil");
        
        NSData *randData = dataNilArray[arc4random_uniform((uint32_t)dataNilArray.count)];
        randData = [randData isKindOfClass:[NSNull class]] ? nil : randData;
        XCTAssertNil([GMSm2Bio readPublicKeyFromDerData:randData], @"空值返回nil");
        XCTAssertNil([GMSm2Bio readPrivateKeyFromDerData:randData], @"空值返回nil");
    }
    // 空值密钥保存返回NO
    for (NSInteger i = 0; i < 5; i++) {
        NSString *randStr = strNilArray[arc4random_uniform((uint32_t)strNilArray.count)];
        randStr = [randStr isKindOfClass:[NSNull class]] ? nil : randStr;
        BOOL success1 = [GMSm2Bio savePublicKeyToPemFile:randStr filePath:randStr];
        BOOL success2 = [GMSm2Bio savePublicKeyToDerFile:randStr filePath:randStr];
        BOOL success3 = [GMSm2Bio savePrivateKeyToPemFile:randStr filePath:randStr];
        BOOL success4 = [GMSm2Bio savePrivateKeyToDerFile:randStr filePath:randStr];
        XCTAssertFalse(success1&&success2&&success3&&success4, @"空值密钥保存失败");
    }
    // 空值转换返回nil
    for (NSInteger i = 0; i < 5; i++) {
        NSString *randStr = strNilArray[arc4random_uniform((uint32_t)strNilArray.count)];
        randStr = [randStr isKindOfClass:[NSNull class]] ? nil : randStr;
        XCTAssertNil([GMSm2Bio convertPemToDer:randStr], @"空值转换返回nil");
        
        NSData *randData = dataNilArray[arc4random_uniform((uint32_t)dataNilArray.count)];
        randData = [randData isKindOfClass:[NSNull class]] ? nil : randData;
        XCTAssertNil([GMSm2Bio convertDerToPem:randData public:YES], @"空值转换返回nil");
        XCTAssertNil([GMSm2Bio convertDerToPem:randData public:NO], @"空值转换返回nil");
    }
}

- (void)testReadPemDerFiles {
    for (NSInteger i = 0; i < 10; i++) {
        NSString *pubPemPath = self.publicPemList[i];
        NSString *pubDerPath = self.publicDerList[i];
        NSString *priPemPath = self.privatePemList[i];
        NSString *priDerPath = self.privateDerList[i];
        NSString *pri8PemPath = self.private8PemList[i];
        
        NSString *pubPem = [GMSm2Bio readPublicKeyFromPemFile:pubPemPath];
        NSString *pubDer = [GMSm2Bio readPublicKeyFromDerFile:pubDerPath];
        NSString *priPem = [GMSm2Bio readPrivateKeyFromPemFile:priPemPath];
        NSString *priDer = [GMSm2Bio readPrivateKeyFromDerFile:priDerPath];
        NSString *pri8Pem = [GMSm2Bio readPrivateKeyFromPemFile:pri8PemPath];
        XCTAssertTrue(pubPem&&pubDer&&priPem&&priDer&&pri8Pem, @"读取密钥不为空！");
        // 同一密钥不同格式，读取结果相同
        BOOL samePub = [pubDer isEqualToString:pubPem];
        BOOL samePri1 = [priDer isEqualToString:priPem];
        BOOL samePri2 = [pri8Pem isEqualToString:priPem];
        XCTAssertTrue(samePub&&samePri1&&samePri2, @"不同格式密钥读取结果应一致");
    }
}

- (void)testSaveToPemDerFiles {
    NSString *tmpDir = NSTemporaryDirectory();
    for (NSInteger i = 0; i < 100; i++) {
        NSArray *keyPair = [GMSm2Utils createKeyPair];
        NSString *pubKey = keyPair[0]; // 测试用 04 开头公钥，Hex 编码格式
        NSString *priKey = keyPair[1]; // 测试用私钥，Hex 编码格式
        XCTAssertTrue(pubKey.length > 0 && priKey.length > 0, @"生成密钥不应为空！");
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
        BOOL success1 = [GMSm2Bio savePublicKeyToPemFile:pubKey filePath:pubPemPath];
        BOOL success2 = [GMSm2Bio savePublicKeyToDerFile:pubKey filePath:pubDerPath];
        BOOL success3 = [GMSm2Bio savePrivateKeyToPemFile:priKey filePath:priPemPath];
        BOOL success4 = [GMSm2Bio savePrivateKeyToDerFile:priKey filePath:priDerPath];
        // 保存成功返回YES，失败NO
        XCTAssertTrue(success1 && success2 && success3 && success4, @"保存成功返回YES");
        // 读取保存的PEM/DER密钥，和传入的公私钥一致
        NSString *pubFromPem = [GMSm2Bio readPublicKeyFromPemFile:pubPemPath];
        NSString *pubFromDer = [GMSm2Bio readPublicKeyFromDerFile:pubDerPath];
        NSString *priFromPem = [GMSm2Bio readPrivateKeyFromPemFile:priPemPath];
        NSString *priFromDer = [GMSm2Bio readPrivateKeyFromDerFile:priDerPath];
        XCTAssertTrue(pubFromPem&&pubFromDer&&priFromPem&&priFromDer, @"保存密钥文件不应为空");

        BOOL samePub1 = [pubFromPem isEqualToString:pubKey];
        BOOL samePub2 = [pubFromDer isEqualToString:pubKey];
        BOOL samePri1 = [priFromPem isEqualToString:priKey];
        BOOL samePri2 = [priFromDer isEqualToString:priKey];
        XCTAssertTrue(samePub1&&samePub2&&samePri1&&samePri2, @"保存读取结果应一致");
    }
}

@end
