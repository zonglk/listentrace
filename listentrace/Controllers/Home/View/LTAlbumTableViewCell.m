//
//  LTAlbumTableViewCell.m
//  listentrace
//
//  Created by luojie on 2019/8/19.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTAlbumTableViewCell.h"

@implementation LTAlbumTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteButtonClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(deleteButtonClick:)]) {
        [self.delegate deleteButtonClick:self];
    }
}
@end
