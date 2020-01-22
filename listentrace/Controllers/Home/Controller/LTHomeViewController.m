//
//  LTHomeViewController.m
//  listentrace
//
//  Created by luojie on 2019/7/22.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTHomeViewController.h"
#import "LTHomeTableViewCell.h"
#import "LTAlbumTableViewController.h"
#import <CloudKit/CloudKit.h>
#import "LTNetworking.h"
#import "LTAlbumModel.h"
#import "LTHelpTableViewController.h"
#import "LTAutoAddAlbumTableViewController.h"
#import <SoundAnalysis/SoundAnalysis.h>

@interface LTHomeViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *homeTableView;
@property (nonatomic, strong) UILabel *tipsLable; // 底部专辑张数提醒label
@property (nonatomic, strong) UIButton *addBttton; // 添加专辑按钮
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray *allKeysArray; // 所有年份的key
@property (nonatomic, strong) NSMutableArray *allMonthKeysArray; // 所有月份的
@property (nonatomic, strong) NSMutableArray *yearKeyIndexArray; // 需要展示的年份section
@property (nonatomic, strong) UIView *emptView; // 无数据视图
@property (nonatomic, strong) UIView *noNetWorkView; // 无数据视图
@property (nonatomic, strong) LTAlbumModel *model;
@property (nonatomic, assign) NSInteger albumCount;
@property (nonatomic, copy) NSString *countTipString;
@property (nonatomic, assign) BOOL isHasUserId;
@property (nonatomic, assign) BOOL isNeedStyleRefreshData;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIView *addView;
@property (copy, nonatomic) NSString *pasteBoardString;
@property (nonatomic, strong) UILabel *linkLable;
@property (nonatomic, strong) UILabel *titleLable;
@property (strong, strong) UIImageView *trangleImageView;
@property (strong, strong) UIImageView *rectangleImageView;
@property (nonatomic, assign) BOOL isHomeVC;
@property (nonatomic, assign) BOOL isCancle;

@end

@implementation LTHomeViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isHomeVC = YES;
    [self getPastedBoardString];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isHomeVC = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"听迹";
    self.isHomeVC = YES;
    [self creatAllViews];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"icloudName"];
    if (userId.length) {
        [self requestData];
        self.isHasUserId = YES;
    }
    else {
        self.emptView.hidden = NO;
        self.homeTableView.hidden = YES;
        self.tipsLable.hidden = YES;
    }
    [self loginIcloud];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAlbumSucess) name:@"AddAlbumSucess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LTDidBecomeActive) name:@"LTDidBecomeActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPastedBoardString) name:@"LTDidBecomeActiveHandlePasteBoard" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackGround) name:@"LTDidEnterBackGround" object:nil];
    [self getPastedBoardString];
}

- (void)creatAllViews {
    self.homeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - kTabBarHeight) style:UITableViewStyleGrouped];
    self.homeTableView.backgroundColor = CViewBgColor;
    self.homeTableView.delegate = self;
    self.homeTableView.dataSource = self;
    [self.homeTableView registerNib:[UINib nibWithNibName:@"LTHomeTableViewCell" bundle:nil] forCellReuseIdentifier:@"LTHomeTableViewCell"];
    self.homeTableView.rowHeight = 70;
    self.homeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.homeTableView];
    
    self.addBttton = [[UIButton alloc] init];
    [self.view addSubview:self.addBttton];
    [self.addBttton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
        make.bottom.mas_equalTo(self.homeTableView.mas_bottom).offset(-18);
    }];
    [self.addBttton setBackgroundImage:[UIImage imageNamed:@"home_add"] forState:UIControlStateNormal];
    [self.addBttton setBackgroundImage:[UIImage imageNamed:@"home_add"] forState:UIControlStateHighlighted];
    [self.addBttton addTarget:self action:@selector(addAlbum) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view bringSubviewToFront:self.addBttton];
}

#pragma mark icloud

- (void)loginIcloud {
    [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError* error) {
        if (accountStatus == CKAccountStatusAvailable) {
            //登录过了
            [[CKContainer defaultContainer] fetchUserRecordIDWithCompletionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
                [[NSUserDefaults standardUserDefaults] setObject:recordID.recordName forKey:@"icloudName"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //获取到共享数据的文件地址
                NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.listentrace"];
                NSURL *birthdayContainerURL = [containerURL URLByAppendingPathComponent:@"Library/Caches/userId.json"];
                //将需要存储的数据写入到该文件中
                NSString *jsonString = recordID.recordName;
                //写入数据
                NSError *err = nil;
                [jsonString writeToURL:birthdayContainerURL atomically:YES encoding:NSUTF8StringEncoding error:&err];
                
                if (!self.isHasUserId) {
                    [self requestData];
                }
                self.isNeedStyleRefreshData = YES;
                if (self.isNeedStyleRefreshData) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LTDidBecomeActive" object:nil];
                }
            }];
        }
    }];
}

