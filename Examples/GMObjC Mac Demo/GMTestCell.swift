//
//  GMTestCell.swift
//  GMObjC Mac Demo
//
//  Created by lifei on 2023/12/25.
//

import Cocoa

class GMTestCell: NSTableCellView {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.addSubview(self.titleLabel)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let titleLeading = self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12)
        let titleTop = self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8)
        let titleTrailing = self.titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12)
        let btmTrailing = self.titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12)
        NSLayoutConstraint.activate([titleLeading, titleTop, titleTrailing, btmTrailing])
    }
    
    // MARK: - Lazy Load
    lazy var titleLabel: NSTextView = {
        let tmpLabel = NSTextView(frame: NSRect.zero)
        tmpLabel.font = NSFont.systemFont(ofSize: 16)
        tmpLabel.textColor = NSColor(red: 47.0/255.0, green: 56.0/255.0, blue: 86.0/255.0, alpha: 1.0)
        tmpLabel.textContainer?.lineFragmentPadding = 5
        tmpLabel.textContainer?.lineBreakMode = .byWordWrapping
        tmpLabel.isEditable = false
        return tmpLabel
    }()
    
}

//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        self.selectionStyle = UITableViewCellSelectionStyleDefault;
//        [self.contentView addSubview:self.titleLabel];
//        [self.contentView addSubview:self.contentLabel];
//        [self.contentView addSubview:self.bubbleButton];
//        [self setupConstraints];
//    }
//    return self;
//}
//
//- (void)layoutSubviews {
//    [super layoutSubviews];
//    self.bubbleButton.hidden = !self.isSelected;
//}
//
//- (void)setupConstraints {
//    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    [NSLayoutConstraint activateConstraints:@[
//        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:12],
//        [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8],
//        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-12]
//    ]];
//    
//    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    [NSLayoutConstraint activateConstraints:@[
//        [self.contentLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:12],
//        [self.contentLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:8],
//        [self.contentLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-12],
//        [self.contentLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8]
//    ]];
//    
//    self.bubbleButton.translatesAutoresizingMaskIntoConstraints = NO;
//    [NSLayoutConstraint activateConstraints:@[
//        [self.bubbleButton.widthAnchor constraintEqualToConstant:70.0],
//        [self.bubbleButton.heightAnchor constraintEqualToConstant:28.0],
//        [self.bubbleButton.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:4],
//        [self.bubbleButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-12],
//    ]];
//}
//
//// MARK: - Actions
//- (void)bubbleBtnClick:(UIButton *)sender {
//    if (self.contentLabel.text.length == 0) {
//        return;
//    }
//    UIPasteboard *paste = [UIPasteboard generalPasteboard];
//    [paste setString:self.contentLabel.text];
//    
//    sender.selected = YES;
//    __weak typeof(self) _self = self;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        __strong typeof(_self) self = _self;
//        if (!self) return;
//        sender.selected = NO;
//    });
//}
//

//
//- (UILabel *)contentLabel {
//    if (_contentLabel == nil) {
//        UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        tmpLabel.font = [UIFont systemFontOfSize:14];
//        tmpLabel.textColor = [UIColor colorWithRed:(94.0 / 255.0) green:(99.0 / 255.0) blue:(123.0 / 255.0) alpha:1.0];
//        tmpLabel.lineBreakMode = NSLineBreakByWordWrapping;
//        tmpLabel.numberOfLines = 0;
//        _contentLabel = tmpLabel;
//    }
//    return _contentLabel;
//}
//
//- (UIButton *)bubbleButton {
//    if (_bubbleButton == nil) {
//        UIButton *tmpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        tmpBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
//        [tmpBtn setTitle:@"复 制" forState:UIControlStateNormal];
//        [tmpBtn setTitle:@"已复制" forState:UIControlStateSelected];
//        [tmpBtn setTitleColor:[UIColor colorWithRed:19.0/255.0 green:119.0/255.0 blue:227.0/255.0 alpha:1] forState:UIControlStateNormal];
//        [tmpBtn setTitleColor:[UIColor colorWithRed:19.0/255.0 green:119.0/255.0 blue:227.0/255.0 alpha:0.5] forState:UIControlStateSelected];
//        tmpBtn.layer.borderColor = [UIColor colorWithRed:19.0/255.0 green:119.0/255.0 blue:227.0/255.0 alpha:0.3].CGColor;
//        tmpBtn.layer.borderWidth = 2.0;
//        tmpBtn.layer.cornerRadius = 5.0;
//        tmpBtn.layer.masksToBounds = YES;
//        tmpBtn.hidden = YES;
//        [tmpBtn addTarget:self action:@selector(bubbleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//        _bubbleButton = tmpBtn;
//    }
//    return _bubbleButton;
//}
