//
//  LTHelpTipsTableViewController.m
//  listentrace
//
//  Created by 宗丽康 on 2020/1/7.
//  Copyright © 2020 listentrace. All rights reserved.
//

#import "LTHelpTipsTableViewController.h"

@interface LTHelpTipsTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *text1;
@property (weak, nonatomic) IBOutlet UILabel *text2;

@end

@implementation LTHelpTipsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:@"复制链接："];
    [str1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:15.f] range:NSMakeRange(0, 4)];
    self.text1.attributedText = str1;
    
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:@"Share Sheet:"];
    [str2 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:15.f] range:NSMakeRange(0, 4)];
    self.text2.attributedText = str2;
}

@end
