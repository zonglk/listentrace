//
//  LTStyleDetailCollectionViewCell.h
//  listentrace
//
//  Created by 宗丽康 on 2019/7/29.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LTStyleDetailCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

NS_ASSUME_NONNULL_END
