//
//  LTBaseTableViewCell.h
//  listentrace
//
//  Created by 宗丽康 on 2019/7/24.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 cell 基类
 */

NS_ASSUME_NONNULL_BEGIN

@interface LTBaseTableViewCell : UITableViewCell

@property(nonatomic,copy) NSString *customDetailText;//介绍文本

@end

NS_ASSUME_NONNULL_END
