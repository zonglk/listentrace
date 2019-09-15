//
//  LTActivity.h
//  listentrace
//
//  Created by 宗丽康 on 2019/9/14.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LTActivity : UIActivity

- (instancetype)initWithTitle:(NSString *)title ActivityImage:(UIImage *)activityImage URL:(NSURL *)url ActivityType:(NSString *)activityType;

@end

NS_ASSUME_NONNULL_END
