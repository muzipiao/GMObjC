//
//  GMTestCell.h
//  GMObjC iOS Demo
//
//  Created by lifei on 2023/7/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: - GMTestHeader
@interface GMTestHeader : UITableViewHeaderFooterView

@property (nonatomic, strong) UILabel *titleLabel;

@end

// MARK: - GMTestCell
@interface GMTestCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *bubbleButton;

@end

NS_ASSUME_NONNULL_END
