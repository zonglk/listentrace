//
//  LTNetworking.m
//  listentrace
//
//  Created by luojie on 2019/9/5.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTNetworking.h"
#import "AFNetworking.h"

#define TIME_NETOUT     20.0f

@implementation LTNetworking  {
    AFHTTPSessionManager *_HTTPManager;
}

+ (id)sharedInstance {
    static LTNetworking *request;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        request = [[LTNetworking alloc] init];
    });
    return request;
}

- (id)init {
    if (self = [super init]) {
        _HTTPManager = [AFHTTPSessionManager manager];
        _HTTPManager.requestSerializer.HTTPShouldHandleCookies = YES;
        _HTTPManager.requestSerializer  = [AFHTTPRequestSerializer serializer];
        _HTTPManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [_HTTPManager.requestSerializer setTimeoutInterval:TIME_NETOUT];
        [_HTTPManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept" ];
        _HTTPManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json",@"text/html", @"text/plain",nil];
    }
    return self;
}

+ (void)requestUrl:(NSString *)url
         WithParam:(NSDictionary *)param
        withMethod:(HTTPRequestMethod)method
           success:(void(^)(id result))success
           failure:(void(^)(NSError *erro))failure
           showHUD:(UIView *)showView {
    [[LTNetworking sharedInstance] createUnloginedRequest:url WithParam:param withMethod:method success:success failure:failure showHUD:showView];
}

- (void)createUnloginedRequest:(NSString *)url WithParam:(NSDictionary *)param withMethod:(HTTPRequestMethod)method success:(void(^)(id result))success failure:(void(^)(NSError *erro))failure showHUD:(UIView *)showView {
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *URLString = [self getUrl:url];
    /******************************************************************/
    /**
     *  将cookie通过请求头的形式传到服务器，比较是否和服务器一致
     */
    NSData *cookiesData = [[NSUserDefaults standardUserDefaults] objectForKey:@"Cookie"];
    
    if([cookiesData length]) {
        /**
         *  拿到所有的cookies
         */
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesData];
        
        for (NSHTTPCookie *cookie in cookies) {
            /**
             *  判断cookie是否等于服务器约定的ECM_ID
             */
            if ([cookie.name isEqualToString:@"ECM_ID"]) {
                //实现了一个管理cookie的单例对象,每个cookie都是NSHTTPCookie类的实例,将cookies传给服务器
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            }
        }
    }
    
    /******************************************************************/
    NSMutableURLRequest *request = [_HTTPManager.requestSerializer requestWithMethod:[self getStringForRequestType:method] URLString:[[NSURL URLWithString:URLString relativeToURL:_HTTPManager.baseURL] absoluteString] parameters:param error:nil];
    NSURLSessionDataTask *dataTask = [_HTTPManager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
//            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (error.code == -1009) {
                [MBProgressHUD showErrorMessage:@"网络已断开"];
            }
            else if (error.code == -1005) { // 网络连接已中断
                [MBProgressHUD showErrorMessage:@"网络连接已中断"];
            }
            else if(error.code == -1001) { // 请求超时
                [MBProgressHUD showErrorMessage:@"请求超时"];
            }
            else if (error.code == -1003) { // 未能找到使用指定主机名的服务器
                [MBProgressHUD showErrorMessage:@"未能找到使用指定主机名的服务器"];
            }
            else { // 网络出错了~请稍后重试
                [MBProgressHUD showErrorMessage:@"网络较差，请稍后重试"];
            }
            
            if (failure != nil) {
                failure(error);
            }
        }
        else {
            if (success != nil) {
//                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                id result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                success(result);
            }
        }
    }];
    [dataTask resume];
}

+ (void)uploadImageWithUrl:(NSString *)rul
            WithParam:(NSDictionary*)param
          withExParam:(NSDictionary*)Exparam
           withMethod:(HTTPRequestMethod)method
              success:(void (^)(id result))success
   uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
              failure:(void (^)(NSError* erro))failure {
    [[LTNetworking sharedInstance] createUnloginedRequest:rul WithParam:param withExParam:Exparam withMethod:method success:success failure:failure uploadFileProgress:uploadFileProgress];
}

