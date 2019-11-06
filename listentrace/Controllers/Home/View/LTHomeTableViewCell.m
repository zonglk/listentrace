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
    [[self.image layer] setShadowOffset:CGSizeZero]; // 阴影扩散的范围控制
    [[self.image layer] setShadowRadius:4]; // 阴影扩散的范围控制
    [[self.image layer] setShadowOpacity:1]; // 阴影透明度
    [[self.image layer] setShadowColor:RGBHexAlpha(0x68BAE9, 0.45).CGColor]; // 阴影的颜色
    self.image.clipsToBounds = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(LTAlbumModel *)model {
    _model = model;
    [self.image sd_setImageWithURL:[NSURL URLWithString:model.album_img] placeholderImage:[UIImage imageNamed:@"home_placeImage"]];
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
