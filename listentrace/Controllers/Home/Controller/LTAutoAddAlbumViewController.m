//
//  LTAutoAddAlbumViewController.m
//  listentrace
//
//  Created by 宗丽康 on 2020/1/8.
//  Copyright © 2020 listentrace. All rights reserved.
//

#import "LTAutoAddAlbumViewController.h"
#import "LTHelpTableViewController.h"
#import "LTHelpViewController.h"
#import "LTHelpTipViewController.h"

@interface LTAutoAddAlbumViewController ()

@property (strong, nonatomic) UIButton *autoButton;

@end

@implementation LTAutoAddAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self creatAllViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusChange:) name:@"LinkUrlButton" object:nil];
    
    NSMutableArray *vcArr = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
    for (UIViewController *vc in vcArr) {
        if ([vc isKindOfClass:[LTHelpViewController class]]) {
            [vcArr removeObject:vc];
            break;
        }
    }
    self.navigationController.viewControllers = vcArr;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.isFromHelpVC) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                self.navigationController.interactivePopGestureRecognizer.enabled = NO;
            }
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        if (self.isFromHelpVC) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)creatAllViews {
    UIButton *rightNavButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightNavButton setTitle:@"帮助" forState:UIControlStateNormal];
    [rightNavButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [rightNavButton setTitleColor:RGBHex(0x6D6BED) forState:UIControlStateNormal];
    [rightNavButton addTarget:self action:@selector(helpButtonClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightNavButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    self.autoButton = [[UIButton alloc] init];
    [self.view addSubview:self.autoButton];
    [self.autoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(15);
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
        make.left.height.mas_equalTo(50);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-kBottomSafeHeight -15);
    }];
    ViewBorderRadius(self.autoButton, 5, 0, [UIColor whiteColor]);
    [self.autoButton setTitle:@"解析" forState:UIControlStateNormal];
    [self.autoButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [self.autoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.autoButton setBackgroundColor:RGBHex(0x78B9FF)];
    [self.autoButton addTarget:self action:@selector(autoButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)statusChange:(NSNotification *)noti {
    NSString *status = noti.userInfo[@"status"];
    if ([status isEqualToString:@"1"]) {
        [self.autoButton setBackgroundColor:[UIColor colorWithHexString:@"0x6D6BED"]];
    }
    else {
        [self.autoButton setBackgroundColor:[UIColor colorWithHexString:@"0x78B9FF"]];
    }
}

- (void)helpButtonClick {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"LTIsClickAdd"]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"LTHelpViewController" bundle:nil];
        LTHelpTableViewController *helpVC = [story instantiateViewControllerWithIdentifier:@"LTHelpViewController"];
        [self.navigationController pushViewController:helpVC animated:YES];
        
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"LTIsClickAdd"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"LTHelpTipViewController" bundle:nil];
        LTHelpTipViewController *helpVC = [story instantiateViewControllerWithIdentifier:@"LTHelpTipViewController"];
        [self.navigationController pushViewController:helpVC animated:YES];
    }
}

- (void)autoButtonClick {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AutoButtonNoti" object:nil];
}

@end
