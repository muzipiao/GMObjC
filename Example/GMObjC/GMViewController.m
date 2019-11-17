//
//  GMViewController.m
//  GMObjC
//
//  Created by lifei on 08/01/2019.
//  Copyright (c) 2019 lifei. All rights reserved.
//

#import "GMViewController.h"
#import "GMObjC.h"

@interface GMViewController ()

@property (nonatomic, copy) NSString *gPwd;
@property (nonatomic, copy) NSString *gPubkey; // 公钥
@property (nonatomic, copy) NSString *gPrikey; // 私钥
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITextView *gTextView;

@end

@implementation GMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    
    self.gTextView = [[UITextView alloc]initWithFrame:self.view.bounds];
    self.gTextView.editable = NO;
    self.gTextView.font = [UIFont systemFontOfSize:11];
    [self.scrollView addSubview:self.gTextView];
    self.gPwd = @"123456";  // 测试用密码
    // 测试用的固定公私钥
    self.gPubkey = @"0408E3FFF9505BCFAF9307E665E9229F4E1B3936437A870407EA3D97886BAFBC9C624537215DE9507BC0E2DD276CF74695C99DF42424F28E9004CDE4678F63D698";
    self.gPrikey = @"90F3A42B9FE24AB196305FD92EC82E647616C3A3694441FB3422E7838E24DEAE";
    
    [self testSm2EnDe];  // sm2 加解密及 ASN1 编码解码
    [self testSm2Sign];  // sm2 签名验签及 Der 编码解码
    [self testSm3];      // sm3 摘要计算文本或文件
    [self testSm4];      // sm4 加密文本或文件
    [self testECDH];     // ECDH 密钥协商
    [self adjustText];   // 调整显示范围
}

- (void)adjustText{
    CGFloat SW = [UIScreen mainScreen].bounds.size.width;
    CGSize contentSize = [self.gTextView sizeThatFits:CGSizeMake(SW, CGFLOAT_MAX)];
    self.scrollView.frame = CGRectMake(0, 0, SW, contentSize.height);
}

// sm2 加解密
- (void)testSm2EnDe{
    // 加密
    NSString *ctext = [GMSm2Utils encrypt:self.gPwd publicKey:self.gPubkey];
    // OpenSSL 加密密文默认 ASN1 编码，有些后台无法解密，对密文解码
    NSString *dcodeCtext = [GMSm2Utils asn1Decode:ctext];
    // 解码的密文为 C1C3C2 拼接格式，解密需要转换为 ASN1 标准格式
    NSString *encodeCtext = [GMSm2Utils asn1Encode:dcodeCtext];
    // 对 ASN1 标准格式的密文进行解密
    NSString *plaintext = [GMSm2Utils decrypt:encodeCtext privateKey:self.gPrikey];
    // 生成一对新的公私钥
    NSArray *newKey = [GMSm2Utils createKeyPair];
    NSString *pubKey = newKey[0];
    NSString *priKey = newKey[1];
    
    NSMutableString *mStr = [NSMutableString stringWithString:self.gTextView.text];
    [mStr appendFormat:@"\n-------SM2加解密及编码-------\nSM2加密密文：\n%@\nASN1 解码SM2密文：\n%@\nASN1编码SM2密文：\n%@\nSM2解密结果：\n%@\n生成SM2公钥：\n%@\n生成SM2私钥：\n%@", ctext, dcodeCtext, encodeCtext, plaintext, pubKey, priKey];
    self.gTextView.text = mStr;
}

// sm2 签名验签
- (void)testSm2Sign{
    // 传入 nil 或空时默认 1234567812345678；不为空时，签名和验签需要相同 ID
    NSString *userID = @"lifei_zdjl@126.com";
    // 签名结果r,s，格式为r和s逗号分割的 16 进制字符串
    NSString *signStr = [GMSm2Utils sign:self.gPwd privateKey:self.gPrikey userID:userID];
    // 若后端验签【明文】前进行了 16 进制解码，传给后端的数据前要进行 16 进制编码
    NSString *hexPwd = [GMUtils stringToHex:self.gPwd];
    // 模拟服务端 16 进制解码，解码出【明文】再进行验签
    NSString *plainPwd = [GMUtils hexToString:hexPwd];
    /**
     * 模拟服务端验证签名，传入【明文】，签名，公钥，用户 ID
     */
    BOOL isOK = [GMSm2Utils verify:plainPwd sign:signStr publicKey:self.gPubkey userID:userID];
    NSString *result = isOK ? @"通过" : @"未通过";
    // 对签名结果 Der 编码
    NSString *derSign = [GMSm2Utils derEncode:signStr];
    // 对 Der 编码解码
    NSString *originStr = [GMSm2Utils derDecode:derSign];
    
    NSMutableString *mStr = [NSMutableString stringWithString:self.gTextView.text];
    [mStr appendFormat:@"\n-------SM2签名验签-------\nSM2签名：\n%@\n验签结果：\n%@\nDer编码SM2签名：\n%@\nDer解码SM2签名：\n%@", signStr, result, derSign, originStr];
    self.gTextView.text = mStr;
}

