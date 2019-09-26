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
@property (nonatomic, strong) LTStyleModel *model;

@end

@implementation LTStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self creatAllViews];
    [self requestData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAlbumSucess) name:@"AddAlbumSucess" object:nil];
}

- (void)creatAllViews {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - kTabBarHeight) style:UITableViewStylePlain];
    self.tableView.backgroundColor = CViewBgColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"LTStyleTableViewCell" bundle:nil] forCellReuseIdentifier:@"LTStyleTableViewCell"];
    self.tableView.rowHeight = 150;
    if (kDevice_iphone5) {
        self.tableView.rowHeight = 140;
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.emptView.hidden = NO;
}

- (void)addAlbumSucess {
    [self requestData];
}

- (void)requestData {
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"icloudName"];
    if (!userId.length) {
        return;
    }
    [LTNetworking requestUrl:@"/album/style" WithParam:@{@"user_id" : userId} withMethod:GET success:^(id  _Nonnull result) {
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
                    LTStyleModel *model = [LTStyleModel mj_objectWithKeyValues:dicArray[j]];
                    [modelArray addObject:model];
                }
                [albumArray addObject:modelArray];
                self.dataArray = albumArray;
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
        self.emptView.hidden = NO;
        self.tableView.hidden = YES;
    } showHUD:self.view];
}

#pragma mark - =================== UITableView delegate \ datasources ===================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allKeysArray.count;
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
    cell.styleLabel.text = self.allKeysArray[indexPath.row];
    cell.albumCountLabel.text = [NSString stringWithFormat:@"%ld 张专辑",array.count];

    for (int i = 0; i < array.count; i ++) {
        if (i == 0) {
            self.model = array[0];
            [cell.leftImageVIew setImageWithURL:[NSURL URLWithString:self.model.album_img] placeholder:nil];
            cell.middleImageVIew.hidden = YES;
            cell.rightImageView.hidden = YES;
        }
        else if (i == 1) {
            self.model = array[1];
            [cell.middleImageVIew setImageWithURL:[NSURL URLWithString:self.model.album_img] placeholder:nil];
            cell.middleImageVIew.hidden = NO;
            cell.rightImageView.hidden = YES;
        }
        else if (i == 2) {
            self.model = array[2];
            [cell.rightImageView setImageWithURL:[NSURL URLWithString:self.model.album_img] placeholder:nil];
            cell.middleImageVIew.hidden = NO;
            cell.rightImageView.hidden = NO;
        }
        else {
            cell.middleImageVIew.hidden = NO;
            cell.rightImageView.hidden = NO;
            break;
        }
    }
    return cell;
}

#pragma mark - =================== cellDelegate ===================
- (void)allStyleButtonClick:(LTBaseTableViewCell *)cell {
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    LTStyleDetailViewController *detail = [[LTStyleDetailViewController alloc] init];
    detail.navTitle = self.allKeysArray[index.row];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
