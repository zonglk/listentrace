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

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
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
@end
