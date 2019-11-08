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

@end

@implementation LTHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"听迹";
    [self creatAllViews];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"icloudName"];
    if (userId.length) {
        [self requestData];
        self.isHasUserId = YES;
    }
    [self loginIcloud];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAlbumSucess) name:@"AddAlbumSucess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LTDidBecomeActive) name:@"LTDidBecomeActive" object:nil];
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
        make.bottom.mas_equalTo(self.homeTableView.mas_bottom).offset(-20);
    }];
    [self.addBttton setBackgroundImage:[UIImage imageNamed:@"home_add"] forState:UIControlStateNormal];
    [self.addBttton setBackgroundImage:[UIImage imageNamed:@"home_add"] forState:UIControlStateHighlighted];
    [self.addBttton addTarget:self action:@selector(addAlbum) forControlEvents:UIControlEventTouchUpInside];
    
    self.emptView.hidden = NO;
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
                if (!self.isHasUserId) {
                    [self requestData];
                }
            }];
        }
    }];
}

- (void)addAlbumSucess {
    [self requestData];
}

- (void)LTDidBecomeActive {
    [self loginIcloud];
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
            
            if (self.albumCount > 0) {
                self.countTipString = [NSString stringWithFormat:@"%ld 张专辑",(long)self.albumCount];
                [[NSUserDefaults standardUserDefaults] setObject:@(self.albumCount) forKey:@"albumCount"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
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
    if (section == 0 || isNeedShowYeah) {
        return 62;
    }
    else {
        return 24;
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
            make.top.mas_equalTo(view.mas_top).offset(18);
        }];
        dateLabel.textColor = RGBHex(0x545C77);
        dateLabel.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightLight];
        if (self.allKeysArray.count > sectionIndex + 1) {
            dateLabel.text = isNeedShowYeah ? self.allKeysArray[sectionIndex + 1] : self.allKeysArray[sectionIndex];
        }
        
        UILabel *monthLabel = [[UILabel alloc] init];
        [view addSubview:monthLabel];
        [monthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(view.mas_left).offset(15);
            make.top.mas_equalTo(dateLabel.mas_bottom).offset(5);
        }];
        monthLabel.textColor = RGBHex(0x989DAD);
        monthLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightLight];
        monthLabel.text = self.allMonthKeysArray[section];
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
        monthLabel.text = self.allMonthKeysArray[section];
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
    cell.model = self.model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.dataArray[indexPath.section];
    self.model = array[indexPath.row];
    [self addAlbum:self.model.album_id];
}

#pragma mark - =================== 添加专辑 ===================
- (void)addAlbum {
    [self addAlbum:nil];
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

@end