- (void)addAlbumSucess {
    [self requestData];
}

- (void)LTDidBecomeActive {
    if (!self.isNeedStyleRefreshData) {
        [self loginIcloud];
    }
}

- (void)appEnterBackGround {
    self.isCancle = NO;
}

- (void)requestData {
    [LTNetworking requestUrl:@"/album/trace" WithParam:@{@"user_id" : [[NSUserDefaults standardUserDefaults] objectForKey:@"icloudName"]} withMethod:GET success:^(id  _Nonnull result) {
        
        if ([result[@"code"] intValue] == 200) {
            [self.allMonthKeysArray removeAllObjects];
            [self.yearKeyIndexArray removeAllObjects];
            self.noNetWorkView.hidden = YES;
            self.albumCount = 0;
            // 获得所有的key 对应年份
            self.allKeysArray = [result[@"data"] allKeys];
            self.allKeysArray = [self.allKeysArray sortedArrayUsingComparator:^NSComparisonResult(id obj1,id obj2) {
                NSComparisonResult result = [obj1 compare:obj2];
                return result == NSOrderedAscending;
            }];
            
            NSInteger sectionIndex = 0;
            NSMutableArray *albumArray = [NSMutableArray array];
            // 循环拿到所有key对应的字典数组
            for (int i = 0; i < self.allKeysArray.count; i ++) {
                NSString *key = self.allKeysArray[i];
                // 获取月份下的所有key
                NSArray *allMonthKeys = [result[@"data"][key] allKeys];
                allMonthKeys = [allMonthKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1,id obj2) {
                    NSComparisonResult result = [obj1 compare:obj2];
                    return result == NSOrderedDescending;
                }];
                
                for (int j = 0; j < allMonthKeys.count; j ++) {
                    [self.allMonthKeysArray addObject:allMonthKeys[j]];
                    // 每一个key放着字典数组，字典数组可能有多个或者一个
                    NSArray *dicArray = result[@"data"][key][allMonthKeys[j]];
                    NSMutableArray *modelArray = [NSMutableArray array];
                    // 将字典数组转换成模型数组
                    for (int k = 0; k < dicArray.count; k ++) {
                        LTAlbumModel *model = [LTAlbumModel mj_objectWithKeyValues:dicArray[k]];
                        [modelArray addObject:model];
                        self.albumCount += 1;
                    }
                    sectionIndex += 1;
                    [albumArray addObject:modelArray];
                }
                self.dataArray = albumArray;
                NSString *section = [NSString stringWithFormat:@"%ld",(long)sectionIndex];
                [self.yearKeyIndexArray addObject:section];
            }
            
            self.countTipString = [NSString stringWithFormat:@"%ld 张专辑",(long)self.albumCount];
            [[NSUserDefaults standardUserDefaults] setObject:@(self.albumCount) forKey:@"albumCount"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self.homeTableView reloadData];
        }
        else {
            [MBProgressHUD showInfoMessage:result[@"msg"]];
        }
        
        if (!self.dataArray.count) {
            self.emptView.hidden = NO;
            self.homeTableView.hidden = YES;
            self.tipsLable.hidden = YES;
        }
        else {
            if (self.dataArray.count > 7) {
                self.tipsLable.hidden = NO;
            }
            else {
                self.tipsLable.hidden = YES;
            }
            self.emptView.hidden = YES;
            self.homeTableView.hidden = NO;
        }
    } failure:^(NSError * _Nonnull erro) {
        if (!self.dataArray.count) {
            self.homeTableView.hidden = YES;
            self.tipsLable.hidden = YES;
            if (erro.code == -1009 || erro.code == -1005) {
                self.emptView.hidden = YES;
                self.noNetWorkView.hidden = NO;
            }
            else  {
                self.noNetWorkView.hidden = YES;
                self.emptView.hidden = NO;
            }
        }
    } showHUD:self.view];
}

