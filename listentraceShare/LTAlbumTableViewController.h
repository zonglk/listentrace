//
//  LTAlbumTableViewController.h
//  listentrace
//
//  Created by 宗丽康 on 2019/8/4.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LTAlbumTableViewController : UITableViewController

@property (nonatomic, copy) NSString *albumId;
@property (strong, nonatomic) NSDictionary *result;
@property (nonatomic, copy) NSString *urlString;

@end

NS_ASSUME_NONNULL_END
