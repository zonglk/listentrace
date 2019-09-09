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
#import "LTAlbumTableViewCell.h"
#import "LTAlbumStyleView.h"
#import "JPImageresizerView.h"
#import "LTAlbumStyleView.h"
#import "LTNetworking.h"
#import "QFTimePickerView.h"

@interface LTAlbumTableViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, LTAlbumTableViewCellDelegate>
@property (strong, nonatomic) IBOutlet UITableView *albumTableView;
@property (weak, nonatomic) IBOutlet UILabel *tipsImageLabel;
@property (weak, nonatomic) IBOutlet UIButton *albumButton;
@property (weak, nonatomic) IBOutlet UIButton *loveButton; // 红心
@property (weak, nonatomic) IBOutlet UIButton *styleButton; // 风格
@property (weak, nonatomic) IBOutlet UITextField *albumNameTextField; // 专辑名
@property (weak, nonatomic) IBOutlet UITextField *musicianTextField; // 音乐人
@property (weak, nonatomic) IBOutlet UITextField *styleTextField; // 风格
@property (weak, nonatomic) IBOutlet UITextField *timeTextField; // 时长
@property (weak, nonatomic) IBOutlet UITextField *listeningTimeTextField; // 聆听时间
@property (weak, nonatomic) IBOutlet UITextField *releasedTimeTextField; // 发行时间
@property (weak, nonatomic) IBOutlet UITextField *releasedCountTextField; // 发行数目
@property (weak, nonatomic) IBOutlet UITextField *producerTextField; // 制作人
@property (weak, nonatomic) IBOutlet UITextField *mixerTextField; // 录音师
@property (weak, nonatomic) IBOutlet UITextField *mixingTextField; // 混音师
@property (weak, nonatomic) IBOutlet UITextField *masteringTextField; // 母带工程师
@property (weak, nonatomic) IBOutlet UITextField *coverTextField; // 封面设计师

- (IBAction)addDetailButtonClick:(id)sender;

@property (nonatomic, weak) LTAlbumStyleView *styleView;
@property (nonatomic, strong) UIButton *cancleButton;
@property (nonatomic, strong) UIButton *sureButton;
@property (nonatomic, strong) JPImageresizerView *imageresizerView;
@property (nonatomic, strong) LTAlbumStyleView *albumStyleView;
@property (nonatomic, assign) CGPoint styleViewPoint;
@property (nonatomic, strong) UIView *styleCoverView;
@property (nonatomic, strong) NSMutableArray *detailDataArray;

- (IBAction)albumButtonClick:(id)sender; // 专辑封面
- (IBAction)loveButtonClick:(id)sender; // 喜欢
- (IBAction)albumStyle:(id)sender forEvent:(UIEvent *)event; // 风格
- (IBAction)albumTimeButtonClick:(id)sender; // 专辑时长

@end

@implementation LTAlbumTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatAllViews];
}

- (void)creatAllViews {
    self.title = @"专辑信息";
    self.tableView.backgroundColor = CViewBgColor;
    UIButton *rightNavButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightNavButton setTitle:@"保存" forState:UIControlStateNormal];
    [rightNavButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [rightNavButton setTitleColor:RGBHex(0x007AFF) forState:UIControlStateNormal];
    [rightNavButton addTarget:self action:@selector(saveButtonClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightNavButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    [self.albumTableView registerNib:[UINib nibWithNibName:@"LTAlbumTableViewCell" bundle:nil] forCellReuseIdentifier:@"LTAlbumTableViewCell"];
    self.albumTableView.estimatedRowHeight = 0;
    self.albumTableView.estimatedSectionHeaderHeight = 0;
    self.albumTableView.estimatedSectionFooterHeight = 0;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(styleChangeNoti:) name:@"AlbumStyleChangeNoti" object:nil];
}

- (void )styleChangeNoti:(NSNotification *)noti {
    self.styleTextField.text = [NSString stringWithFormat:@"%@",noti.userInfo[@"style"]];
    [self.styleCoverView removeAllSubviews];
    [self.styleCoverView removeFromSuperview];
}

#pragma mark 键盘出现
- (void)keyboardWillShow:(NSNotification *)note {
    CGRect keyBoardRect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, keyBoardRect.size.height, 0);
}

#pragma mark 键盘消失
- (void)keyboardWillHide:(NSNotification *)note {
    self.tableView.contentInset = UIEdgeInsetsZero;
}

#pragma mark - ================ 保存专辑信息 ================