#pragma mark UITableView delegate 、 datasources

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    BOOL isNeedShowYeah = NO;
    for (int i = 0; i < self.yearKeyIndexArray.count; i ++) {
        int index = [self.yearKeyIndexArray[i] intValue];
        if (index == section) {
            isNeedShowYeah = YES;
        }
    }
    if (section == 0) {
        return 62;
    }
    else if (isNeedShowYeah) {
        return 55;
    }
    else {
        return 26;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BOOL isNeedShowYeah = NO;
    int sectionIndex = 0;
    for (int i = 0; i < self.yearKeyIndexArray.count; i ++) {
        int index = [self.yearKeyIndexArray[i] intValue];
        if (index == section) {
            isNeedShowYeah = YES;
            sectionIndex = i;
        }
    }
    if (section == 0 || isNeedShowYeah) {
        UIView *view = [UIView new];
        view.backgroundColor = CViewBgColor;
        UILabel *dateLabel = [[UILabel alloc] init];
        [view addSubview:dateLabel];
        [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(view.mas_left).offset(15);
            make.top.mas_equalTo(view.mas_top).offset(isNeedShowYeah ? 12 : 18);
        }];
        dateLabel.textColor = RGBHex(0x545C77);
        dateLabel.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightLight];
        if (self.allKeysArray.count > sectionIndex + 1) {
            dateLabel.text = isNeedShowYeah ? self.allKeysArray[sectionIndex + 1] : self.allKeysArray[sectionIndex];
        }
        
        if (self.allKeysArray.count == 1) {
            dateLabel.text = self.allKeysArray[0];
        }
        
        UILabel *monthLabel = [[UILabel alloc] init];
        [view addSubview:monthLabel];
        [monthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(view.mas_left).offset(15);
            make.top.mas_equalTo(dateLabel.mas_bottom).offset(5);
        }];
        monthLabel.textColor = RGBHex(0x989DAD);
        monthLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightLight];
        NSString *string = self.allMonthKeysArray[section];
        NSArray *array = [string componentsSeparatedByString:@"-"];
        monthLabel.text = array.lastObject;
        return view;
    }
    else {
        UIView *view = [UIView new];
        view.backgroundColor = CViewBgColor;
        
        UILabel *monthLabel = [[UILabel alloc] init];
        [view addSubview:monthLabel];
        [monthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(view.mas_left).offset(15);
            make.top.mas_equalTo(view.mas_top).offset(10);
        }];
        monthLabel.textColor = RGBHex(0x989DAD);
        monthLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightLight];
        NSString *string = self.allMonthKeysArray[section];
        NSArray *array = [string componentsSeparatedByString:@"-"];
        monthLabel.text = array.lastObject;
        return view;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.albumCount < 8) {
        return 0.00001;
    }
    else if (section == self.dataArray.count - 1) {
        return 60;
    }
    else {
        return 0.00001;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.albumCount < 8) {
        return [UIView new];
    }
    else if (section == self.dataArray.count - 1) {
        UIView *view = [[UIView alloc] init];
        self.tipsLable = [[UILabel alloc] init];
        [view addSubview:self.tipsLable];
        [self.tipsLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(view);
            make.centerY.mas_equalTo(view);
        }];
        self.tipsLable.textColor = RGBHex(0xB2B2B2);
        self.tipsLable.font = [UIFont systemFontOfSize:12.0];
        self.tipsLable.text = self.countTipString;
        return view;
    }
    else {
        return [UIView new];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.dataArray[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.dataArray[indexPath.section];
    self.model = array[indexPath.row];
    LTHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LTHomeTableViewCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [LTHomeTableViewCell creatCell];;
    }
    if (array.count == indexPath.row + 1) {
        cell.lineView.hidden = YES;
    }
    else {
        cell.lineView.hidden = NO;
    }
    cell.model = self.model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.dataArray[indexPath.section];
    self.model = array[indexPath.row];
    [self addAlbum:self.model.album_id];
}

#pragma mark 添加专辑

- (void)addAlbum {
    AudioServicesPlaySystemSound(1519);
    [self addCoverView];
    [self getPastedBoardString];
}

#pragma mark 手动添加

- (void)manaulButtonClick {
    self.coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    self.coverView.hidden = YES;
    self.addView.alpha = 0;
    
    [self addAlbum:nil];
    self.isCancle = YES;
}

#pragma mark 自动

