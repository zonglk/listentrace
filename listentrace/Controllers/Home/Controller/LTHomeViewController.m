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
@property (nonatomic, strong) NSArray *allKeysArray;
@property (nonatomic, strong) UIView *emptView; // 无数据视图
@property (nonatomic, strong) LTAlbumModel *model;

@end

@implementation LTHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"听迹";
    [self creatAllViews];
    [self loginIcloud];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAlbumSucess) name:@"AddAlbumSucess" object:nil];
}

- (void)creatAllViews {
    self.homeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - kTabBarHeight - 70) style:UITableViewStyleGrouped];
    self.homeTableView.backgroundColor = CViewBgColor;
    self.homeTableView.delegate = self;
    self.homeTableView.dataSource = self;
    [self.homeTableView registerNib:[UINib nibWithNibName:@"LTHomeTableViewCell" bundle:nil] forCellReuseIdentifier:@"LTHomeTableViewCell"];
    self.homeTableView.rowHeight = 70;
    self.homeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.homeTableView];
    
    self.tipsLable = [[UILabel alloc] init];
    [self.view addSubview:self.tipsLable];
    [self.tipsLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(- kTabBarHeight - 12);
        make.centerX.mas_equalTo(self.view);
    }];
    self.tipsLable.textColor = RGBHex(0xB2B2B2);
    self.tipsLable.font = [UIFont systemFontOfSize:17.0];
    self.tipsLable.hidden = YES;
    self.tipsLable.text = @"X 张专辑";
    
    self.addBttton = [[UIButton alloc] init];
    [self.view addSubview:self.addBttton];
    [self.addBttton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
        make.bottom.mas_equalTo(self.tipsLable.mas_bottom);
    }];
    [self.addBttton setBackgroundImage:[UIImage imageNamed:@"home_add"] forState:UIControlStateNormal];
    [self.addBttton setBackgroundImage:[UIImage imageNamed:@"home_add"] forState:UIControlStateHighlighted];
    [self.addBttton addTarget:self action:@selector(addAlbum) forControlEvents:UIControlEventTouchUpInside];
    
    self.emptView.hidden = NO;
    [self.view bringSubviewToFront:self.addBttton];
}

#pragma mark - =================== icloud ===================

- (void)loginIcloud {
    [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError* error) {
        if (accountStatus == CKAccountStatusNoAccount) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"尚未登录iCloud" message:nil preferredStyle:UIAlertControllerStyleAlert];

            [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil]];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
        else if (accountStatus == CKAccountStatusRestricted) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请允许听迹登录icloud" message:nil preferredStyle:UIAlertControllerStyleAlert];

            [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil]];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
        else if (accountStatus == CKAccountStatusCouldNotDetermine) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请允许听迹登录icloud" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
        else {
            //登录过了
            [[CKContainer defaultContainer] fetchUserRecordIDWithCompletionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
                [[NSUserDefaults standardUserDefaults] setObject:recordID.recordName forKey:@"icloudName"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self requestData];
            }];
        }
    }];
}

- (void)addAlbumSucess {
    [self requestData];
}

- (void)requestData {
    [LTNetworking requestUrl:@"/album/trace" WithParam:@{@"user_id" : [[NSUserDefaults standardUserDefaults] objectForKey:@"icloudName"]} withMethod:GET success:^(id  _Nonnull result) {
        if ([result[@"code"] intValue] == 0) {
            // 获得所有的key
            self.allKeysArray = [result[@"data"] allKeys];
            NSMutableArray *albumArray = [NSMutableArray array];
            // 循环拿到所有key对应的字典数组
            for (int i = 0; i < self.allKeysArray.count; i ++) {
                NSString *key = self.allKeysArray[i];
                // 每一个key放着字典数组，字典数组可能有多个或者一个
                NSArray *dicArray = result[@"data"][key];
                NSMutableArray *modelArray = [NSMutableArray array];
                // 将字典数组转换成模型数组
                for (int j = 0; j < dicArray.count; j ++) {
                    LTAlbumModel *model = [LTAlbumModel mj_objectWithKeyValues:dicArray[j]];
                    [modelArray addObject:model];
                }
                [albumArray addObject:modelArray];
                self.dataArray = albumArray;
            }
            
            [self.homeTableView reloadData];
            if (!self.dataArray.count) {
                self.emptView.hidden = NO;
                self.homeTableView.hidden = YES;
                self.tipsLable.hidden = YES;
            }
            else {
                self.emptView.hidden = YES;
                self.homeTableView.hidden = NO;
                self.tipsLable.hidden = YES;
            }
        }
        else {
            if (!self.dataArray.count) {
                self.emptView.hidden = NO;
                self.homeTableView.hidden = YES;
                self.tipsLable.hidden = YES;
            }
            else {
                self.emptView.hidden = YES;
                self.homeTableView.hidden = NO;
                self.tipsLable.hidden = YES;
            }
            [MBProgressHUD showInfoMessage:result[@"msg"]];
        }
    } failure:^(NSError * _Nonnull erro) {
        self.emptView.hidden = NO;
        self.homeTableView.hidden = YES;
        self.tipsLable.hidden = YES;
    } showHUD:self.view];
}

#pragma mark - =================== UITableView delegate \ datasources ===================
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = CViewBgColor;
    UILabel *dateLabel = [[UILabel alloc] init];
    [view addSubview:dateLabel];
    [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view.mas_left).offset(15);
        make.bottom.mas_equalTo(view.mas_bottom).offset(-4);
    }];
    dateLabel.textColor = RGBHex(0x989DAD);
    dateLabel.font = [UIFont systemFontOfSize:13.0];
    dateLabel.text = self.allKeysArray[section];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.00001;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.allKeysArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.dataArray[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LTHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LTHomeTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = CViewBgColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - =================== 添加专辑 ===================
- (void)addAlbum {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"LTAlbumTableViewController" bundle:[NSBundle mainBundle]];
    LTAlbumTableViewController *albumVC = [story instantiateViewControllerWithIdentifier:@"LTAlbumTableViewController"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:albumVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
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
            make.centerY.mas_equalTo(weakself.emptView.mas_centerY).offset(-100);
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

@end
