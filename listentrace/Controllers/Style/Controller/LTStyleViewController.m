//
//  LTStyleViewController.m
//  listentrace
//
//  Created by luojie on 2019/7/22.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTStyleViewController.h"
#import "LTStyleTableViewCell.h"
#import "LTStyleDetailViewController.h"
#import "LTNetworking.h"
#import "LTStyleModel.h"
#import "LTAlbumTableViewController.h"

@interface LTStyleViewController () <UITableViewDelegate, UITableViewDataSource, styleTableViewCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray *allKeysArray;
@property (nonatomic, strong) UIView *emptView; // 无数据视图
@property (nonatomic, strong) UIView *noNetWorkView; // 无数据视图
@property (nonatomic, strong) LTStyleModel *model;

@end

@implementation LTStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self creatAllViews];
    [self requestData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAlbumSucess) name:@"AddAlbumSucess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAlbumSucess) name:@"LTDidBecomeActive" object:nil];
}

- (void)creatAllViews {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - kTabBarHeight) style:UITableViewStylePlain];
    self.tableView.backgroundColor = CViewBgColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"LTStyleTableViewCell" bundle:nil] forCellReuseIdentifier:@"LTStyleTableViewCell"];
    self.tableView.rowHeight = 170;
    if (kDevice_iphone5) {
        self.tableView.rowHeight = 140;
    }
    else if (kDevice_iphone6) {
        self.tableView.rowHeight = 160;
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}

- (void)addAlbumSucess {
    [self requestData];
}

- (void)requestData {
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"icloudName"];
    if (!userId.length) {
        self.emptView.hidden = NO;
        self.tableView.hidden = YES;
        return;
    }
    [LTNetworking requestUrl:@"/album/style" WithParam:@{@"user_id" : userId} withMethod:GET success:^(id  _Nonnull result) {
        if ([result[@"code"] intValue] == 200) {
            self.noNetWorkView.hidden = YES;
            // 获得所有的key
            self.allKeysArray = [result[@"data"] allKeys];
            self.allKeysArray = [self.allKeysArray sortedArrayUsingComparator:^NSComparisonResult(id obj1,id obj2) {
                NSComparisonResult result = [obj1 compare:obj2];
                return result == NSOrderedDescending;
            }];
            NSMutableArray *albumArray = [NSMutableArray array];
            
            @autoreleasepool {
                // 循环拿到所有key对应的字典数组
                for (int i = 0; i < self.allKeysArray.count; i ++) {
                    NSString *key = self.allKeysArray[i];
                    // 每一个key放着字典数组，字典数组可能有多个或者一个
                    NSArray *dicArray = result[@"data"][key];
                    NSMutableArray *modelArray = [NSMutableArray array];
                    // 将字典数组转换成模型数组
                    for (int j = 0; j < dicArray.count; j ++) {
                        LTStyleModel *model = [LTStyleModel mj_objectWithKeyValues:dicArray[j]];
                        [modelArray addObject:model];
                    }
                    [albumArray addObject:modelArray];
                    self.dataArray = albumArray;
                }
            }
            [self.tableView reloadData];
        }
        else {
            [MBProgressHUD showInfoMessage:result[@"msg"]];
        }
        
        if (!self.dataArray.count) {
            self.emptView.hidden = NO;
            self.tableView.hidden = YES;
        }
        else {
            self.emptView.hidden = YES;
            self.tableView.hidden = NO;
        }
    } failure:^(NSError * _Nonnull erro) {
        if (!self.dataArray.count) {
            self.tableView.hidden = YES;
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

#pragma mark - =================== UITableView delegate \ datasources ===================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allKeysArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 7;
    }
    else {
        return 0.00001;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.dataArray[indexPath.row];
    LTStyleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LTStyleTableViewCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [LTStyleTableViewCell creatCell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = CViewBgColor;
    cell.delegate = self;
    NSString *string = self.allKeysArray[indexPath.row];
    NSArray *keyArray = [string componentsSeparatedByString:@"-"];
    cell.styleLabel.text = keyArray.lastObject;
    cell.albumCountLabel.text = [NSString stringWithFormat:@"%lu 张专辑",(unsigned long)array.count];

    for (int i = 0; i < array.count; i ++) {
        if (i == 0) {
            self.model = array[0];
            [cell.leftImageVIew setImageWithURL:[NSURL URLWithString:self.model.album_img] placeholder:[UIImage imageNamed:@"style_album_placeImage"]];
            cell.middleImageVIew.hidden = YES;
            cell.rightImageView.hidden = YES;
            cell.view2.hidden = YES;
            cell.view3.hidden = YES;
        }
        else if (i == 1) {
            self.model = array[1];
            [cell.middleImageVIew setImageWithURL:[NSURL URLWithString:self.model.album_img] placeholder:[UIImage imageNamed:@"style_album_placeImage"]];
            cell.middleImageVIew.hidden = NO;
            cell.rightImageView.hidden = YES;
            cell.view2.hidden = NO;
            cell.view3.hidden = YES;
        }
        else if (i == 2) {
            self.model = array[2];
            [cell.rightImageView setImageWithURL:[NSURL URLWithString:self.model.album_img] placeholder:[UIImage imageNamed:@"style_album_placeImage"]];
            cell.middleImageVIew.hidden = NO;
            cell.rightImageView.hidden = NO;
            cell.view2.hidden = NO;
            cell.view3.hidden = NO;
        }
        else {
            cell.view2.hidden = NO;
            cell.view3.hidden = NO;
            break;
        }
    }
    return cell;
}

#pragma mark - =================== cellDelegate ===================
- (void)allStyleButtonClick:(LTBaseTableViewCell *)cell {
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    LTStyleDetailViewController *detail = [[LTStyleDetailViewController alloc] init];
    NSString *string = self.allKeysArray[index.row];
    NSArray *keyArray = [string componentsSeparatedByString:@"-"];
    detail.navTitle = keyArray.lastObject;;
    detail.dataArray = self.dataArray[index.row];
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)imageClick:(LTBaseTableViewCell *)cell index:(NSInteger)index {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSArray *detailArray = self.dataArray[indexPath.row];
    self.model = detailArray[index];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"LTAlbumTableViewController" bundle:[NSBundle mainBundle]];
    LTAlbumTableViewController *albumVC = [story instantiateViewControllerWithIdentifier:@"LTAlbumTableViewController"];
    albumVC.albumId = self.model.album_id;
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