- (void)autoButtonClick {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"LTIsClickAdd"]) {
        self.coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
        self.coverView.hidden = YES;
        self.addView.alpha = 0;
        
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"LTHelpViewController" bundle:nil];
        LTHelpTableViewController *helpVC = [story instantiateViewControllerWithIdentifier:@"LTHelpViewController"];
        [self.navigationController pushViewController:helpVC animated:YES];
        
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"LTIsClickAdd"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        self.coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
        self.coverView.hidden = YES;
        self.addView.alpha = 0;
        
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"LTAutoAddAlbumViewController" bundle:nil];
        LTAutoAddAlbumTableViewController *autoVC = [story instantiateViewControllerWithIdentifier:@"LTAutoAddAlbumViewController"];
        [self.navigationController pushViewController:autoVC animated:YES];
        self.isCancle = YES;
    }
}

#pragma mark 获取剪贴板的内容

- (void)getPastedBoardString {
    if (!self.isHomeVC || self.isCancle) {
        self.linkLable.alpha = 0;
        self.rectangleImageView.alpha = 0;
        self.trangleImageView.alpha = 0;
        self.titleLable.alpha = 0;
        return;
    }
    
    self.pasteBoardString = [[UIPasteboard generalPasteboard] string];
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:@"LinkUrlString"];
    if ([self.pasteBoardString isEqualToString:string]) {
        return;
    }
    
    if ([self.pasteBoardString containsString:@"open.spotify.com"] || [self.pasteBoardString containsString:@"music.apple.com"] || [self.pasteBoardString containsString:@"music.163.com"] || [self.pasteBoardString containsString:@"y.qq.com"] || [self.pasteBoardString containsString:@"bandcamp.com"]) {
        [self addCoverView];
        [UIView animateWithDuration:0.4 animations:^{
            self.linkLable.alpha = 1;
            self.rectangleImageView.alpha = 1;
            self.trangleImageView.alpha = 1;
            self.titleLable.alpha = 1;
        }];
        
        if ([self.pasteBoardString containsString:@"open.spotify.com"]) {
            self.linkLable.text = @"open.spotify.com";
            [self updateConstraints:212];
        }
        else if ([self.pasteBoardString containsString:@"music.apple.com"]) {
            self.linkLable.text = @"music.apple.com";
            [self updateConstraints:210];
        }
        else if ([self.pasteBoardString containsString:@"music.163.com"]) {
            self.linkLable.text = @"music.163.com";
            [self updateConstraints:196];
        }
        else if ([self.pasteBoardString containsString:@"y.qq.com"]) {
            self.linkLable.text = @"y.qq.com";
            [self.trangleImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(160);
            }];
            [self.linkLable mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.addView).mas_offset(-10);
            }];
        }
        else if ([self.pasteBoardString containsString:@"bandcamp.com"]) {
            self.linkLable.text = @"bandcamp.com";
            [self updateConstraints:194];
        }
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LinkUrl"];
        [[NSUserDefaults standardUserDefaults] setValue:self.pasteBoardString forKey:@"LinkUrlString"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        self.pasteBoardString = nil;
        self.linkLable.alpha = 0;
        self.rectangleImageView.alpha = 0;
        self.trangleImageView.alpha = 0;
        self.titleLable.alpha = 0;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"LinkUrl"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)updateConstraints:(NSInteger)constraints {
    [self.trangleImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(constraints);
    }];
    [self.linkLable mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.addView);
    }];
}

- (void)addCoverView {
    self.coverView =  [self creatCoverView];
    [[UIApplication sharedApplication].delegate.window addSubview:_coverView];
    self.coverView.hidden = NO;
    [UIView animateWithDuration:0.4 animations:^{
        self.coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        self.addView.alpha = 1;
        self.linkLable.alpha = 0;
        self.rectangleImageView.alpha = 0;
        self.trangleImageView.alpha = 0;
        self.titleLable.alpha = 0;
    }];
}

- (void)coverButtonClick {
    [UIView animateWithDuration:0.5 animations:^{
        self.coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
        self.addView.alpha = 0;
        self.linkLable.alpha = 0;
        self.rectangleImageView.alpha = 0;
        self.trangleImageView.alpha = 0;
        self.titleLable.alpha = 0;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.coverView.hidden = YES;
    });
    self.isCancle = YES;
}

- (void)addAlbum:(NSString *)albumId {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"LTAlbumTableViewController" bundle:[NSBundle mainBundle]];
    LTAlbumTableViewController *albumVC = [story instantiateViewControllerWithIdentifier:@"LTAlbumTableViewController"];
    albumVC.albumId = albumId;
    [self.navigationController pushViewController:albumVC animated:YES];
}

