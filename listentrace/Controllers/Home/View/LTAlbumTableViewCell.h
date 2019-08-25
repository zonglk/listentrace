//
//  LTAlbumTableViewCell.h
//  listentrace
//
//  Created by luojie on 2019/8/19.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTBaseTableViewCell.h"
@class LTAlbumTableViewCell;

@protocol LTAlbumTableViewCellDelegate <NSObject>

- (void)deleteButtonClick:(LTAlbumTableViewCell *)cell;

@end

NS_ASSUME_NONNULL_BEGIN

@interface LTAlbumTableViewCell : LTBaseTableViewCell

@property (nonatomic, weak) id <LTAlbumTableViewCellDelegate>delegate;
- (IBAction)deleteButtonClick:(id)sender;

@end

NS_ASSUME_NONNULL_END
