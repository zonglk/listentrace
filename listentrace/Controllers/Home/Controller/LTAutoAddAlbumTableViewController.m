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
@property (strong, nonatomic) IBOutlet UITableView *linkTableView;

@property (weak, nonatomic) IBOutlet UIView *autoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *autoViewHeight;
@property (weak, nonatomic) IBOutlet UITextView *autoTextView;
@property (weak, nonatomic) IBOutlet UIView *linkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkViewWidth;
@property (weak, nonatomic) IBOutlet UILabel *linkUrl;
@property (strong, nonatomic) UIButton *coverButton;
@property (weak, nonatomic) IBOutlet UIView *autoLinkVIew;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkLabelWidth;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
- (IBAction)button1Click:(id)sender;
- (IBAction)button2Click:(id)sender;
- (IBAction)linkButtonClick:(id)sender;

@end

@implementation LTAutoAddAlbumTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatAllViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoButtonClick) name:@"AutoButtonNoti" object:nil];
}

- (void)creatAllViews {
    self.view.backgroundColor = CViewBgColor;
    ViewBorderRadius(self.autoView, 5, 1, RGBHex(0xE5EAFA));
    self.autoTextView.delegate = self;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LinkUrl"]) {
        self.linkUrl.text = [[UIPasteboard generalPasteboard] string];
        CGFloat titleWidth = [self.linkUrl.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} context:nil].size.width;
        CGFloat width = KScreenWidth - 40 > titleWidth + 40 ? titleWidth + 40: KScreenWidth - 40;
        self.linkViewWidth.constant = width > 110 ? width : 110;
        self.linkLabelWidth.constant = self.linkViewWidth.constant - 20;
        self.linkView.hidden = NO;
        
        self.autoLinkVIew.layer.cornerRadius = 5.0f;
        self.autoLinkVIew.layer.masksToBounds = YES;
        self.autoLinkVIew.layer.shadowColor = [UIColor colorWithHexString:@"0x6D6BED"].CGColor;
        self.autoLinkVIew.layer.shadowOffset = CGSizeZero; //设置偏移量为0,四周都有阴影
        self.autoLinkVIew.layer.shadowRadius = 10.0f;//阴影半径，默认3
        self.autoLinkVIew.layer.shadowOpacity = .5f;//阴影透明度，默认0
        self.autoLinkVIew.layer.masksToBounds = NO;
        self.autoLinkVIew.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.linkViewWidth.constant, 65) cornerRadius:self.autoLinkVIew.layer.cornerRadius].CGPath;
        self.button1.hidden = NO;
        self.button2.hidden = NO;
    }
    else {
        self.linkView.hidden = YES;
        self.button1.hidden = YES;
        self.button2.hidden = YES;
    }
}

- (void)coverButtonClick {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"LinkUrl"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.coverButton.hidden = YES;
    self.linkView.hidden = YES;
}

- (void)autoButtonClick {
    if (!self.autoTextView.text.length) {
        return;
    }
    UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [[UIApplication sharedApplication].delegate.window addSubview:coverView];
    
    UIImageView *tipImageView = [[UIImageView alloc] init];
    [tipImageView setImage:[UIImage imageNamed:@"auto_link_handing"]];
    [[UIApplication sharedApplication].delegate.window addSubview:tipImageView];
    [tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        [make.centerY.mas_equalTo(self.view.mas_centerY) setOffset:(-30)];
    }];
    [LTNetworking requestUrl:@"/album/resolve" WithParam:@{@"url" : self.autoTextView.text} withMethod:GET success:^(id  _Nonnull result) {
        NSDictionary *dic = result[@"data"];
        if ([result[@"code"] intValue] == 200 && [dic class] != [NSNull class]) {
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
        [coverView removeFromSuperview];
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
    
    if (textView.text.length == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LinkUrlButton" object:nil userInfo:@{@"status" : @"0"}];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LinkUrlButton" object:nil userInfo:@{@"status" : @"1"}];
    }
}

- (IBAction)button1Click:(id)sender {
    [self coverButtonClick];
}

- (IBAction)button2Click:(id)sender {
    [self coverButtonClick];
}

- (IBAction)linkButtonClick:(id)sender {
    self.autoTextView.text = self.linkUrl.text;
       [[NSNotificationCenter defaultCenter] postNotificationName:@"LinkUrlButton" object:nil userInfo:@{@"status" : @"1"}];
       [self coverButtonClick];
    [self textViewDidChange:self.autoTextView];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