- (UIView *)emptView {
    if (!_emptView) {
        _emptView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kBottomSafeHeight - kTabBarHeight)];
        [self.view addSubview:_emptView];
        
        kWeakSelf(self)
        UIImageView *emptImageView = [[UIImageView alloc] init];
        [_emptView addSubview:emptImageView];
        [emptImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(weakself.emptView.mas_centerX);
            make.centerY.mas_equalTo(weakself.emptView.mas_centerY).offset(-70);
        }];
        [emptImageView setImage:[UIImage imageNamed:@"home_empt"]];
        
        UILabel *tipLabel = [[UILabel alloc] init];
        [_emptView addSubview:tipLabel];
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(emptImageView.mas_centerX);
            make.top.mas_equalTo(emptImageView.mas_bottom).offset(20);
        }];
        tipLabel.text = @"暂时没有专辑";
        tipLabel.font = [UIFont systemFontOfSize:18];
        tipLabel.textColor = RGBHex(0xC0C6DA);
        self.emptView.hidden = YES;
        
        [self.view bringSubviewToFront:self.addBttton];
    }
    return _emptView;
}

- (UIView *)noNetWorkView {
    if (!_noNetWorkView) {
        _noNetWorkView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kBottomSafeHeight - kTabBarHeight)];
        [self.view addSubview:_noNetWorkView];
        
        kWeakSelf(self)
        UIImageView *emptImageView = [[UIImageView alloc] init];
        [_noNetWorkView addSubview:emptImageView];
        [emptImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(weakself.emptView.mas_centerX);
            make.centerY.mas_equalTo(weakself.emptView.mas_centerY).offset(-120);
        }];
        [emptImageView setImage:[UIImage imageNamed:@"noNetWork"]];
        
        UILabel *tipLabel = [[UILabel alloc] init];
        [_noNetWorkView addSubview:tipLabel];
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(emptImageView.mas_centerX);
            make.top.mas_equalTo(emptImageView.mas_bottom).offset(20);
        }];
        tipLabel.text = @"网络连接有点小问题";
        tipLabel.font = [UIFont systemFontOfSize:13];
        tipLabel.textColor = RGBHex(0xC0C6DA);
        
        UILabel *tipBottmLabel = [[UILabel alloc] init];
        [_noNetWorkView addSubview:tipBottmLabel];
        [tipBottmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(emptImageView.centerX);
            make.top.mas_equalTo(tipLabel.mas_bottom).offset(10);
        }];
        tipBottmLabel.text = @"请检查后点击重试";
        tipBottmLabel.font = [UIFont systemFontOfSize:13];
        tipBottmLabel.textColor = RGBHex(0xC0C6DA);
        UIButton *requestButton = [[UIButton alloc] init];
        [_noNetWorkView addSubview:requestButton];
        ViewBorderRadius(requestButton, 18, 1, RGBHex(0xCEE3FB));
        [requestButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(emptImageView.centerX);
            make.top.mas_equalTo(tipBottmLabel.mas_bottom).offset(20);
            make.size.mas_equalTo(CGSizeMake(100, 36));
        }];
        [requestButton setTitle:@"点击重试" forState:UIControlStateNormal];
        [requestButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [requestButton setTitleColor:RGBHex(0xC0C6DA) forState:UIControlStateNormal];
        [requestButton addTarget:self action:@selector(requestData) forControlEvents:UIControlEventTouchUpInside];
    }
    return _noNetWorkView;
}

- (NSMutableArray *)allMonthKeysArray {
    if (!_allMonthKeysArray) {
        _allMonthKeysArray = [NSMutableArray array];
    }
    return _allMonthKeysArray;
}

- (NSMutableArray *)yearKeyIndexArray {
    if (!_yearKeyIndexArray) {
        _yearKeyIndexArray = [NSMutableArray array];
    }
    return _yearKeyIndexArray;
}

