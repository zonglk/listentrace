//
//  LTBaseTableViewCell.m
//  listentrace
//
//  Created by 宗丽康 on 2019/7/24.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTBaseTableViewCell.h"

@interface LTBaseTableViewCell ()

@property(nonatomic,strong) UILabel *customDetailLabel;//label

@end

@implementation LTBaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self setupUI];
    }
    return self;
}

#pragma mark - =================== 初始化页面 ===================

- (void)setupUI {
    
}

-(void)setCustomDetailText:(NSString *)customDetailText {
    _customDetailText = customDetailText;
    self.customDetailLabel.text = customDetailText;
}

-(UILabel *)customDetailLabel{
    if (!_customDetailLabel) {
        _customDetailLabel = [UILabel new];
        [self addSubview:_customDetailLabel];
        _customDetailLabel.font = SYSTEMFONT(14);
        _customDetailLabel.textColor = CBlackColor;
        _customDetailLabel.textAlignment = NSTextAlignmentCenter;
        [_customDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
            make.centerY.mas_equalTo(self);
        }];
    }
    return _customDetailLabel;
}

@end