- (void)createUnloginedRequest:(NSString *)url WithParam:(NSDictionary *)param withExParam:(NSDictionary*)Exparam withMethod:(HTTPRequestMethod)method success:(void(^)(id result))success failure:(void(^)(NSError *erro))failure uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress {
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *URLString = [self getUrl:url];
    /**
     *  将cookie通过请求头的形式传到服务器，比较是否和服务器一致
     */
    NSData *cookiesData = [[NSUserDefaults standardUserDefaults] objectForKey:@"Cookie"];
    if([cookiesData length]) {
        /**
         *  拿到所有的cookies
         */
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesData];
        for (NSHTTPCookie *cookie in cookies) {
            /**
             *  判断cookie是否等于服务器约定的ECM_ID
             */
            if ([cookie.name isEqualToString:@"ECM_ID"]) {
                //实现了一个管理cookie的单例对象,每个cookie都是NSHTTPCookie类的实例,将cookies传给服务器
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            }
        }
    }
    
    /******************************************************************/
    NSMutableURLRequest *request = [_HTTPManager.requestSerializer multipartFormRequestWithMethod:[self getStringForRequestType:method] URLString:URLString parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //图片上传
        if (Exparam) {
            for (NSString *key in [Exparam allKeys]) {
                [formData appendPartWithFileData:[Exparam objectForKey:key] name:key fileName:[NSString stringWithFormat:@"%@.png",key] mimeType:@"image/jpeg"];
            }
        }
    } error:nil];
    
    NSURLSessionDataTask *dataTask = [_HTTPManager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        if (uploadProgress) { //上传进度
            uploadFileProgress (uploadProgress);
        }
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
//            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (error.code == -1009) {
                [MBProgressHUD showErrorMessage:@"网络已断开"];
            }
            else if (error.code == -1005) { // 网络连接已中断
                [MBProgressHUD showErrorMessage:@"网络连接已中断"];
            }
            else if(error.code == -1001) { // 请求超时
                [MBProgressHUD showErrorMessage:@"请求超时"];
            }
            else if (error.code == -1003) { // 未能找到使用指定主机名的服务器
                [MBProgressHUD showErrorMessage:@"未能找到使用指定主机名的服务器"];
            }
            else { // 网络出错了~请稍后重试
                [MBProgressHUD showErrorMessage:@"网络较差，请稍后重试"];
            }
            
            if (failure != nil) {
                failure(error);
            }
        }
        else {
            if (success != nil) {
//                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                id result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                success(result);
            }
        }
    }];
    [dataTask resume];
}

- (NSString *)getStringForRequestType:(HTTPRequestMethod)type {
    NSString *requestTypeString;
    switch (type) {
        case POST:
            requestTypeString = @"POST";
            break;
            
        case GET:
            requestTypeString = @"GET";
            break;
            
        case PUT:
            requestTypeString = @"PUT";
            break;
            
        case DELETE:
            requestTypeString = @"DELETE";
            break;
            
        default:
            requestTypeString = @"POST";
            break;
    }
    return requestTypeString;
}

- (NSString *)getUrl:(NSString *)url {
    NSString *urlString = @"http://101.37.25.106:8080/listentrace";
//#ifdef DEBUG
//    urlString = [NSString stringWithFormat:@"http://tsdev.zlapi.com%@",url];
//#else
//    urlString = [NSString stringWithFormat:@"https://ts.zlapi.com%@",url];
//#endif
    
    NSMutableString *finalUrl = [NSMutableString string];
    [finalUrl appendString:urlString];
    NSString *next;
    if([urlString rangeOfString:@"?"].location != NSNotFound) {
        next = @"&";
    }
    else {
        next = @"?";
    }
    [finalUrl appendFormat:@"%@",url];
    [finalUrl appendString:next];
    return finalUrl;
}

-(NSString*)DataTOjsonString:(id)object {
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}


@end
