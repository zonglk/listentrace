//
//  LTAlbumTimePIckerView.m
//  listentrace
//
//  Created by luojie on 2019/9/5.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTAlbumTimePIckerView.h"

#define KScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define KScreenHeight ([[UIScreen mainScreen] bounds].size.height)

@implementation LTAlbumTimePIckerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)creatXib {
    return [[[NSBundle mainBundle] loadNibNamed:@"LTAlbumTimePIckerView" owner:nil options:nil] lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self creatAllViews];
}

- (void)creatAllViews {
    self.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
}

- (IBAction)cancleButtonClick:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)sureButtonClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(timePickerSureButtonClick)]) {
        [self.delegate timePickerSureButtonClick];
    }
}
@end
