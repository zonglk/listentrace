//
//  LTHelpTableViewController.m
//  listentrace
//
//  Created by 宗丽康 on 2020/1/6.
//  Copyright © 2020 listentrace. All rights reserved.
//

#import "LTHelpTableViewController.h"

@interface LTHelpTableViewController ()

@property (weak, nonatomic) IBOutlet UIButton *knowButton;
- (IBAction)knowButtonClick:(id)sender;

@end

@implementation LTHelpTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.knowButton.layer.cornerRadius = 23;
    self.knowButton.clipsToBounds = YES;
}

- (IBAction)knowButtonClick:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LTReadAddTips"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
