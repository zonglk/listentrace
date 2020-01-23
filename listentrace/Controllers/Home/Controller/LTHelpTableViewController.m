//
//  LTHelpTableViewController.m
//  listentrace
//
//  Created by 宗丽康 on 2020/1/6.
//  Copyright © 2020 listentrace. All rights reserved.
//

#import "LTHelpTableViewController.h"
#import "LTAutoAddAlbumViewController.h"

@interface LTHelpTableViewController ()

@property (weak, nonatomic) IBOutlet UIButton *knowButton;
@property (strong, nonatomic) UIView *coverView;
- (IBAction)knowButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet UIImageView *image3;

@end

@implementation LTHelpTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.knowButton.layer.cornerRadius = 23;
    self.knowButton.clipsToBounds = YES;
    
    self.coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, 80, 30)];
    [[UIApplication sharedApplication].delegate.window addSubview:self.coverView];
    self.coverView.backgroundColor = [UIColor whiteColor];
    
    if (kDevice_iphone4 || kDevice_iphone5) {
        self.image1.contentMode = UIViewContentModeScaleAspectFit;
        self.image2.contentMode = UIViewContentModeScaleAspectFit;
        self.image3.contentMode = UIViewContentModeScaleAspectFit;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.coverView removeFromSuperview];

    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (IBAction)knowButtonClick:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LTReadAddTips"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"LTAutoAddAlbumViewController" bundle:nil];
    LTAutoAddAlbumViewController *autoVC = [story instantiateViewControllerWithIdentifier:@"LTAutoAddAlbumViewController"];
    autoVC.isFromHelpVC  = YES;
    [self.navigationController pushViewController:autoVC animated:YES];
}

@end
