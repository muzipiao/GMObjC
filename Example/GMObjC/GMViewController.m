//
//  GMViewController.m
//  GMObjC
//
//  Created by lifei on 08/01/2019.
//  Copyright (c) 2019 lifei. All rights reserved.
//

#import "GMViewController.h"
#import "GMSm.h"

@interface GMViewController ()

@property (nonatomic, copy) NSString *gPubkey; // 公钥
@property (nonatomic, copy) NSString *gPrikey; // 私钥
@property (nonatomic, strong) UITextView *gTextView;

@end

@implementation GMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.gTextView = [[UITextView alloc]initWithFrame:self.view.bounds];
    self.gTextView.userInteractionEnabled = NO;
    self.gTextView.font = [UIFont systemFontOfSize:10];
    [self.view addSubview:self.gTextView];
    // 测试用的固定公私钥
    self.gPubkey = @"0408E3FFF9505BCFAF9307E665E9229F4E1B3936437A870407EA3D97886BAFBC9C624537215DE9507BC0E2DD276CF74695C99DF42424F28E9004CDE4678F63D698";
    self.gPrikey = @"90F3A42B9FE24AB196305FD92EC82E647616C3A3694441FB3422E7838E24DEAE";
    [self gmTest];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.view.backgroundColor =  [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
    [self gmTest];
}

// sm2 和 sm4 加解密测试
-(void)gmTest{
    NSString *pwd = @"123456";
    // 加密
    NSString *ctext = [GMSm2Utils encrypt:pwd PublicKey:self.gPubkey];
    // OpenSSL 加密密文默认 ASN1 编码，有些后台无法解密，对密文解码
    NSString *dcodeCtext = [GMSm2Utils decodeWithASN1:ctext];
    // 解码的密文为 C1C3C2 拼接格式，解密需要转换为 ASN1 标准格式
    NSString *encodeCtext = [GMSm2Utils encodeWithASN1:dcodeCtext];
    // 对 ASN1 标准格式的密文进行解密
    NSString *plainText = [GMSm2Utils decrypt:encodeCtext PrivateKey:self.gPrikey];
    // 生成一对新的公私钥
    NSArray *newKey = [GMSm2Utils createPublicAndPrivateKey];
    NSString *pubKey = newKey[0];
    NSString *priKey = newKey[1];
    
    // sm3 摘要算法
    NSString *digest = [GMSm3Utils hashWithString:pwd];
    
    // sm4 加解密测试
    NSString *sm4Key = [GMSm4Utils createSm4Key]; // 生成16位密钥
    NSString *sm4Ctext = [GMSm4Utils encrypt:pwd Key:sm4Key];
    NSString *sm4Ptext = [GMSm4Utils decrypt:sm4Ctext Key:sm4Key];
    
    NSString *result = [NSString stringWithFormat:@"\nsm2加密密文：\n%@\nASN1 解码sm2密文：\n%@\nASN1编码sm2密文：\n%@\nsm2解密结果：\n%@\n生成sm2公钥：\n%@\n生成sm2私钥：\n%@\nsm4密钥：\n%@\nsm4加密密文：\n%@\nsm4解密结果：\n%@\n密码字符串 123456 的摘要值：\n%@\n", ctext, dcodeCtext, encodeCtext, plainText, pubKey, priKey, sm4Key, sm4Ctext, sm4Ptext, digest];
    self.gTextView.text = result;
    
    // 加解密文件，任意文件可读取为 NSData 格式
    NSString *txtPath = [[NSBundle mainBundle] pathForResource:@"sm4TestFile.txt" ofType:nil];
    NSData *fileData = [NSData dataWithContentsOfFile:txtPath];
    // 读取的文本文件
    NSString *orginStr = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    NSLog(@"文本文件原文：\n%@", orginStr);

    // 加解密
    NSData *encryptData = [GMSm4Utils encryptData:fileData Key:sm4Key];
    NSData *decryptData = [GMSm4Utils decryptData:encryptData Key:sm4Key];
    // 加解密后台文本不变
    NSString *sm4DeFileStr = [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
    NSLog(@"加解密后文本：\n%@", sm4DeFileStr);
}

@end
