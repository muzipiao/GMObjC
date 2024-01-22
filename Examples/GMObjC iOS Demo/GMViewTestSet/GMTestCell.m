//
//  GMTestCell.m
//  GMObjC iOS Demo
//
//  Created by lifei on 2023/7/25.
//

#import "GMTestCell.h"

// MARK: - GMTestHeader
@implementation GMTestHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithRed:(65.0 / 255.0) green:(80.0 / 255.0) blue:(98.0 / 255.0) alpha:1.0];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:12],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-12],
            [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0],
            [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:0]
        ]];
    }
    return self;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        tmpLabel.font = [UIFont boldSystemFontOfSize:18];
        tmpLabel.textColor = [UIColor whiteColor];
        _titleLabel = tmpLabel;
    }
    return _titleLabel;
}

@end

// MARK: - GMTestCell
@implementation GMTestCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.bubbleButton];
        [self setupConstraints];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bubbleButton.hidden = !self.isSelected;
}

- (void)setupConstraints {
    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:12],
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-12]
    ]];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.contentLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:12],
        [self.contentLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:8],
        [self.contentLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-12],
        [self.contentLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8]
    ]];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.bubbleButton.widthAnchor constraintEqualToConstant:70.0],
        [self.bubbleButton.heightAnchor constraintEqualToConstant:28.0],
        [self.bubbleButton.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:4],
        [self.bubbleButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-12],
    ]];
}

// MARK: - Actions
- (void)bubbleBtnClick:(UIButton *)sender {
    if (self.contentLabel.text.length == 0) {
        return;
    }
    UIPasteboard *paste = [UIPasteboard generalPasteboard];
    [paste setString:self.contentLabel.text];
    
    sender.selected = YES;
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if (!self) return;
        sender.selected = NO;
    });
}

// MARK: - Lazy Load
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        tmpLabel.font = [UIFont systemFontOfSize:16];
        tmpLabel.textColor = [UIColor colorWithRed:(47.0 / 255.0) green:(56.0 / 255.0) blue:(86.0 / 255.0) alpha:1.0];
        tmpLabel.translatesAutoresizingMaskIntoConstraints = NO;
        tmpLabel.lineBreakMode = NSLineBreakByWordWrapping;
        tmpLabel.numberOfLines = 0;
        _titleLabel = tmpLabel;
    }
    return _titleLabel;
}

- (UILabel *)contentLabel {
    if (_contentLabel == nil) {
        UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        tmpLabel.font = [UIFont systemFontOfSize:14];
        tmpLabel.textColor = [UIColor colorWithRed:(94.0 / 255.0) green:(99.0 / 255.0) blue:(123.0 / 255.0) alpha:1.0];
        tmpLabel.translatesAutoresizingMaskIntoConstraints = NO;
        tmpLabel.lineBreakMode = NSLineBreakByWordWrapping;
        tmpLabel.numberOfLines = 0;
        _contentLabel = tmpLabel;
    }
    return _contentLabel;
}

- (UIButton *)bubbleButton {
    if (_bubbleButton == nil) {
        UIButton *tmpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        tmpBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [tmpBtn setTitle:@"复 制" forState:UIControlStateNormal];
        [tmpBtn setTitle:@"已复制" forState:UIControlStateSelected];
        [tmpBtn setTitleColor:[UIColor colorWithRed:19.0/255.0 green:119.0/255.0 blue:227.0/255.0 alpha:1] forState:UIControlStateNormal];
        [tmpBtn setTitleColor:[UIColor colorWithRed:19.0/255.0 green:119.0/255.0 blue:227.0/255.0 alpha:0.5] forState:UIControlStateSelected];
        tmpBtn.layer.borderColor = [UIColor colorWithRed:19.0/255.0 green:119.0/255.0 blue:227.0/255.0 alpha:0.3].CGColor;
        tmpBtn.layer.borderWidth = 2.0;
        tmpBtn.layer.cornerRadius = 5.0;
        tmpBtn.layer.masksToBounds = YES;
        tmpBtn.hidden = YES;
        tmpBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [tmpBtn addTarget:self action:@selector(bubbleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _bubbleButton = tmpBtn;
    }
    return _bubbleButton;
}

@end
