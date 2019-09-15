//
//  LTSetUpTableViewController.m
//  listentrace
//
//  Created by 宗丽康 on 2019/7/28.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTSetUpTableViewController.h"
#import "LTActivity.h"

@interface LTSetUpTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *setUpTableView;
@property (weak, nonatomic) IBOutlet UIView *view1; // 以下4个view只是为了设置圆角和边框
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UIView *view4;

- (IBAction)feedbackButtonClick:(id)sender; // 建议与反馈
- (IBAction)scoreButtonClick:(id)sender; // 评分
- (IBAction)shareButtonClick:(id)sender; // 评分
- (IBAction)UrlSchemesButtonClick:(id)sender; // 打开app
- (IBAction)handsUrlSchemesClick:(id)sender; // 手动录入

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

#pragma mark - =================== 分享 ===================

- (IBAction)shareButtonClick:(id)sender {
    // 1、设置分享的内容，并将内容添加到数组中
    NSString *shareText = @"我正在使用「听迹」App，感觉还不错。不妨下载试试看：D";
    NSURL *shareUrl = [NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/id1473462600?mt=8"];
    NSArray *activityItemsArray = @[shareText,shareUrl];
    
    // 自定义的CustomActivity，继承自UIActivity
    LTActivity *customActivity = [[LTActivity alloc]initWithTitle:shareText ActivityImage:[UIImage imageNamed:@""] URL:shareUrl ActivityType:@"Custom"];
    NSArray *activityArray = @[customActivity];
    
    // 2、初始化控制器，添加分享内容至控制器
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItemsArray applicationActivities:activityArray];
    activityVC.modalInPopover = YES;
    // 3、设置回调
    UIActivityViewControllerCompletionWithItemsHandler itemsBlock = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
        if (completed == YES) {
            
        }
        else{

        }
    };
    activityVC.completionWithItemsHandler = itemsBlock;
    // 4、调用控制器
    [self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - =================== 打开手动录入界面 ===================

- (IBAction)handsUrlSchemesClick:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = @"Listentrace://addAlbum";
    
    [MBProgressHUD showTipMessageInView:@"已复制到粘贴板"];
}

#pragma mark - =================== 打击app ===================

- (IBAction)UrlSchemesButtonClick:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = @"Listentrace://";
    
    [MBProgressHUD showTipMessageInView:@"已复制到粘贴板"];
}

#pragma mark - =================== 建议与反馈 ===================

- (IBAction)feedbackButtonClick:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = @"hippiezhu@gmail.com";
    
    [MBProgressHUD showTipMessageInView:@"邮箱已复制 hippiezhu@gmail.com 可发送信息至该邮箱"];
}

#pragma mark - =================== 评分 ===================

- (IBAction)scoreButtonClick:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id1473462600?action=write-review"]]];
}

@end
