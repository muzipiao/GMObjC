//
//  GMTestModel.h
//  GMObjC iOS Demo
//
//  Created by lifei on 2023/7/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: - NSData+Desc
@interface NSData (Desc)
- (NSString *)hexDesc;
@end

// MARK: - GMTestModel
@class GMTestItemModel;

@interface GMTestModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSMutableArray<GMTestItemModel *> *itemList;

- (instancetype)initWithTitle:(NSString *)title;

@end

// MARK: - GMTestItemModel
@interface GMTestItemModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detail;

- (instancetype)initWithTitle:(NSString *)title detail:(NSString *)detail;

@end



NS_ASSUME_NONNULL_END
