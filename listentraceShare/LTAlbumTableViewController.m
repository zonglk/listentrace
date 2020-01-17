//
//  LTAlbumTableViewController.m
//  listentrace
//
//  Created by 宗丽康 on 2019/8/4.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTAlbumTableViewController.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import "LTAlbumStyleView.h"
#import "JPImageresizerView.h"
#import "LTShareNetworking.h"
#import "QFTimePickerView.h"
#import "QFDatePickerView.h"
#import "LTAlbumTimePIckerView.h"
#import "UIImageView+WebCache.h"

#define kWeakSelf(type)  __weak typeof(type) weak##type = type;

#define RGBHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//View 圆角和加边框
#define ViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]

#define kIS_IPHONE_X ([UIScreen mainScreen].bounds.size.height > 736.0f) ? YES : NO
#define kBottomSafeHeight   ((kIS_IPHONE_X)? 34 : 0)

#define KScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define KScreenHeight ([[UIScreen mainScreen] bounds].size.height)

@interface LTAlbumTableViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, LTAlbumTimePickerDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITableView *albumTableView;
@property (weak, nonatomic) IBOutlet UILabel *tipsImageLabel;
@property (weak, nonatomic) IBOutlet UIButton *albumButton;
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@property (weak, nonatomic) IBOutlet UIButton *loveButton; // 红心
@property (weak, nonatomic) IBOutlet UIButton *styleButton; // 风格
@property (weak, nonatomic) IBOutlet UIButton *styleViewButton;
@property (weak, nonatomic) IBOutlet UITextField *albumNameTextField; // 专辑名
@property (weak, nonatomic) IBOutlet UITextField *musicianTextField; // 音乐人
@property (weak, nonatomic) IBOutlet UITextField *styleTextField; // 风格
@property (weak, nonatomic) IBOutlet UITextField *timeTextField; // 时长
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet UIButton *listeningTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *releaseButton;
@property (weak, nonatomic) IBOutlet UIButton *releaseCountButton;
@property (weak, nonatomic) IBOutlet UITextField *listeningTimeTextField; // 聆听时间
@property (weak, nonatomic) IBOutlet UITextField *releasedTimeTextField; // 发行时间
@property (weak, nonatomic) IBOutlet UITextField *releasedCountTextField; // 发行数目
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UIView *view4;

@property (nonatomic, weak) LTAlbumStyleView *styleView;
@property (nonatomic, strong) UIButton *cancleButton;
@property (nonatomic, strong) UIButton *sureButton;
@property (nonatomic, strong) JPImageresizerView *imageresizerView;
@property (nonatomic, strong) UIView *styleCoverView;
@property (nonatomic, strong) LTAlbumTimePIckerView *timePicker;
@property (nonatomic, copy) NSString *listeningTimeString;
@property (nonatomic, copy) NSString *releaseTimeString;
@property (nonatomic, assign) BOOL isListeningTime;
@property (nonatomic, copy) NSString *imageId; // 上传图片拿到的后台的id
@property (nonatomic, assign) BOOL isSave; // 专辑已存在时候的保存
@property (nonatomic, assign) BOOL isEditImage; // 编辑图片时按钮不可用
@property (copy, nonatomic) NSString *userId;

- (IBAction)albumButtonClick:(id)sender; // 专辑封面
- (IBAction)loveButtonClick:(id)sender; // 喜欢
- (IBAction)albumStyle:(id)sender; // 风格
- (IBAction)albumTimeButtonClick:(id)sender; // 专辑时长
- (IBAction)listeningTime:(id)sender; // 聆听时间
- (IBAction)releaseTime:(id)sender; // 发布时间
- (IBAction)releaseCount:(id)sender; // 发布数量
- (IBAction)cancleButtonClick:(id)sender;
- (IBAction)saveButtonClick:(id)sender;

@end

@implementation LTAlbumTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatAllViews];

    NSDate *date = [NSDate date];
    NSDateFormatter *forMatter = [[NSDateFormatter alloc] init];
    [forMatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [forMatter stringFromDate:date];
    self.listeningTimeString = dateStr;
    self.listeningTimeTextField.text = self.listeningTimeString;

    if (self.urlString) {
        [self requestData];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(styleChangeNoti:) name:@"AlbumStyleChangeNoti" object:nil];
}

- (void)creatAllViews {
    ViewBorderRadius(self.view1, 5, 1, RGBHex(0xE5EAFA));
    ViewBorderRadius(self.view2, 5, 1, RGBHex(0xE5EAFA));
    ViewBorderRadius(self.view3, 5, 1, RGBHex(0xE5EAFA));
    ViewBorderRadius(self.view4, 5, 1, RGBHex(0xE5EAFA));
}

