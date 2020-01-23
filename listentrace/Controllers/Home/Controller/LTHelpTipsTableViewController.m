//
//  LTHelpTipsTableViewController.m
//  listentrace
//
//  Created by 宗丽康 on 2020/1/7.
//  Copyright © 2020 listentrace. All rights reserved.
//

#import "LTHelpTipsTableViewController.h"

@interface LTHelpTipsTableViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet UIImageView *image3;

@end

@implementation LTHelpTipsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (kDevice_iphone4 || kDevice_iphone5) {
        self.image1.contentMode = UIViewContentModeScaleAspectFit;
        self.image2.contentMode = UIViewContentModeScaleAspectFit;
        self.image3.contentMode = UIViewContentModeScaleAspectFit;
    }
}

@end
