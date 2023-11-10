//
//  GMViewController.m
//  GMObjC
//
//  Created by lifei on 08/01/2019.
//  Copyright (c) 2019 lifei. All rights reserved.
//

#import "GMViewController.h"
#import "GMObjC/GMObjC.h"
#import "GMTestCell.h"
#import "GMTestModel.h"
#import "GMTestUtil.h"
#import "GMObjC/GMObjC.h"

#define GMMainBundle(name) [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:nil]

@interface GMViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<GMTestModel *> *modelList;
@property (nonatomic, strong) NSArray<UIColor *> *colorList; // 背景颜色

@end

@implementation GMViewController

static NSString *kGMTestCellID = @"kGMTestCellID";
static NSString *kGMTestHeaderID = @"kGMTestHeaderID";

// MARK: - Life
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"GMObjC 版本：%d", GMOBJC_VERSION_NUMBER);
    NSLog(@"GMObjC 版本：%s", GMOBJC_VERSION_TEXT);
    // 初始化测试用密码、公钥，私钥
    self.colorList = [self setupColors];
    self.modelList = [NSMutableArray array];
    [self.modelList addObject:[GMTestUtil testSm2EnDe]];
    [self.modelList addObject:[GMTestUtil testSm2Sign]];
    [self.modelList addObject:[GMTestUtil testSm3]];
    [self.modelList addObject:[GMTestUtil testSm4]];
    [self.modelList addObject:[GMTestUtil testECDH]];
    [self.modelList addObject:[GMTestUtil testReadPemDerFiles]];
    [self.modelList addObject:[GMTestUtil testSaveToPemDerFiles]];
    [self.modelList addObject:[GMTestUtil testCreateKeyPairFiles]];
    [self.modelList addObject:[GMTestUtil testCompressPublicKey]];
    [self.modelList addObject:[GMTestUtil testConvertPemAndDer]];
    [self.modelList addObject:[GMTestUtil testReadX509FileInfo]];
    [self.view addSubview:self.tableView];
    
    NSString *prikey = @"dfd9f517a121f67565957383d44a5e032dbd868f1eff0f02cda8b17e69bd08a7";
    NSString *plaintext = @"123456"; // ordinary plaintext
    NSString *c1c3c2Result = @"9e62bd4ddf639c368a011da8c53654fa9158f80aaccf92a47861d46415dd53e12904b0f10aeee6d7eace37a44143582bef92f644162df65b2ffb288c9197669c7580d96d5d0a9114d75399ae4978a98d4f842b289385f2944eb4d550ca04cfbc600460268363";
    NSData *cccc = [c1c3c2Result dataUsingEncoding:NSUTF8StringEncoding];
    [GMDoctor checkSm2Decrypt:cccc privateKey:prikey];
}

// MARK: - SetupUI
- (NSArray<UIColor *> *)setupColors {
    UIColor *color0 = [UIColor whiteColor];
    UIColor *color1 = [UIColor colorWithRed:(250.0 / 255.0) green:(249.0 / 255.0) blue:(222.0 / 255.0) alpha:1.0];
    UIColor *color2 = [UIColor colorWithRed:(255.0 / 255.0) green:(242.0 / 255.0) blue:(226.0 / 255.0) alpha:1.0];
    UIColor *color3 = [UIColor colorWithRed:(253.0 / 255.0) green:(230.0 / 255.0) blue:(224.0 / 255.0) alpha:1.0];
    UIColor *color4 = [UIColor colorWithRed:(227.0 / 255.0) green:(237.0 / 255.0) blue:(205.0 / 255.0) alpha:1.0];
    UIColor *color5 = [UIColor colorWithRed:(220.0 / 255.0) green:(226.0 / 255.0) blue:(241.0 / 255.0) alpha:1.0];
    UIColor *color6 = [UIColor colorWithRed:(233.0 / 255.0) green:(235.0 / 255.0) blue:(254.0 / 255.0) alpha:1.0];
    UIColor *color7 = [UIColor colorWithRed:(234.0 / 255.0) green:(234.0 / 255.0) blue:(239.0 / 255.0) alpha:1.0];
    NSArray *colorArray = @[color0, color1, color2, color3, color4, color5, color6, color7];
    return colorArray;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGFloat statusBarH = 20;
    if (@available(iOS 11.0, *)) {
        statusBarH = [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;
    } else {
        statusBarH = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    CGSize size = self.view.bounds.size;
    CGFloat margin = size.width > size.height ? 34 : 0;
    CGRect rect = CGRectMake(margin, statusBarH, size.width-margin*2, size.height-statusBarH);
    self.tableView.frame = rect;
}

// MARK: - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.modelList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    GMTestModel *model = self.modelList[section];
    return model.itemList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GMTestCell *cell = (GMTestCell *)[tableView dequeueReusableCellWithIdentifier:kGMTestCellID forIndexPath:indexPath];
    GMTestItemModel *model = self.modelList[indexPath.section].itemList[indexPath.row];
    NSInteger colorIndex = indexPath.item % 8;
    cell.contentView.backgroundColor = colorIndex < self.colorList.count ? self.colorList[colorIndex] : self.colorList[0];
    cell.titleLabel.text = model.title;
    cell.contentLabel.text = model.detail;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    GMTestHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kGMTestHeaderID];
    if (header == nil) {
        header = [[GMTestHeader alloc] initWithReuseIdentifier:kGMTestHeaderID];
    }
    GMTestModel *model = self.modelList[section];
    header.titleLabel.text = model.title;
    return header;
}

// MARK: - Lazy Load
- (UITableView *)tableView {
    if (_tableView == nil) {
        UITableView *tmpTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tmpTable.dataSource = self;
        tmpTable.delegate = self;
        tmpTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tmpTable.separatorInset = UIEdgeInsetsMake(0, 12, 0, 0);
        tmpTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        tmpTable.sectionHeaderHeight = 44;
        tmpTable.estimatedRowHeight = 100;
        tmpTable.rowHeight = UITableViewAutomaticDimension;
        tmpTable.sectionFooterHeight = 0.01;
        [tmpTable registerClass:[GMTestCell class] forCellReuseIdentifier:kGMTestCellID];
        [tmpTable registerClass:[GMTestHeader class] forHeaderFooterViewReuseIdentifier:kGMTestHeaderID];
        _tableView = tmpTable;
    }
    return _tableView;
}

@end