- (void)saveButtonClick {
    if (!self.albumNameTextField.text.length) {
        [MBProgressHUD showInfoMessage:@"请填写专辑名"];
        return;
    }
    if (!self.musicianTextField.text.length) {
        [MBProgressHUD showInfoMessage:@"请填写专辑音乐人"];
        return;
    }
    if (!self.styleTextField.text.length) {
        [MBProgressHUD showInfoMessage:@"请选择专辑风格"];
        return;
    }
    
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    NSString  *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"icloudName"];
    [parameter setObject:userId forKey:@"user_id"];
    [parameter setObject:self.albumNameTextField.text forKey:@"album_name"];
    [parameter setObject:self.musicianTextField.text forKey:@"album_musician"];
    [parameter setObject:self.styleTextField.text forKey:@"album_style"];
    
    if (self.timeTextField.text.length) {
        [parameter setObject:self.timeTextField.text forKey:@"album_duration"];
    }
    if (self.listeningTimeTextField.text.length) {
        [parameter setObject:self.listeningTimeTextField.text forKey:@"listen_year"];
    }
    if (self.releasedTimeTextField.text.length) {
        [parameter setObject:self.releasedTimeTextField.text forKey:@"album_release_year"];
    }
    if (self.releasedCountTextField.text.length) {
        [parameter setObject:self.releasedCountTextField.text forKey:@"song_quantity"];
    }
    if (self.mixerTextField.text.length) {
        [parameter setObject:self.mixerTextField.text forKey:@"sound_engineer"];
    }
    if (self.mixingTextField.text.length) {
        [parameter setObject:self.mixingTextField.text forKey:@"sound_mixer"];
    }
    if (self.masteringTextField.text.length) {
        [parameter setObject:self.masteringTextField.text forKey:@"mastering_engineer"];
    }
    if (self.coverTextField.text.length) {
        [parameter setObject:self.coverTextField.text forKey:@"cover_designer"];
    }
//    if (self.timeTextField.text.length) {
//        [parameter setObject:self.timeTextField.text forKey:@"album_tracks"];
//    }
//    if (self.timeTextField.text.length) {
//        [parameter setObject:self.timeTextField.text forKey:@"album_lyricist"];
//    }
//    if (self.timeTextField.text.length) {
//        [parameter setObject:self.timeTextField.text forKey:@"album_composer"];
//    }
//    if (self.timeTextField.text.length) {
//        [parameter setObject:self.timeTextField.text forKey:@"album_arranger"];
//    }
//    if (self.timeTextField.text.length) {
//        [parameter setObject:self.timeTextField.text forKey:@"album_player"];
//    }
    if (self.loveButton.selected) {
        [parameter setObject:@(1) forKey:@"favorite"];
    }
    else {
        [parameter setObject:@(1) forKey:@"favorite"];
    }
    [LTNetworking requestUrl:@"/album/add" WithParam:parameter withMethod:POST success:^(id  _Nonnull result) {
        if ([result[@"code"] intValue] == 0) {
            [MBProgressHUD showInfoMessage:result[@"msg"]];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [MBProgressHUD showInfoMessage:result[@"msg"]];
        }
    } failure:^(NSError * _Nonnull erro) {
            [MBProgressHUD showInfoMessage:@"网络连接失败，请稍后重试"];
    } showHUD:self.view];
}

#pragma mark - =================== UITableView Delegate\dataSource ===================

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return self.detailDataArray.count;
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        LTAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LTAlbumTableViewCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = CViewBgColor;
        cell.delegate = self;
        return cell;
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return 270;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1) {
        return [super tableView:tableView indentationLevelForRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
    }
    return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
}

#pragma mark - ================ 添加/修改专辑照片 ================

