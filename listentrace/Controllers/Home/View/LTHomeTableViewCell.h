//
//  LTHomeTableViewCell.h
//  listentrace
//
//  Created by 宗丽康 on 2019/7/28.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTBaseTableViewCell.h"
#import "LTAlbumModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LTHomeTableViewCell : LTBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *producter;
@property (weak, nonatomic) IBOutlet UIImageView *loveImage;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (nonatomic, strong) LTAlbumModel *model;

+ (instancetype)creatCell;

@end

NS_ASSUME_NONNULL_END
