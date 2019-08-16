//
//  LTJSHandler.h
//  listentrace
//
//  Created by 宗丽康 on 2019/7/24.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LTJSHandler : NSObject<WKScriptMessageHandler>

@property (nonatomic,weak,readonly) UIViewController * webVC;
@property (nonatomic,strong,readonly) WKWebViewConfiguration * configuration;
-(instancetype)initWithViewController:(UIViewController *)webVC configuration:(WKWebViewConfiguration *)configuration;
-(void)cancelHandler;

@end

NS_ASSUME_NONNULL_END
