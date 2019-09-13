//
//  LTHomeTableViewCell.m
//  listentrace
//
//  Created by 宗丽康 on 2019/7/28.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTHomeTableViewCell.h"

@implementation LTHomeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(LTAlbumModel *)model {
    _model = model;
    [self.image sd_setImageWithURL:[NSURL URLWithString:model.album_img]];
    self.name.text = model.album_name;
    self.producter.text = model.album_musician;
    
    if ([model.favorite intValue] == 1) {
        self.loveImage.hidden = NO;
    }
    else {
        self.loveImage.hidden = YES;
    }
}

@end
