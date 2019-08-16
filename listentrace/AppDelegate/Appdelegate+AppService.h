//
//  Appdelegate+AppService.h
//  listentrace
//
//  Created by 宗丽康 on 2019/7/21.
//  Copyright © 2019 listentrace. All rights reserved.
//


#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (AppService)

/// 初始化 window
- (void)initWindow;

/// 初始化 用户系统
-(void)initUserManager;

/// 单例
+ (AppDelegate *)shareAppDelegate;

/**
 当前顶层控制器
 */
-(UIViewController*) getCurrentVC;
-(UIViewController*) getCurrentUIVC;


@end

NS_ASSUME_NONNULL_END