- (IBAction)albumButtonClick:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"选择图片" message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:@"选择照片"];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:RGBHex(0x8F8F8F) range:NSMakeRange(0, 4)];
    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, 4)];
    [actionSheet setValue:alertControllerStr forKey:@"attributedTitle"];
    
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
            [MBProgressHUD showErrorMessage:@"请打开相册访问权限"];
        }
        else if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self showAlbum];
                }
                else {
                    [MBProgressHUD showErrorMessage:@"请先打开相册访问权限，否则您无法使用上传专辑图片功能"];
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
            [MBProgressHUD showErrorMessage:@"请打开相机访问权限"];
        }
        else if (status == AVAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self showCamera];
                }
                else {
                    [MBProgressHUD showErrorMessage:@"请先打开相册访问权限，否则您无法使用上传专辑图片功能"];
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
    [self.navigationController presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark - ================ 相册 ================

- (void)showAlbum {
    UIImagePickerController *vc = [[UIImagePickerController alloc] init];
    vc.delegate = self;
    vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - =================== 相机 ===================

- (void)showCamera {
    UIImagePickerController *vc = [[UIImagePickerController alloc] init];
    vc.delegate = self;
    vc.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:vc animated:YES completion:nil];
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
        .jp_maskAlpha(0.7)
        .jp_strokeColor([UIColor whiteColor])
        .jp_frameType(JPClassicFrameType)
        .jp_bgColor([UIColor blackColor])
        .jp_isClockwiseRotation(YES)
        .jp_animationCurve(JPAnimationCurveEaseOut);
    }];
    
    JPImageresizerView *imageresizerView = [JPImageresizerView imageresizerViewWithConfigure:configure imageresizerIsCanRecovery:^(BOOL isCanRecovery) {

    } imageresizerIsPrepareToScale:^(BOOL isPrepareToScale) {

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
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor grayColor];
    [self.imageresizerView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imageresizerView.mas_left);
        make.right.mas_equalTo(self.imageresizerView.mas_right);
        make.bottom.mas_equalTo(self.imageresizerView.mas_bottom).offset(-kBottomSafeHeight - 60);
        make.height.mas_equalTo(1);
    }];
    
    UIButton *cancleButton = [[UIButton alloc] init];
    [cancleButton setTitleColor:RGBHex(0xFB1414) forState:UIControlStateNormal];
    [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancleButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [self.imageresizerView addSubview:cancleButton];
    [cancleButton addTarget:self action:@selector(cancleButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imageresizerView.mas_left).offset(32);
        make.top.mas_equalTo(line.mas_bottom).offset(16);
    }];
    self.cancleButton = cancleButton;
    
    UIButton *sureButton = [[UIButton alloc] init];
    [sureButton setTitleColor:RGBHex(0x5079D9) forState:UIControlStateNormal];
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [self.imageresizerView addSubview:sureButton];
    [sureButton addTarget:self action:@selector(sureButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.imageresizerView.mas_right).offset(-32);
        make.top.mas_equalTo(line.mas_bottom).offset(16);
    }];
    self.sureButton = sureButton;
}

#pragma mark - ================ 红心喜欢按钮 ================

- (IBAction)loveButtonClick:(id)sender {
    self.loveButton.selected = !self.loveButton.selected;
}

#pragma mark - ================ 风格编辑 ================

- (IBAction)albumStyle:(id)sender forEvent:(UIEvent *)event {
    UIView *coverView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
    [[UIApplication sharedApplication].keyWindow addSubview:coverView];
    coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    self.styleCoverView = coverView;
    
    UIButton *button = [[UIButton alloc] initWithFrame:coverView.frame];
    [self.styleCoverView addSubview:button];
    [button addTarget:self action:@selector(tapCoverView) forControlEvents:UIControlEventTouchUpInside];
    
    UITouch* touch = [[event touchesForView:self.styleButton] anyObject];
    self.styleViewPoint = [touch locationInView:[UIApplication sharedApplication].keyWindow];
    [self.styleCoverView addSubview:self.styleView];
}

- (void)tapCoverView {
    [self.styleCoverView removeAllSubviews];
    [self.styleCoverView removeFromSuperview];
}


#pragma mark - =================== 取消图片选择 ===================

- (void)cancleButtonClick {
    [self.imageresizerView removeFromSuperview];
}

#pragma mark - =================== 确定选择的图片 ===================

- (void)sureButtonClick {
    [self.imageresizerView removeFromSuperview];
    kWeakSelf(self);
    [self.imageresizerView originImageresizerWithComplete:^(UIImage *resizeImage) {
        [weakself.albumButton setImage:resizeImage forState:UIControlStateNormal];
    }];
}

#pragma mark - ================ 时长 ================

- (IBAction)albumTimeButtonClick:(id)sender {
    QFTimePickerView *pickerView = [[QFTimePickerView alloc] initDatePackerWithStartHour:@"0" endHour:@"24" period:1 response:^(NSString *str) {
        self.timeTextField.text = str;
    }];
    [pickerView show];
}


#pragma mark - =================== 添加曲目详细信息 ===================

- (IBAction)addDetailButtonClick:(id)sender {
    [self.detailDataArray addObject:@"1"];
    [self.albumTableView reloadSection:1 withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - =================== 删除曲目详细信息 ===================

- (void)deleteButtonClick:(LTAlbumTableViewCell *)cell {
    NSIndexPath *index = [self.albumTableView indexPathForCell:cell];
    [self.detailDataArray removeObjectAtIndex:index.row];
    [self.albumTableView reloadSection:1 withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (LTAlbumStyleView *)styleView {
    if (!_styleView) {
        LTAlbumStyleView *albumView = [[LTAlbumStyleView alloc] initWithFrame:CGRectMake(self.styleViewPoint.x - 145, self.styleViewPoint.y + 5, 170, 250)];
        _styleView = albumView;
    }
    return _styleView;
}

- (NSMutableArray *)detailDataArray {
    if (!_detailDataArray) {
        _detailDataArray = [NSMutableArray array];
    }
    return _detailDataArray;
}


@end
