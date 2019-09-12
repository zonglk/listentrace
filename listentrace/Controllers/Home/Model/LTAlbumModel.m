//
//  LTAlbumModel.m
//  listentrace
//
//  Created by 宗丽康 on 2019/9/8.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTAlbumModel.h"

@implementation LTAlbumModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"tracks_info" : @"LTAddAlbumDetailModel"
             };
}

@end
