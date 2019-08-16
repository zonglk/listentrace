//
//  LTMainTabBarController.m
//  listentrace
//
//  Created by 宗丽康 on 2019/7/21.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTMainTabBarController.h"
#import "LTRootNavgationController.h"
#import "LTHomeViewController.h"
#import "LTStyleViewController.h"
#import "LTSetUpViewController.h"

@interface LTMainTabBarController ()<UITabBarControllerDelegate>

@property (nonatomic,strong) NSMutableArray * VCS;//tabbar root VCsetUpAllChildViewController

@end

@implementation LTMainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    // 初始化 tabbar
    [self setUpTabbar];
    // 添加子控制器
    [self setUpAllChildViewController];
}

- (void)setUpTabbar {
    [self.tabBar setBackgroundColor:CWhiteColor];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
}

- (void)setUpAllChildViewController {
    _VCS = @[].mutableCopy;
    
    LTHomeViewController *homeVC = [[LTHomeViewController alloc] init];
    [self setupChildViewController:homeVC title:@"听迹" imageName:@"home_tabbar_normal" seleceImageName:@"home_tabbar_selected"];
    
    LTStyleViewController *styleVC = [[LTStyleViewController alloc] init];
    [self setupChildViewController:styleVC title:@"风格" imageName:@"style_tabbar_normal" seleceImageName:@"style_tabbar_selected"];
    
    UIStoryboard *mainStory = [UIStoryboard storyboardWithName:@"LTSetUpViewController" bundle:nil];
    LTSetUpViewController *setUpVC = [mainStory instantiateViewControllerWithIdentifier:@"LTSetUpViewController"];
    [self setupChildViewController:setUpVC title:@"设置" imageName:@"setup_tabbar_normal" seleceImageName:@"setup_tabbar_selected"];
    
    self.viewControllers = _VCS;
}

-(void)setupChildViewController:(UIViewController*)controller title:(NSString *)title imageName:(NSString *)imageName seleceImageName:(NSString *)selectImageName {
    controller.title = title;
    controller.tabBarItem.title = title;
    controller.tabBarItem.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    controller.tabBarItem.selectedImage = [[UIImage imageNamed:selectImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [controller.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:CTabbarTextNormalColor,NSFontAttributeName:SYSTEMFONT(9.0f)} forState:UIControlStateNormal];
    [controller.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:CTabbarTextSelectedColor,NSFontAttributeName:SYSTEMFONT(9.0f)} forState:UIControlStateSelected];
    //包装导航控制器
    LTRootNavgationController *nav = [[LTRootNavgationController alloc]initWithRootViewController:controller];
    
    [_VCS addObject:nav];
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
