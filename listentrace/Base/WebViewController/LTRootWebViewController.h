//
//  LTRootWebViewController.h
//  listentrace
//
//  Created by 宗丽康 on 2019/7/24.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTWebViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LTRootWebViewController : LTWebViewController

//在多级跳转后，是否在返回按钮右侧展示关闭按钮
@property(nonatomic,assign) BOOL isShowCloseBtn;

@end

NS_ASSUME_NONNULL_END
