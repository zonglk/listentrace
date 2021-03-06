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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *linkUrl;
@property (strong, nonatomic) UIButton *coverButton;
@property (weak, nonatomic) IBOutlet UIView *autoLinkVIew;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkLabelWidth;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
- (IBAction)button1Click:(id)sender;
- (IBAction)button2Click:(id)sender;
- (IBAction)linkButtonClick:(id)sender;

@property (assign, nonatomic) BOOL isLinkVC;
@property (assign, nonatomic) BOOL isCancle;

@end

@implementation LTAutoAddAlbumTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatAllViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoButtonClick) name:@"AutoButtonNoti" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPastedBoardString) name:@"LTDidBecomeActiveHandlePasteBoard" object:nil];
    self.autoTextView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.isLinkVC = YES;
    NSString *pasteBoardString = [[UIPasteboard generalPasteboard] string];
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:@"LinkUrlString"];
    if ([pasteBoardString isEqualToString:string] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"LinkUrl"]) {
        return;
    }
    
    if ([pasteBoardString containsString:@"open.spotify.com"] || [pasteBoardString containsString:@"music.apple.com"] || [pasteBoardString containsString:@"music.163.com"] || [pasteBoardString containsString:@"tidal.com"]) {
        if ([pasteBoardString containsString:@"(@网易云音乐)"]) {
            NSArray *array = [pasteBoardString componentsSeparatedByString:@"》"];
            pasteBoardString = array.lastObject;
            
            NSArray *resultArray = [pasteBoardString componentsSeparatedByString:@"("];
            pasteBoardString = resultArray.firstObject;
        }
        self.linkUrl.text = pasteBoardString;
        [self linkButtonClick:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isLinkVC = NO;
}

- (void)creatAllViews {
    self.view.backgroundColor = CViewBgColor;
    ViewBorderRadius(self.autoView, 5, 1, RGBHex(0xE5EAFA));
    self.autoTextView.delegate = self;
    
    self.linkView.hidden = YES;
    self.button1.hidden = YES;
    self.button2.hidden = YES;
}

- (void)getPastedBoardString {
    if (!self.isLinkVC || self.isCancle || self.autoTextView.text.length) {
        self.linkView.hidden = YES;
        self.button1.hidden = YES;
        self.button2.hidden = YES;
        return;
    }
    
    self.linkUrl.text = [[UIPasteboard generalPasteboard] string];
    
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:@"LinkUrlString"];
    if ([self.linkUrl.text isEqualToString:string]) {
        return;
    }
    
    if ([self.linkUrl.text containsString:@"open.spotify.com"] || [self.linkUrl.text containsString:@"music.apple.com"] || [self.linkUrl.text containsString:@"music.163.com"] || [self.linkUrl.text containsString:@"tidal.com"]) {
        [self addCoverView];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LinkUrl"];
        [[NSUserDefaults standardUserDefaults] setValue:self.linkUrl.text forKey:@"LinkUrlString"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"LinkUrl"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)addCoverView {
    NSString *string =[[UIPasteboard generalPasteboard] string];
    if ([string containsString:@"(@网易云音乐)"]) {
        NSArray *array = [string componentsSeparatedByString:@"》"];
        string = array.lastObject;
        
        NSArray *resultArray = [string componentsSeparatedByString:@"("];
        string = resultArray.firstObject;
    }
    self.linkUrl.text = string;
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

- (void)coverButtonClick {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"LinkUrl"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.coverButton.hidden = YES;
    self.linkView.hidden = YES;
}

#pragma mark 解析

- (void)autoButtonClick {
    if (!self.autoTextView.text.length) {
        return;
    }
    UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [[UIApplication sharedApplication].delegate.window addSubview:coverView];
    
    UIView *view = [[UIView alloc] init];
    [coverView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(88, 88));
    }];
    view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    view.layer.cornerRadius = 6;
    view.clipsToBounds = YES;

    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(14, 0, 60, 60)];
    [view addSubview:activityIndicator];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [activityIndicator startAnimating];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 52, 88, 30)];
    [view addSubview:label];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor whiteColor];
    label.text = @"解析中...";
    [LTNetworking requestUrl:@"/album/resolve" WithParam:@{@"url" : self.autoTextView.text} withMethod:GET success:^(id  _Nonnull result) {
        NSDictionary *dic = result[@"data"];
        if ([result[@"code"] intValue] == 200 && [dic class] != [NSNull class]) {
            NSString *albumString = result[@"data"][@"album_img"];
            UIImageView *imageView = [[UIImageView alloc] init];
            if (albumString != nil && [albumString class] != [NSNull class]) {
                [imageView sd_setImageWithURL:[NSURL URLWithString:albumString] placeholderImage:[UIImage imageNamed:@"album_detail_placeImage"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (!error) {
                        NSString *path_document = NSHomeDirectory();
                        NSString *imagePath = [path_document stringByAppendingString:@"/Documents/headerPic.png"];
                        [UIImagePNGRepresentation(imageView.image) writeToFile:imagePath atomically:YES];
                        
                        UIStoryboard *story = [UIStoryboard storyboardWithName:@"LTAlbumTableViewController" bundle:[NSBundle mainBundle]];
                        LTAlbumTableViewController *albumVC = [story instantiateViewControllerWithIdentifier:@"LTAlbumTableViewController"];
                        if ([self.autoTextView.text containsString:@"music.apple.com"]) {
                            albumVC.isNeedTailoring = YES;
                        }
                        else {
                            albumVC.isNeedTailoring = NO;
                        }
                        albumVC.result = result;
                        [self.navigationController pushViewController:albumVC animated:YES];
                        [coverView removeFromSuperview];
                        [view removeFromSuperview];
                    }
                    else {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"解析失败" message:[NSString stringWithFormat:@"请检查专辑链接后，再重新尝试"] preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                        [alert addAction:action];
                        [self.navigationController presentViewController:alert animated:YES completion:nil];
                        [coverView removeFromSuperview];
                        [view removeFromSuperview];
                    }
                }];
            }
        }
        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"解析失败" message:[NSString stringWithFormat:@"请检查专辑链接后，再重新尝试"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self.navigationController presentViewController:alert animated:YES completion:nil];
            [coverView removeFromSuperview];
            [view removeFromSuperview];
        }
    } failure:^(NSError * _Nonnull erro) {
        [coverView removeFromSuperview];
        [view removeFromSuperview];
    } showHUD:self.view];
}

-(void)textViewDidChange:(UITextView *)textView{
    float textViewHeight =  [textView sizeThatFits:CGSizeMake(textView.frame.size.width, MAXFLOAT)].height;
    if (textViewHeight > 100) {
        self.autoViewHeight.constant = 100 + 17;
        self.textViewHeight.constant = 100;
        return;
    }
    else if (textViewHeight > 0) {
        self.autoViewHeight.constant = textViewHeight + 17;
        self.textViewHeight.constant = textViewHeight;
    }
    else {
        self.textViewHeight.constant = 50;
        self.autoViewHeight.constant = 55;
    }
    
    if (textView.text.length == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LinkUrlButton" object:nil userInfo:@{@"status" : @"0"}];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LinkUrlButton" object:nil userInfo:@{@"status" : @"1"}];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        [self.autoTextView resignFirstResponder];
        return NO;
    }
    return YES;
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
    self.button1.hidden = YES;
    self.button2.hidden = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
