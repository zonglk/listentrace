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

@interface LTStyleViewController () <UITableViewDelegate, UITableViewDataSource, styleTableViewCellDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LTStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self creatAllViews];
}

- (void)creatAllViews {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - kTabBarHeight) style:UITableViewStylePlain];
    self.tableView.backgroundColor = CViewBgColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"LTStyleTableViewCell" bundle:nil] forCellReuseIdentifier:@"LTStyleTableViewCell"];
    self.tableView.rowHeight = 150;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}

#pragma mark - =================== UITableView delegate \ datasources ===================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LTStyleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LTStyleTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = CViewBgColor;
    cell.delegate = self;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - =================== cellDelegate ===================
- (void)allStyleButtonClick:(LTBaseTableViewCell *)cell {
    LTStyleDetailViewController *detail = [[LTStyleDetailViewController alloc] init];
    detail.navTitle = @"style";
    [self.navigationController pushViewController:detail animated:YES];
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
