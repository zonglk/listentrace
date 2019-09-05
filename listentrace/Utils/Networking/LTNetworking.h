//
//  LTNetworking.h
//  listentrace
//
//  Created by luojie on 2019/9/5.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, HTTPRequestMethod) {
    POST = 0,
    GET,
    PUT,
    DELETE
};

NS_ASSUME_NONNULL_BEGIN

@interface LTNetworking : NSObject

+ (id)sharedInstance;

/**
 *  HTTP请求
 *
 *  @param url      服务器提供的接口
 *  @param param    传的参数
 *  @param method   GET,POST,DELETE,PUT方法
 *  @param success  请求完成
 *  @param failure  请求失败
 *  @param showView 界面上显示的网络加载进度状态(nil为不显示)
 */
+ (void)requestUrl:(NSString *)url
         WithParam:(NSDictionary *)param
        withMethod:(HTTPRequestMethod)method
           success:(void(^)(id result))success
           failure:(void(^)(NSError *erro))failure
           showHUD:(UIView *)showView;

@end

NS_ASSUME_NONNULL_END
