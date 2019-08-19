//
//  LTAlbumStyleView.m
//  listentrace
//
//  Created by luojie on 2019/8/19.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTAlbumStyleView.h"

@implementation LTAlbumStyleView

+ (instancetype)creatStyleView {
    NSString *className = NSStringFromClass([self class]);
    UINib *nib = [UINib nibWithNibName:className bundle:nil];
    return [nib instantiateWithOwner:nil options:nil].firstObject;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
