//
//  LTRootNavgationController.h
//  listentrace
//
//  Created by luojie on 2019/7/22.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LTRootNavgationController : UINavigationController

/**
 返回指定的类视图

 @param className 类名
 @param animated 是否动画
 */
- (BOOL)popToAppointViewController:(NSString *)className animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
