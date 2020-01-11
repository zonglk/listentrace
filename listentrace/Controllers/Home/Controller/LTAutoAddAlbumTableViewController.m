//
//  LTAutoAddAlbumTableViewController.m
//  listentrace
//
//  Created by 宗丽康 on 2020/1/8.
//  Copyright © 2020 listentrace. All rights reserved.
//

#import "LTAutoAddAlbumTableViewController.h"
#import "LTNetworking.h"
#import "LTAlbumTableViewController.h"

@interface LTAutoAddAlbumTableViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *autoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *autoViewHeight;
@property (weak, nonatomic) IBOutlet UITextView *autoTextView;

@end

@implementation LTAutoAddAlbumTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = CViewBgColor;
    ViewBorderRadius(self.autoView, 5, 1, RGBHex(0xE5EAFA));
    self.autoTextView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoButtonClick) name:@"AutoButtonNoti" object:nil];
}

- (void)autoButtonClick {
    UIImageView *tipImageView = [[UIImageView alloc] init];
    [tipImageView setImage:[UIImage imageNamed:@"auto_link_handing"]];
    [[UIApplication sharedApplication].delegate.window addSubview:tipImageView];
    [tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        [make.centerY.mas_equalTo(self.view.mas_centerY) setOffset:(-30)];
    }];
    [LTNetworking requestUrl:@"/album/resolve" WithParam:@{@"url" : @"https://open.spotify.com/album/4xyCx6Yc4lDr3bC8S7FNuT?si=idfJ2cd5QDSk41v0FcrSkg"} withMethod:GET success:^(id  _Nonnull result) {
        if ([result[@"code"] intValue] == 200) {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"LTAlbumTableViewController" bundle:[NSBundle mainBundle]];
            LTAlbumTableViewController *albumVC = [story instantiateViewControllerWithIdentifier:@"LTAlbumTableViewController"];
            albumVC.result = result;
            [self.navigationController pushViewController:albumVC animated:YES];
        }
        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"解析失败" message:[NSString stringWithFormat:@"请检查专辑链接后，再重新尝试"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self.navigationController presentViewController:alert animated:YES completion:nil];
        }
        [tipImageView removeFromSuperview];
    } failure:^(NSError * _Nonnull erro) {
        
    } showHUD:self.view];
}

-(void)textViewDidChange:(UITextView *)textView{
    float textViewHeight =  [textView sizeThatFits:CGSizeMake(textView.frame.size.width, MAXFLOAT)].height;
    if (textViewHeight == 100) {
        self.autoViewHeight.constant  = 100 + 17;
        self.autoTextView.scrollEnabled = YES;
    }
    else if (textViewHeight > 0) {
        self.autoViewHeight.constant = textViewHeight + 17;
        self.autoTextView.scrollEnabled = NO;
    }
    else {
        self.autoViewHeight.constant = 55;
        self.autoTextView.scrollEnabled = NO;
    }
    CGRect frame = textView.frame;
    frame.size.height = textViewHeight+100;
    textView.frame = frame;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