- (void)styleChangeNoti:(NSNotification *)noti {
    self.styleTextField.text = [NSString stringWithFormat:@"%@",noti.userInfo[@"style"]];
    [self.styleCoverView removeFromSuperview];
}

- (void)requestData {
    [LTShareNetworking requestUrl:@"/album/resolve" WithParam:@{@"url" : self.urlString} withMethod:GET success:^(id  _Nonnull result) {
        NSDictionary *dic = result[@"data"];
        if ([result[@"code"] intValue] == 200 && [dic class] != [NSNull class]) {
            [self handleDate:result];
        }
        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"解析失败" message:[NSString stringWithFormat:@"请检查专辑链接后，再重新尝试"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } failure:^(NSError * _Nonnull erro) {
        
    } showHUD:self.view];
}

- (void)handleDate:(id)result {
    NSString *albumString = result[@"data"][@"album_img"];
    if (albumString != nil && [albumString class] != [NSNull class]) {
        [self.albumImageView sd_setImageWithURL:[NSURL URLWithString:albumString] placeholderImage:[UIImage imageNamed:@"album_detail_placeImage"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!error) {
                [self postLinkImage];
                [self.albumButton setImage:nil forState:UIControlStateNormal];
            }
        }];
    }

    NSString *albumNameString = result[@"data"][@"album_name"];
    if (albumNameString != nil && [albumNameString class] != [NSNull class]) {
        self.albumNameTextField.text = result[@"data"][@"album_name"];
    }
    NSString *musicianTextString = result[@"data"][@"album_musician"];
    if (musicianTextString != nil && [musicianTextString class] != [NSNull class]) {
        self.musicianTextField.text = result[@"data"][@"album_musician"];
    }
    NSString *styleTextString = result[@"data"][@"album_style"];
    if (styleTextString != nil && [styleTextString class] != [NSNull class]) {
        self.styleTextField.text = result[@"data"][@"album_style"];
    }
    NSString *durationString = result[@"data"][@"album_duration"];
    if (durationString != nil && [durationString class] != [NSNull class]) {
        self.timeTextField.text = result[@"data"][@"album_duration"];
    }
    NSString *listeningTimeString = result[@"data"][@"listen_time"];
    if (listeningTimeString != nil && [listeningTimeString class] != [NSNull class]) {
        self.listeningTimeTextField.text = result[@"data"][@"listen_time"];
    }
    NSString *releaseTimeString = result[@"data"][@"album_release_time"];
    if (releaseTimeString != nil && [releaseTimeString class] != [NSNull class]) {
        self.releasedTimeTextField.text = result[@"data"][@"album_release_time"];
    }
    NSString *quantityString = result[@"data"][@"song_quantity"];
    if (quantityString != nil  && [quantityString class] != [NSNull class]) {
        self.releasedCountTextField.text = result[@"data"][@"song_quantity"];
    }
}

#pragma mark 保存专辑信息

- (void)saveButtonClick {
    [self handleKeyBoard];
    
    NSError *err = nil;
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.listentrace"];
    containerURL = [containerURL URLByAppendingPathComponent:@"Library/Caches/userId.json"];
    self.userId = [NSString stringWithContentsOfURL:containerURL encoding: NSUTF8StringEncoding error:&err];
    
    if (!self.userId.length) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"请先前往《听迹》App登录"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self disMisSelf];
        }];
        [alert addAction:sureAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    NSString *albumString = self.result[@"data"][@"album_img"];
    if (!albumString.length && (!self.imageId.length && !self.albumId.length)) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"请上传专辑封面图"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if (!self.albumNameTextField.text.length) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"请填写专辑名"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if (!self.musicianTextField.text.length) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"请填写专辑音乐人"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if (!self.styleTextField.text.length) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"请选择专辑风格"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if (!self.listeningTimeTextField.text.length) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"请选择聆听时间"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    [parameter setObject:self.userId forKey:@"user_id"];
    [parameter setObject:self.albumNameTextField.text forKey:@"album_name"];
    [parameter setObject:self.musicianTextField.text forKey:@"album_musician"];
    [parameter setObject:self.styleTextField.text forKey:@"album_style"];
    [parameter setObject:self.listeningTimeTextField.text forKey:@"listen_time"];
    if (self.imageId.length) {
        [parameter setObject:self.imageId forKey:@"album_img"];
    }
    if (self.timeTextField.text.length) {
        [parameter setObject:self.timeTextField.text forKey:@"album_duration"];
    }
    if (self.releasedTimeTextField.text.length) {
        [parameter setObject:self.releasedTimeTextField.text forKey:@"album_release_time"];
    }
    if (self.releasedCountTextField.text.length) {
        [parameter setObject:self.releasedCountTextField.text forKey:@"song_quantity"];
    }
    if (self.loveButton.selected) {
        [parameter setObject:@(1) forKey:@"favorite"];
    }
    else {
        [parameter setObject:@(0) forKey:@"favorite"];
    }

    NSString *url;
    if (self.albumId.length) {
        url = @"/album/update";
        [parameter setObject:self.albumId forKey:@"album_id"];
    }
    else {
        url = @"/album/add";
    }

    if (self.isSave) {
        [parameter setValue:@(YES) forKey:@"repeat"];
    }
    else {
        [parameter setValue:@(NO) forKey:@"repeat"];
    }

    [LTShareNetworking requestUrl:url WithParam:parameter withMethod:POST success:^(id  _Nonnull result) {
        if ([result[@"code"] intValue] == 200) {
            self.isSave = NO;
            [self disMisSelf];
        }
        else if ([result[@"code"] intValue] == 1002) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"已添加过该专辑，是否继续保存。"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.isSave = YES;
                [self saveButtonClick];
            }];
            [alert addAction:action];
            [alert addAction:sureAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:result[@"msg"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } failure:^(NSError * _Nonnull erro) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"网络连接失败，请稍后重试"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    } showHUD:self.view];
}

