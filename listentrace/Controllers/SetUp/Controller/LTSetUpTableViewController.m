//
//  LTSetUpTableViewController.m
//  listentrace
//
//  Created by 宗丽康 on 2019/7/28.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTSetUpTableViewController.h"

@interface LTSetUpTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *setUpTableView;
@property (weak, nonatomic) IBOutlet UIView *view1; // 以下4个view只是为了设置圆角和边框
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UIView *view4;


- (IBAction)scoreButtonClick:(id)sender;

@end

@implementation LTSetUpTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatAllViews];
}

- (void)creatAllViews {
    self.setUpTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.setUpTableView.backgroundColor = CViewBgColor;
    ViewBorderRadius(self.view1, 5, 1, RGBHex(0xE5EAFA));
    ViewBorderRadius(self.view2, 5, 1, RGBHex(0xE5EAFA));
    ViewBorderRadius(self.view3, 5, 1, RGBHex(0xE5EAFA));
    ViewBorderRadius(self.view4, 5, 1, RGBHex(0xE5EAFA));
    
}

#pragma mark - =================== 评分 ===================

- (IBAction)scoreButtonClick:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id1473462600?action=write-review"]]];
}
@end