- (UIView *)creatCoverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
        _coverView.hidden = YES;
        [[UIApplication sharedApplication].delegate.window addSubview:_coverView];
        
        UIButton *coverButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        [_coverView addSubview:coverButton];
        [coverButton addTarget:self action:@selector(coverButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        _addView = [[UIView alloc] init];
        [_coverView addSubview:_addView];
        [_addView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.coverView.mas_right).offset(-15);
            make.bottom.mas_equalTo(self.coverView.mas_bottom).offset(- kBottomSafeHeight - 140);
            make.size.mas_equalTo(CGSizeMake(200, 110));
        }];
        _addView.backgroundColor = [UIColor whiteColor];
        ViewBorderRadius(_addView, 5, 0, [UIColor whiteColor]);
        _addView.alpha = 0;
        
        UIView *autoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 55)];
        [_addView addSubview:autoView];
        
        UIImageView *autoImageView = [[UIImageView alloc] init];
        [autoView addSubview:autoImageView];
        [autoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.addView).offset(22);
            make.centerY.mas_equalTo(autoView);
        }];
        [autoImageView setImage:[UIImage imageNamed:@"home_autoButton"]];
        
        UILabel *autoLabel = [[UILabel alloc] init];
        [autoView addSubview:autoLabel];
        [autoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(autoImageView.mas_right).offset(17);
            make.centerY.mas_equalTo(autoView);
        }];
        autoLabel.textColor = [UIColor colorWithHexString:@"0x007AFF"];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"链接导入"];
        [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Medium" size:15.f] range:NSMakeRange(0, 4)];
        autoLabel.attributedText = str;
        
        UIButton *autoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 55)];
        [autoView addSubview:autoButton];
        [autoButton addTarget:self action:@selector(autoButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *mamuelView = [[UIView alloc] initWithFrame:CGRectMake(0, 55, 200, 55)];
        [_addView addSubview:mamuelView];

        UIImageView *manuelImageView = [[UIImageView alloc] init];
        [mamuelView addSubview:manuelImageView];
        [manuelImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.addView).offset(24);
            make.centerY.mas_equalTo(mamuelView);
        }];
        [manuelImageView setImage:[UIImage imageNamed:@"home_manuelButton"]];
        
        UILabel *manuelLabel = [[UILabel alloc] init];
        [mamuelView addSubview:manuelLabel];
        [manuelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(manuelImageView.mas_right).offset(17);
            make.centerY.mas_equalTo(mamuelView);
        }];
        manuelLabel.textColor = [UIColor colorWithHexString:@"0x007AFF"];
        manuelLabel.font = [UIFont systemFontOfSize:15 weight:0.5];
        NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:@"手动导入"];
        [str1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Medium" size:15.f] range:NSMakeRange(0, 4)];
        manuelLabel.attributedText = str1;
        
        UIButton *manuelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 55)];
        [mamuelView addSubview:manuelButton];
        [manuelButton addTarget:self action:@selector(manaulButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 55, 200, 0.5)];
        [_addView addSubview:lineView];
        [lineView setBackgroundColor:[UIColor colorWithHexString:@"0xDDE2F4"]];
        
        // 发现链接
        _trangleImageView = [[UIImageView alloc] init];
        [_coverView addSubview:_trangleImageView];
        [_trangleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.addView.mas_top).mas_offset(25);
            make.height.mas_equalTo(130);
            make.centerX.mas_equalTo(self.addView);
            make.width.mas_equalTo(220);
        }];
        _trangleImageView.userInteractionEnabled = YES;
        [_trangleImageView setImage:[UIImage imageNamed:@"home_link_Auto_rectangle"]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(autoButtonClick)];
        [_trangleImageView addGestureRecognizer:tap];
        
        _rectangleImageView = [[UIImageView alloc] init];
        [_coverView addSubview:_rectangleImageView];
        [_rectangleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.addView);
            make.bottom.mas_equalTo(self.addView.mas_top);
        }];
        [_rectangleImageView setImage:[UIImage imageNamed:@"home_link_Auto_triangle"]];
        
        self.linkLable = [[UILabel alloc] init];
        [_coverView addSubview:self.linkLable];
        [self.linkLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.addView);
            make.bottom.mas_equalTo(self.rectangleImageView.mas_top).mas_offset(-14);
        }];
        self.linkLable.textColor = [UIColor whiteColor];
        self.linkLable.font = [UIFont systemFontOfSize:14];
        
        self.titleLable = [[UILabel alloc] init];
        [_coverView addSubview:self.titleLable];
        [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.linkLable.mas_left);
            make.bottom.mas_equalTo(self.linkLable.mas_top).mas_offset(-5);
        }];
        self.titleLable.textColor = [UIColor whiteColor];
        self.titleLable.font = [UIFont systemFontOfSize:14];
        self.titleLable.text = @"发现新链接:";
        
        self.linkLable.alpha = 0;
        self.rectangleImageView.alpha = 0;
        self.trangleImageView.alpha = 0;
        self.titleLable.alpha = 0;
    }
    return _coverView;
}

@end
