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
- (void)imageClick:(LTBaseTableViewCell *)cell index:(NSInteger)index;

@end

@interface LTStyleTableViewCell : LTBaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *styleLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageVIew;
@property (weak, nonatomic) IBOutlet UIImageView *middleImageVIew;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (nonatomic, weak) id<styleTableViewCellDelegate>delegate;

+ (instancetype)creatCell;

@end

NS_ASSUME_NONNULL_END
