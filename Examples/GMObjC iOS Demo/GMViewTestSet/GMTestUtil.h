//
//  GMTestUtil.h
//  GMObjC iOS Demo
//
//  Created by lifei on 2023/7/28.
//

#import <Foundation/Foundation.h>
#import "GMTestModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GMTestUtil : NSObject

+ (GMTestModel *)testSm2EnDe;
+ (GMTestModel *)testSm2Sign;
+ (GMTestModel *)testSm3;
+ (GMTestModel *)testSm4;
+ (GMTestModel *)testECDH;
+ (GMTestModel *)testReadPemDerFiles;
+ (GMTestModel *)testSaveToPemDerFiles;
+ (GMTestModel *)testCreateKeyPairFiles;
+ (GMTestModel *)testCompressPublicKey;
+ (GMTestModel *)testConvertPemAndDer;
+ (GMTestModel *)testReadX509FileInfo;

@end

NS_ASSUME_NONNULL_END
