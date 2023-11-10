//
//  ViewController.m
//  Tests Host
//
//  Created by lifei on 2021/10/9.
//

#import "TestsHostVC.h"

@interface TestsHostVC ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *msgLabel;

@end

@implementation TestsHostVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.msgLabel];
    
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewTop = self.view.bounds.size.height * 0.5 - 40;
    self.titleLabel.frame = CGRectMake(0, viewTop, viewWidth, 40);
    self.msgLabel.frame = CGRectMake(0, viewTop + 40, viewWidth, 40);
}

// MARK: - Lazy Load
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        UILabel *tmpLabel = [[UILabel alloc] init];
        tmpLabel.font = [UIFont boldSystemFontOfSize:16];
        tmpLabel.textColor = [UIColor blackColor];
        tmpLabel.textAlignment = NSTextAlignmentCenter;
        tmpLabel.text = @"运行单元测试中...";
        _titleLabel = tmpLabel;
    }
    return _titleLabel;
}

- (UILabel *)msgLabel {
    if (_msgLabel == nil) {
        UILabel *tmpLabel = [[UILabel alloc] init];
        tmpLabel.font = [UIFont systemFontOfSize:14];
        tmpLabel.textAlignment = NSTextAlignmentCenter;
        tmpLabel.text = @"此 Target 为配合单元测试使用，非独立使用";
        _msgLabel = tmpLabel;
    }
    return _msgLabel;
}

@end
