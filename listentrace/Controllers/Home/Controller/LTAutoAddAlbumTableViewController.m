//
//  LTAutoAddAlbumTableViewController.m
//  listentrace
//
//  Created by 宗丽康 on 2020/1/8.
//  Copyright © 2020 listentrace. All rights reserved.
//

#import "LTAutoAddAlbumTableViewController.h"

@interface LTAutoAddAlbumTableViewController ()

@property (weak, nonatomic) IBOutlet UIView *autoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *autoViewHeight;
@property (weak, nonatomic) IBOutlet UITextView *autoTextView;

@end

@implementation LTAutoAddAlbumTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = CViewBgColor;
    ViewBorderRadius(self.autoView, 5, 1, RGBHex(0xE5EAFA));
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoButtonClick) name:@"AutoButtonNoti" object:nil];
}

- (void)autoButtonClick {
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
