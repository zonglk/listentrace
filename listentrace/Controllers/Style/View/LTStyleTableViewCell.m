//
//  LTStyleTableViewCell.m
//  listentrace
//
//  Created by 宗丽康 on 2019/7/28.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTStyleTableViewCell.h"

@interface LTStyleTableViewCell ()

- (IBAction)allStyleButtonClick:(id)sender;

@end

@implementation LTStyleTableViewCell

+ (instancetype)creatCell {
    return [[[NSBundle mainBundle] loadNibNamed:@"LTStyleTableViewCell" owner:nil options:nil] lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UITapGestureRecognizer *leftTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftTap)];
    [self.leftImageVIew addGestureRecognizer:leftTap];
    
    UITapGestureRecognizer *middleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(middleTap)];
    [self.middleImageVIew addGestureRecognizer:middleTap];
    
    UITapGestureRecognizer *rightTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightTap)];
    [self.rightImageView addGestureRecognizer:rightTap];
    
    [[self.leftImageVIew layer] setShadowOffset:CGSizeZero]; // 阴影扩散的范围控制
    [[self.leftImageVIew layer] setShadowRadius:4]; // 阴影扩散的范围控制
    [[self.leftImageVIew layer] setShadowOpacity:1]; // 阴影透明度
    [[self.leftImageVIew layer] setShadowColor:RGBHexAlpha(0x68BAE9, 0.45).CGColor]; // 阴影的颜色
    self.leftImageVIew.clipsToBounds = NO;
    
    [[self.middleImageVIew layer] setShadowOffset:CGSizeZero]; // 阴影扩散的范围控制
    [[self.middleImageVIew layer] setShadowRadius:4]; // 阴影扩散的范围控制
    [[self.middleImageVIew layer] setShadowOpacity:1]; // 阴影透明度
    [[self.middleImageVIew layer] setShadowColor:RGBHexAlpha(0x68BAE9, 0.45).CGColor]; // 阴影的颜色
    self.middleImageVIew.clipsToBounds = NO;
    
    [[self.rightImageView layer] setShadowOffset:CGSizeZero]; // 阴影扩散的范围控制
    [[self.rightImageView layer] setShadowRadius:4]; // 阴影扩散的范围控制
    [[self.rightImageView layer] setShadowOpacity:1]; // 阴影透明度
    [[self.rightImageView layer] setShadowColor:RGBHexAlpha(0x68BAE9, 0.45).CGColor]; // 阴影的颜色
    self.rightImageView.clipsToBounds = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)allStyleButtonClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(allStyleButtonClick:)]) {
        [self.delegate allStyleButtonClick:self];
    }
}

- (void)leftTap {
    if ([self.delegate respondsToSelector:@selector(imageClick:index:)]) {
        [self.delegate imageClick:self index:0];
    }
}

- (void)middleTap {
    if ([self.delegate respondsToSelector:@selector(imageClick:index:)]) {
        [self.delegate imageClick:self index:1];
    }
}

- (void)rightTap {
    if ([self.delegate respondsToSelector:@selector(imageClick:index:)]) {
        [self.delegate imageClick:self index:2];
    }
}


@end
