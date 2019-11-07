//
//  LTAlbumTableViewCell.h
//  listentrace
//
//  Created by luojie on 2019/8/19.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTBaseTableViewCell.h"
#import "LTAddAlbumDetailModel.h"
@class LTAlbumTableViewCell;

NS_ASSUME_NONNULL_BEGIN

@protocol LTAlbumTableViewCellDelegate <NSObject>

- (void)deleteButtonClick:(LTAlbumTableViewCell *)cell;
- (void)detailCellTextChange:(LTAlbumTableViewCell *)cell string:(NSString *)string index:(NSInteger)index;

@end

@interface LTAlbumTableViewCell : LTBaseTableViewCell

@property (weak, nonatomic) IBOutlet UITextField *songTextField; // 曲目
@property (weak, nonatomic) IBOutlet UITextField *lyricistTextField; // 作词人
@property (weak, nonatomic) IBOutlet UITextField *composerTextField; // 作曲人
@property (weak, nonatomic) IBOutlet UITextField *arrangerTextField; // 编曲人
@property (weak, nonatomic) IBOutlet UITextField *songPerformerTextField; // 乐器演奏者
@property (weak, nonatomic) IBOutlet UIButton *deleteButton; // 删除按钮
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (nonatomic, strong) LTAddAlbumDetailModel *model;
@property (nonatomic, weak) id <LTAlbumTableViewCellDelegate>delegate;
- (IBAction)deleteButtonClick:(id)sender;

@end

NS_ASSUME_NONNULL_END
