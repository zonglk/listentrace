//
//  LTStyleTableViewCell.h
//  listentrace
//
//  Created by 宗丽康 on 2019/7/28.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTBaseTableViewCell.h"
@class LTBaseTableViewCell;

NS_ASSUME_NONNULL_BEGIN

@protocol styleTableViewCellDelegate <NSObject>

- (void)allStyleButtonClick:(LTBaseTableViewCell *)cell;

@end

@interface LTStyleTableViewCell : LTBaseTableViewCell

@property (nonatomic, weak) id<styleTableViewCellDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
