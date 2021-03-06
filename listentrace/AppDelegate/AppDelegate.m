//
//  AppDelegate.m
//  listentrace
//
//  Created by 宗丽康 on 2019/7/18.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 初始化 window
    [self initWindow];
    // 初始化用户系统
    [self initUserManager];
    sleep(1);
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LTDidEnterBackGround" object:nil];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"icloudName"];
    if (!userId.length) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LTDidBecomeActive" object:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LTDidBecomeActiveHandlePasteBoard" object:nil];
    
    NSError *err = nil;
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.listentrace"];
    containerURL = [containerURL URLByAppendingPathComponent:@"Library/Caches/addSucess.json"];
    NSString *statusString = [NSString stringWithContentsOfURL:containerURL encoding: NSUTF8StringEncoding error:&err];
    if ([statusString isEqualToString:@"YES"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddAlbumSucess" object:nil];
        
        //获取到共享数据的文件地址
        NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.listentrace"];
        NSURL *birthdayContainerURL = [containerURL URLByAppendingPathComponent:@"Library/Caches/addSucess.json"];
        //将需要存储的数据写入到该文件中
        NSString *jsonString = @"NO";
        //写入数据
        NSError *err = nil;
        [jsonString writeToURL:birthdayContainerURL atomically:YES encoding:NSUTF8StringEncoding error:&err];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