#pragma mark  添加/修改专辑照片

- (IBAction)albumButtonClick:(id)sender {
    [self handleKeyBoard];
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"选择图片" message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:@"选择照片"];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:RGBHex(0x8F8F8F) range:NSMakeRange(0, 4)];
    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, 4)];
    [actionSheet setValue:alertControllerStr forKey:@"attributedTitle"];

    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"请打开相册访问权限"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self showAlbum];
                }
                else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"请先打开相册访问权限，否则您无法使用上传专辑图片功能"] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:action];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }];
        }
        else if (status == PHAuthorizationStatusAuthorized) {
            [self showAlbum];
        }
    }];

    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"请打开相机访问权限"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else if (status == AVAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self showCamera];
                }
                else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"请先打开相册访问权限，否则您无法使用上传专辑图片功能"] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:action];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }];
        }
        else if (status == AVAuthorizationStatusAuthorized) {
            [self showCamera];
        }
    }];

    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [cancleAction setValue:RGBHex(0x8F8F8F) forKey:@"titleTextColor"];

    [actionSheet addAction:albumAction];
    [actionSheet addAction:cameraAction];
    [actionSheet addAction:cancleAction];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark  相册

- (void)showAlbum {
    UIImagePickerController *vc = [[UIImagePickerController alloc] init];
    vc.delegate = self;
    vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark  相机

- (void)showCamera {
    dispatch_async(dispatch_get_main_queue(), ^{
       UIImagePickerController *vc = [[UIImagePickerController alloc] init];
       vc.delegate = self;
       vc.sourceType = UIImagePickerControllerSourceTypeCamera;
       vc.modalPresentationStyle = UIModalPresentationFullScreen;
       [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithResizeImage:image make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_resizeImage(image)
        .jp_maskAlpha(0.6)
        .jp_strokeColor(RGBHex(0xCCCCCC))
        .jp_frameType(JPClassicFrameType)
        .jp_bgColor([UIColor blackColor])
        .jp_isClockwiseRotation(YES)
        .jp_animationCurve(JPAnimationCurveEaseOut);
    }];

    JPImageresizerView *imageresizerView = [JPImageresizerView imageresizerViewWithConfigure:configure imageresizerIsCanRecovery:^(BOOL isCanRecovery) {

    } imageresizerIsPrepareToScale:^(BOOL isPrepareToScale) {
        if (isPrepareToScale) {
            self.sureButton.hidden = YES;
            self.cancleButton.hidden = YES;
            self.isEditImage = YES;
        }
        else {
            self.sureButton.hidden = NO;
            self.cancleButton.hidden = NO;
            self.isEditImage = NO;
        }
    }];
    [imageresizerView setResizeWHScale:(1.0 / 1.0) isToBeArbitrarily:YES animated:YES];
    [[UIApplication sharedApplication].keyWindow addSubview:imageresizerView];
    self.imageresizerView = imageresizerView;
    if (@available(iOS 11.0, *)) {

    }
    else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self addImageAction];
}

- (void)addImageAction {
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, KScreenHeight - kBottomSafeHeight - 60, KScreenWidth, 1)];
    line.backgroundColor = [UIColor grayColor];
    [self.imageresizerView addSubview:line];

    UIButton *cancleButton = [[UIButton alloc] initWithFrame:CGRectMake(25, KScreenHeight - kBottomSafeHeight - 40, 40, 20)];
    [cancleButton setTitleColor:RGBHex(0xFB1414) forState:UIControlStateNormal];
    [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancleButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [self.imageresizerView addSubview:cancleButton];
    [cancleButton addTarget:self action:@selector(cancleButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.cancleButton = cancleButton;

    UIButton *sureButton = [[UIButton alloc] initWithFrame:CGRectMake(KScreenWidth - 30 - 40, KScreenHeight - kBottomSafeHeight - 40, 40, 20)];
    [sureButton setTitleColor:RGBHex(0x5079D9) forState:UIControlStateNormal];
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [self.imageresizerView addSubview:sureButton];
    [sureButton addTarget:self action:@selector(sureButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.sureButton = sureButton;
}

#pragma mark 红心喜欢按钮

- (IBAction)loveButtonClick:(id)sender {
    self.loveButton.selected = !self.loveButton.selected;
}

#pragma mark 风格编辑

- (IBAction)albumStyle:(id)sender {
    [self handleKeyBoard];
    UIView *coverView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
    [[UIApplication sharedApplication].keyWindow addSubview:coverView];
    coverView.backgroundColor = [UIColor clearColor];
    self.styleCoverView = coverView;

    UIButton *button = [[UIButton alloc] initWithFrame:coverView.frame];
    [self.styleCoverView addSubview:button];
    [button addTarget:self action:@selector(tapCoverView) forControlEvents:UIControlEventTouchUpInside];

    [self.styleCoverView addSubview:self.styleView];
}

- (void)tapCoverView {
    [self.styleCoverView removeFromSuperview];
}

#pragma mark 取消图片选择

- (void)cancleButtonClick {
    [self.imageresizerView removeFromSuperview];
}

#pragma mark 上传选择的图片
- (void)sureButtonClick {
    [self.imageresizerView removeFromSuperview];
    kWeakSelf(self);
    [self.imageresizerView originImageresizerWithComplete:^(UIImage *resizeImage) {
        NSData *imageData = UIImageJPEGRepresentation(resizeImage, 0.2f);
        NSMutableDictionary *Exparams = [[NSMutableDictionary alloc]init];
        [Exparams addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:imageData,@"file", nil]];
        [LTShareNetworking uploadImageWithUrl:@"/img/upload" WithParam:[NSDictionary dictionary] withExParam:Exparams withMethod:POST success:^(id  _Nonnull result) {
            if ([result[@"code"] intValue] == 200) {
                [weakself.albumButton setImage:resizeImage forState:UIControlStateNormal];
                self.imageId = result[@"data"];
                self.tipsImageLabel.hidden = YES;
            }
            else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:result[@"msg"] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
        } uploadFileProgress:^(NSProgress * _Nonnull uploadProgress) {

        } failure:^(NSError * _Nonnull erro) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"网络连接失败，请稍后重试"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }];
    }];
}

#pragma mark  链接传图

- (void)postLinkImage {
    NSData *imageData = UIImageJPEGRepresentation(self.albumImageView.image, 0.2f);
    NSMutableDictionary *Exparams = [[NSMutableDictionary alloc]init];
    [Exparams addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:imageData,@"file", nil]];
    [LTShareNetworking uploadImageWithUrl:@"/img/upload" WithParam:[NSDictionary dictionary] withExParam:Exparams withMethod:POST success:^(id  _Nonnull result) {
        if ([result[@"code"] intValue] == 200) {
            self.imageId = result[@"data"];
            self.tipsImageLabel.hidden = YES;
        }
        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:result[@"msg"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } uploadFileProgress:^(NSProgress * _Nonnull uploadProgress) {

    } failure:^(NSError * _Nonnull erro) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"网络连接失败，请稍后重试"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

#pragma mark  时长

- (IBAction)albumTimeButtonClick:(id)sender {
    [self handleKeyBoard];
    QFTimePickerView *pickerView = [[QFTimePickerView alloc] initDatePackerWithStartHour:@"0" endHour:@"24" period:1 timeString:self.timeTextField.text response:^(NSString *str) {
        self.timeTextField.text = str;
    }];
    [pickerView show];
}

#pragma mark 聆听时间

- (IBAction)listeningTime:(id)sender {
    [self handleKeyBoard];
    self.isListeningTime = YES;
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSDate *minDate = [fmt dateFromString:@"1997-1-1"];
    self.timePicker.timePicker.minimumDate = minDate;
    if (self.listeningTimeTextField.text.length) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
        NSDate *tempDate = [dateFormatter dateFromString:self.listeningTimeTextField.text];
        [self.timePicker.timePicker setDate:tempDate animated:NO];
    }
    else {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        NSString *DateTime = [formatter stringFromDate:date];
        NSDate *tempDate = [formatter dateFromString:DateTime];
        [self.timePicker.timePicker setDate:tempDate animated:NO];
    }
    [self.albumTableView addSubview:self.timePicker];
}

#pragma mark 发布时间

- (IBAction)releaseTime:(id)sender {
    [self handleKeyBoard];
    self.isListeningTime = NO;

    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSDate *minDate = [fmt dateFromString:@"1902-1-1"];
    self.timePicker.timePicker.minimumDate = minDate;
    if (self.releasedTimeTextField.text.length) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
        NSDate *tempDate = [dateFormatter dateFromString:self.releasedTimeTextField.text];
        [self.timePicker.timePicker setDate:tempDate animated:NO];
    }
    else {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        NSString *DateTime = [formatter stringFromDate:date];
        NSDate *tempDate = [formatter dateFromString:DateTime];
        [self.timePicker.timePicker setDate:tempDate animated:NO];
    }
    [self.tableView addSubview:self.timePicker];
}

#pragma mark 聆听、发行时间代理

- (void)timePickerSureButtonClick {
    if (self.isListeningTime) {
        if (!self.listeningTimeString) {
            NSDate *date = [NSDate date];
            NSDateFormatter *forMatter = [[NSDateFormatter alloc] init];
            [forMatter setDateFormat:@"yyyy-MM-dd"];
            NSString *dateStr = [forMatter stringFromDate:date];
            self.listeningTimeString = dateStr;
        }
        self.listeningTimeTextField.text = self.listeningTimeString;
    }
    else {
        if (!self.releaseTimeString) {
            NSDate *date = [NSDate date];
            NSDateFormatter *forMatter = [[NSDateFormatter alloc] init];
            [forMatter setDateFormat:@"yyyy-MM-dd"];
            NSString *dateStr = [forMatter stringFromDate:date];
            self.releaseTimeString = dateStr;
        }
        self.releasedTimeTextField.text = self.releaseTimeString;
    }
    [self.timePicker removeFromSuperview];
}

#pragma mark  timePicker delegate

- (void)dateChanged:(UIDatePicker *)picker{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    if (self.isListeningTime) {
        self.listeningTimeString = [formatter stringFromDate:picker.date];
    }
    else {
        self.releaseTimeString = [formatter stringFromDate:picker.date];
    }
}

#pragma mark 发布数量

- (IBAction)releaseCount:(id)sender {
    [self handleKeyBoard];
    QFDatePickerView *datePickerView = [[QFDatePickerView alloc] initYearPickerWithView:self.view countString:self.releasedCountTextField.text response:^(NSString *str) {
        if ([str intValue] > 100) {
            str = @"10 首";
        }
        self.releasedCountTextField.text = str;
    }];
    [datePickerView show];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self handleKeyBoard];
    return YES;
}

- (void)handleKeyBoard {
    [self.albumNameTextField resignFirstResponder];
    [self.musicianTextField resignFirstResponder];
    [self.styleTextField resignFirstResponder];
    [self.timeTextField resignFirstResponder];
    [self.listeningTimeTextField resignFirstResponder];
    [self.releasedTimeTextField resignFirstResponder];
    [self.releasedCountTextField resignFirstResponder];
}

- (LTAlbumStyleView *)styleView {
    if (!_styleView) {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        CGRect startRact = [self.styleViewButton convertRect:self.styleViewButton.bounds toView:window];
        LTAlbumStyleView *albumView = [[LTAlbumStyleView alloc] initWithFrame:CGRectMake(startRact.origin.x - 137, startRact.origin.y + 20, 170, 250)];
        _styleView = albumView;
    }
    return _styleView;
}

- (LTAlbumTimePIckerView *)timePicker {
    if (!_timePicker) {
        _timePicker = [LTAlbumTimePIckerView creatXib];
        _timePicker.delegate = self;
        // 设置显示最大时间（此处为当前时间）
        [_timePicker.timePicker setMaximumDate:[NSDate date]];
        [_timePicker.timePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _timePicker;
}

- (IBAction)cancleButtonClick:(id)sender {
    [self disMisSelf];
}

- (IBAction)saveButtonClick:(id)sender {
    [self saveButtonClick];
}

- (void)disMisSelf {
    [self dismissViewControllerAnimated:self completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DisMisSelf" object:nil];
}

@end
