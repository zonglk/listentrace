//
//  LTNetworking.h
//  listentrace
//
//  Created by luojie on 2019/9/5.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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

/**
 *  上传文件功能，如图片等
 *
 *  @param url                服务器提供的接口
 *  @param param              传的参数
 *  @param Exparam            文件流，将要上传的文件转成NSData中，然后一起传给服务器
 *  @param method             GET,POST,DELETE,PUT方法
 *  @param success            请求完成
 *  @param uploadFileProgress 请求图片的进度条，百分比
 *  @param failure            请求失败
 */
+ (void)uploadImageWithUrl:(NSString *)url
        WithParam:(NSDictionary*)param
        withExParam:(NSDictionary*)Exparam
        withMethod:(HTTPRequestMethod)method
        success:(void (^)(id result))success
        uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
        failure:(void (^)(NSError* erro))failure;

@end

NS_ASSUME_NONNULL_END
