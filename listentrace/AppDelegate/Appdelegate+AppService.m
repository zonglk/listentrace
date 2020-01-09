//
//  Appdelegate+AppService.m
//  listentrace
//
//  Created by 宗丽康 on 2019/7/21.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "Appdelegate+AppService.h"
#import "IQKeyboardManager.h"
#import "LTAlbumTableViewController.h"
#import "LTAutoAddAlbumViewController.h"

@implementation AppDelegate (AppService)

#pragma mark - =================== 初始化window ===================

- (void)initWindow {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = CWhiteColor;
    [self.window makeKeyAndVisible];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [[UIButton appearance] setExclusiveTouch:YES];
    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [IQKeyboardManager sharedManager].shouldShowToolbarPlaceholder = NO; // 是否显示占位文字
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
}

#pragma mark - =================== 初始化用户系统 ===================

- (void)initUserManager {
    self.mainTabBar = [LTMainTabBarController new];
    self.window.rootViewController = self.mainTabBar;
}

+ (AppDelegate *)shareAppDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (UIViewController *)getCurrentVC {
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

- (UIViewController *)getCurrentUIVC {
    UIViewController  *superVC = [self getCurrentVC];
    if ([superVC isKindOfClass:[UITabBarController class]]) {
        UIViewController  *tabSelectVC = ((UITabBarController*)superVC).selectedViewController;
        if ([tabSelectVC isKindOfClass:[UINavigationController class]]) {
            return ((UINavigationController*)tabSelectVC).viewControllers.lastObject;
        }
        return tabSelectVC;
    }
    else
        if ([superVC isKindOfClass:[UINavigationController class]]) {
            return ((UINavigationController*)superVC).viewControllers.lastObject;
        }
    return superVC;
}

#pragma mark - =================== URL Schemes ===================

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSString *str = url.absoluteString;
    
    UITabBarController *tbc = (UITabBarController *)self.window.rootViewController;
    UINavigationController *nav = tbc.viewControllers[tbc.selectedIndex];
    [nav popToRootViewControllerAnimated:YES];
    //判断url是否包含addAlbum
    if([str containsString:@"Listentrace://manual"]) { // 手动
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"LTAlbumTableViewController" bundle:[NSBundle mainBundle]];
        LTAlbumTableViewController *albumVC = [story instantiateViewControllerWithIdentifier:@"LTAlbumTableViewController"];
        [nav pushViewController:albumVC animated:YES];
    }
    else if ([str containsString:@"Listentrace://link"]) { // 自动
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"LTAutoAddAlbumViewController" bundle:nil];
        LTAutoAddAlbumViewController *autoVC = [story instantiateViewControllerWithIdentifier:@"LTAutoAddAlbumViewController"];
        [nav pushViewController:autoVC animated:YES];
    }
    return YES;
}

@end
