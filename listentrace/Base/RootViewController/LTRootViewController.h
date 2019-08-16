//
//  LTRootViewController.h
//  listentrace
//
//  Created by 宗丽康 on 2019/7/21.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LTRootViewController : UIViewController

/// 修改状态栏颜色
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
/// 是否显示返回按钮， 默认是YES
@property (nonatomic, assign) BOOL isShowLeftBackButton;
/// 是否隐藏导航栏
@property (nonatomic, assign) BOOL isHidenNaviBar;

/**
 导航栏添加文本按钮

 @param titles 文本数组
 @param isLeft 是否是左边，非左即右
 @param target 目标
 @param action 点击方法
 @param tags 数组，回调区分用
 */
- (void)addNavgationItemWithTitles:(NSArray *)titles isLeft:(BOOL)isLeft target:(id)target action:(SEL)action tags:(NSArray *)tags;

/**
 导航栏添加图片按钮

 @param imageNames 图片数组
 @param isLeft 是否左边，非左即右
 @param target 目标
 @param action 点击方法
 @param tags 区分回调用
 */
- (void)addNavgationItemWithImageNames:(NSArray *)imageNames isLeft:(BOOL)isLeft target:(id)target action:(SEL)action tags:(NSArray *)tags;
/// 默认返回按钮的点击事件,默认是返回，子类可重写
- (void)backBtnClicked;

@end

NS_ASSUME_NONNULL_END