// sm3 摘要
- (void)testSm3{
    // sm3 字符串摘要
    NSString *sm3DigPwd = [GMSm3Utils hashWithString:self.gPwd];
    // sm4TestFile.txt 文件的摘要
    NSString *txtPath = [[NSBundle mainBundle] pathForResource:@"sm4TestFile.txt" ofType:nil];
    NSData *fileData = [NSData dataWithContentsOfFile:txtPath];
    NSString *sm3DigFile = [GMSm3Utils hashWithData:fileData];
    
    NSMutableString *mStr = [NSMutableString stringWithString:self.gTextView.text];
    [mStr appendFormat:@"\n-------SM3摘要-------\n字符串 123456 SM3摘要：\n%@\n文件 sm4TestFile.txt SM3摘要：\n%@", sm3DigPwd, sm3DigFile];
    self.gTextView.text = mStr;
}

// sm4 加解密测试
- (void)testSm4{
    NSString *sm4Key = [GMSm4Utils createSm4Key]; // 生成16位密钥
    // ECB 加解密模式
    NSString *sm4EcbCipertext = [GMSm4Utils ecbEncryptText:self.gPwd key:sm4Key];
    NSString *sm4EcbPlaintext = [GMSm4Utils ecbDecryptText:sm4EcbCipertext key:sm4Key];
    NSMutableString *mStr = [NSMutableString stringWithString:self.gTextView.text];
    [mStr appendFormat:@"\n-------SM4加解密-------\nSM4密钥：\n%@\nECB 模式加密密文：\n%@\nECB模式解密结果：\n%@", sm4Key, sm4EcbCipertext, sm4EcbPlaintext];
    // CBC 加解密模式
    NSString *ivec = [GMSm4Utils createSm4Key]; // 生成16位初始化向量
    NSString *sm4CbcCipertext = [GMSm4Utils cbcEncryptText:self.gPwd key:sm4Key IV:ivec];
    NSString *sm4CbcPlaintext = [GMSm4Utils cbcDecryptText:sm4CbcCipertext key:sm4Key IV:ivec];
    [mStr appendFormat:@"\nCBC模式需要的16字节向量：\n%@\nCBC模式加密密文：\n%@\nCBC模式解密结果：\n%@", ivec, sm4CbcCipertext, sm4CbcPlaintext];
    self.gTextView.text = mStr;
    
    // 加解密文件，任意文件可读取为 NSData 格式
    NSString *txtPath = [[NSBundle mainBundle] pathForResource:@"sm4TestFile.txt" ofType:nil];
    NSData *fileData = [NSData dataWithContentsOfFile:txtPath];
    // 读取的文本文件
    NSString *orginStr = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    NSLog(@"文本文件原文：\n%@", orginStr);
    
    // ECB 模式加解密
    NSData *ecbCipherData = [GMSm4Utils ecbEncryptData:fileData key:sm4Key];
    NSData *ecbDecryptData = [GMSm4Utils ecbDecryptData:ecbCipherData key:sm4Key];
    // CBC 模式加解密
    NSData *cbcCipherData = [GMSm4Utils cbcEncryptData:fileData key:sm4Key IV:ivec];
    NSData *cbcDecryptData = [GMSm4Utils cbcDecryptData:cbcCipherData key:sm4Key IV:ivec];
    // 加解密后台文本不变
    NSString *sm4EcbFileStr = [[NSString alloc] initWithData:ecbDecryptData encoding:NSUTF8StringEncoding];
    NSString *sm4CbcFileStr = [[NSString alloc] initWithData:cbcDecryptData encoding:NSUTF8StringEncoding];
    NSLog(@"SM4 ECB 模式加解密后文本：\n%@", sm4EcbFileStr);
    NSLog(@"SM4 CBC 模式加解密后文本：\n%@", sm4CbcFileStr);
}

// ECDH 密钥协商
- (void)testECDH{
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
}

@end
