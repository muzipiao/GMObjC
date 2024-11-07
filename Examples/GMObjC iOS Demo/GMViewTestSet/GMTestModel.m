//
//  GMTestModel.m
//  GMObjC iOS Demo
//
//  Created by lifei on 2023/7/28.
//

#import "GMTestModel.h"
#import "GMObjC/GMObjC.h"

// MARK: - NSData+Desc
@implementation NSData (Desc)

- (NSString *)hexDesc {
    NSString *result = [GMSmUtils hexStringFromData:self];
    return [NSString stringWithFormat:@"%@", result];
}

@end

// MARK: - GMTestModel
@implementation GMTestModel

- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        self.title = title;
    }
    return self;
}

- (NSMutableArray<GMTestItemModel *> *)itemList {
    if (_itemList == nil) {
        _itemList = [NSMutableArray array];
    }
    return _itemList;
}

@end

@implementation GMTestItemModel

- (instancetype)initWithTitle:(NSString *)title detail:(NSString *)detail {
    self = [super init];
    if (self) {
        self.title = title;
        self.detail = detail;
    }
    return self;
}

@end
