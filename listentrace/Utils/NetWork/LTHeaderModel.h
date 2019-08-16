//
//  LTHeaderModel.h
//  listentrace
//
//  Created by 宗丽康 on 2019/7/24.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenUDID.h"

NS_ASSUME_NONNULL_BEGIN

@interface LTHeaderModel : NSObject

@property(nonatomic,assign)long long userid;//用户ID
@property (nonatomic,copy) NSString * imei;//设备号
@property (nonatomic,assign) NSInteger  os_type;//0未知,1安卓,2IOS
@property (nonatomic,copy) NSString * version;//当前APP版本
@property (nonatomic,copy) NSString * channel;//来源渠道 苹果使用：@"App Store"
@property (nonatomic,copy) NSString * clientId;//客户端唯一标示，后台用来判断是否更换设备
@property (nonatomic,assign) NSInteger  versioncode;//内部维护的应用版本 随版本递增
@property (nonatomic,copy) NSString * mobile_model;//手机型号
@property (nonatomic,copy) NSString * mobile_brand;//手机品牌
@property (nonatomic,copy) NSString * token;//用户登录后分配的登录Token

@end

NS_ASSUME_NONNULL_END
