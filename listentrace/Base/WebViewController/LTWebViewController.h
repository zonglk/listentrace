//
//  LTWebViewController.h
//  listentrace
//
//  Created by 宗丽康 on 2019/7/24.
//  Copyright © 2019 listentrace. All rights reserved.
//
//  网页视图

#import "LTRootViewController.h"
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LTWebViewController : LTRootViewController

@property (nonatomic,strong) WKWebView * webView;
@property (nonatomic,strong) UIProgressView * progressView;
@property (nonatomic) UIColor *progressViewColor;
@property (nonatomic,weak) WKWebViewConfiguration * webConfiguration;
@property (nonatomic, copy) NSString * url;

-(instancetype)initWithUrl:(NSString *)url;
//更新进度条
-(void)updateProgress:(double)progress;
//更新导航栏按钮，子类去实现
-(void)updateNavigationItems;

@end

NS_ASSUME_NONNULL_END
