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
#import "QFDatePickerView.h"
#import "LTAlbumTimePIckerView.h"
#import "LTAddAlbumDetailModel.h"

@interface LTAlbumTableViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, LTAlbumTableViewCellDelegate, UIPickerViewDelegate, LTAlbumTimePickerDelegate>
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

@property (nonatomic, weak) LTAlbumStyleView *styleView;
@property (nonatomic, strong) UIButton *cancleButton;
@property (nonatomic, strong) UIButton *sureButton;
@property (nonatomic, strong) JPImageresizerView *imageresizerView;
@property (nonatomic, strong) LTAlbumStyleView *albumStyleView;
@property (nonatomic, assign) CGPoint styleViewPoint;
@property (nonatomic, strong) UIView *styleCoverView;
@property (nonatomic, strong) NSMutableArray *detailDataArray; // 曲目详细信息
@property (nonatomic, strong) LTAlbumTimePIckerView *timePicker;
@property (nonatomic, copy) NSString *listeningTimeString;
@property (nonatomic, copy) NSString *releaseTimeString;
@property (nonatomic, assign) BOOL isListeningTime;
@property (nonatomic, strong) LTAddAlbumDetailModel *detailModel;
@property (nonatomic, copy) NSString *imageId; // 上传图片拿到的后台的id

- (IBAction)albumButtonClick:(id)sender; // 专辑封面
- (IBAction)loveButtonClick:(id)sender; // 喜欢
- (IBAction)albumStyle:(id)sender forEvent:(UIEvent *)event; // 风格
- (IBAction)albumTimeButtonClick:(id)sender; // 专辑时长
- (IBAction)listeningTime:(id)sender; // 聆听时间
- (IBAction)releaseTime:(id)sender; // 发布时间
- (IBAction)releaseCount:(id)sender; // 发布数量
- (IBAction)addDetailButtonClick:(id)sender;

@end

@implementation LTAlbumTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatAllViews];
    if (self.albumId.length) {
        [self requestData];
    }
}

- (void)creatAllViews {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backItem;
    //将返回按钮的文字position设置不在屏幕上显示
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, NSIntegerMin) forBarMetrics:UIBarMetricsDefault];
    
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

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)requestData {
    [LTNetworking requestUrl:@"/album/info" WithParam:@{@"album_id" : self.albumId} withMethod:GET success:^(id  _Nonnull result) {
        if ([result[@"code"] intValue] == 0) {
            [self handleDate:result];
        }
        else {
            [MBProgressHUD showInfoMessage:result[@"msg"]];
        }
    } failure:^(NSError * _Nonnull erro) {
        [MBProgressHUD showInfoMessage:@"网络连接失败，请稍后重试"];
    } showHUD:self.view];
}

- (void)handleDate:(id)result {
    [self.detailDataArray removeAllObjects];
    NSString *infoString = result[@"data"][@"tracks_info"];
    NSArray *array = [NSMutableArray arrayWithArray:[infoString componentsSeparatedByString:@"|"]];
    for (int i = 0; i < array.count; i ++) {
        NSArray *valueArray = [NSMutableArray arrayWithArray:[array[i] componentsSeparatedByString:@","]];
        LTAddAlbumDetailModel *model = [[LTAddAlbumDetailModel alloc] init];
        if (valueArray.count == 5) {
            model.album_tracks = valueArray[0];
            model.album_composer = valueArray[1];
            model.album_lyricist = valueArray[2];
            model.album_player = valueArray[3];
            model.album_arranger = valueArray[4];
            if (model.album_tracks.length || model.album_composer.length || model.album_lyricist.length || model.album_player.length || model.album_arranger.length) {
                [self.detailDataArray addObject:model];
            }
        }
    }
    if (self.detailDataArray.count) {
        [self.albumTableView reloadData];
    }
    [self.albumButton setImageWithURL:result[@"data"][@"album_img"] forState:UIControlStateNormal options:YYWebImageOptionUseNSURLCache];
    if ([result[@"data"][@"favorite"] intValue] == 1 ) {
        self.loveButton.selected = YES;
    }
    self.albumNameTextField.text = result[@"data"][@"album_name"];
    self.musicianTextField.text = result[@"data"][@"album_musician"];
    self.styleTextField.text = result[@"data"][@"album_style"];
    self.albumNameTextField.text = result[@"data"][@"album_name"];
    NSString *durationString = result[@"data"][@"album_duration"];
    if (durationString != nil && [durationString class] != [NSNull class]) {
        self.timeTextField.text = result[@"data"][@"album_duration"];
    }
    self.listeningTimeTextField.text = result[@"data"][@"listen_time"];
    NSString *releaseTimeString = result[@"data"][@"album_release_time"];
    if (releaseTimeString != nil && [releaseTimeString class] != [NSNull class]) {
        self.releasedTimeTextField.text = result[@"data"][@"album_release_time"];
    }
    NSString *quantityString = result[@"data"][@"song_quantity"];
    if (quantityString != nil  && [quantityString class] != [NSNull class]) {
        self.releasedCountTextField.text = result[@"data"][@"song_quantity"];
    }
    NSString *producerString = result[@"data"][@"album_producer"];
    if (producerString != nil && [producerString class] != [NSNull class]) {
        self.producerTextField.text = result[@"data"][@"album_producer"];
    }
    NSString *engineerString = result[@"data"][@"sound_engineer"];
    if (engineerString != nil && [engineerString class] != [NSNull class]) {
        self.mixerTextField.text = result[@"data"][@"sound_engineer"];
    }
    NSString *mixerString = result[@"data"][@"sound_mixer"];
    if (mixerString != nil && [mixerString class] != [NSNull class]) {
        self.mixingTextField.text = result[@"data"][@"sound_mixer"];
    }
    NSString *maxsAngineerString = result[@"data"][@"mastering_engineer"];
    if (maxsAngineerString != nil && [maxsAngineerString class] != [NSNull class]) {
        self.masteringTextField.text = result[@"data"][@"mastering_engineer"];
    }
    NSString *designerString = result[@"data"][@"cover_designer"];
    if (designerString != nil && [designerString class] != [NSNull class]) {
        self.coverTextField.text = result[@"data"][@"cover_designer"];
    }
}

#pragma mark - ================ 保存专辑信息 ================

- (void)saveButtonClick {
    if (!self.imageId.length && !self.albumId.length) {
        [MBProgressHUD showInfoMessage:@"请上传专辑封面图"];
        return;
    }
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
    if (!self.listeningTimeTextField.text.length) {
        [MBProgressHUD showInfoMessage:@"请选择聆听时间"];
        return;
    }
    
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    NSString  *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"icloudName"];
    [parameter setObject:userId forKey:@"user_id"];
    [parameter setObject:self.albumNameTextField.text forKey:@"album_name"];
    [parameter setObject:self.musicianTextField.text forKey:@"album_musician"];
    [parameter setObject:self.styleTextField.text forKey:@"album_style"];
    if (self.imageId.length) {
        [parameter setObject:self.imageId forKey:@"album_img"];
    }
    if (self.timeTextField.text.length) {
        [parameter setObject:self.timeTextField.text forKey:@"album_duration"];
    }
    if (self.listeningTimeTextField.text.length) {
        NSMutableString *string = [NSMutableString stringWithString:self.listeningTimeTextField.text];
        string = [NSMutableString stringWithString:[string stringByReplacingOccurrencesOfString:@"年" withString:@"-"]];
        string = [NSMutableString stringWithString:[string stringByReplacingOccurrencesOfString:@"月" withString:@"-"]];
        string = [NSMutableString stringWithString:[string stringByReplacingOccurrencesOfString:@"日" withString:@""]];
        [parameter setObject:string forKey:@"listen_time"];
        
    }
    if (self.releasedTimeTextField.text.length) {
        NSMutableString *string = [NSMutableString stringWithString:self.releasedTimeTextField.text];
        string = [NSMutableString stringWithString:[string stringByReplacingOccurrencesOfString:@"年" withString:@"-"]];
        string = [NSMutableString stringWithString:[string stringByReplacingOccurrencesOfString:@"月" withString:@"-"]];
        string = [NSMutableString stringWithString:[string stringByReplacingOccurrencesOfString:@"日" withString:@""]];
        [parameter setObject:string forKey:@"album_release_time"];
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
    if (self.producerTextField.text.length) {
        [parameter setObject:self.producerTextField.text forKey:@"album_producer"];
    }
    if (self.loveButton.selected) {
        [parameter setObject:@(1) forKey:@"favorite"];
    }
    else {
        [parameter setObject:@(0) forKey:@"favorite"];
    }
    
    // 详细曲目信息
    NSMutableString *mulString = [NSMutableString string];
    for (int i = 0; i < self.detailDataArray.count; i++) {
        self.detailModel = self.detailDataArray[i];
        self.detailModel.album_tracks = self.detailModel.album_tracks.length ? self.detailModel.album_tracks : @"";
        self.detailModel.album_lyricist = self.detailModel.album_lyricist.length ? self.detailModel.album_lyricist : @"";
        self.detailModel.album_composer = self.detailModel.album_composer.length ? self.detailModel.album_composer : @"";
        self.detailModel.album_arranger = self.detailModel.album_arranger.length ? self.detailModel.album_arranger : @"";
        self.detailModel.album_player = self.detailModel.album_player.length ? self.detailModel.album_player : @"";
        
        [mulString appendString:[NSString stringWithFormat:@"%@,",self.detailModel.album_tracks]];
        [mulString appendString:[NSString stringWithFormat:@"%@,",self.detailModel.album_lyricist]];
        [mulString appendString:[NSString stringWithFormat:@"%@,",self.detailModel.album_composer]];
        [mulString appendString:[NSString stringWithFormat:@"%@,",self.detailModel.album_arranger]];
        if (i == self.detailDataArray.count - 1) {
            [mulString appendString:[NSString stringWithFormat:@"%@",self.detailModel.album_player]];
        }
        else {
            [mulString appendString:[NSString stringWithFormat:@"%@|",self.detailModel.album_player]];
        }
    }
    [parameter setObject:mulString forKey:@"tracks_info"];
    
    NSString *url;
    if (self.albumId.length) {
        url = @"/album/update";
        [parameter setObject:self.albumId forKey:@"album_id"];
    }
    else {
        url = @"/album/add";
    }
    
    [LTNetworking requestUrl:url WithParam:parameter withMethod:POST success:^(id  _Nonnull result) {
        if ([result[@"code"] intValue] == 0) {
            [MBProgressHUD showInfoMessage:result[@"msg"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AddAlbumSucess" object:nil];
            [self.navigationController popViewControllerAnimated:YES];
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
        self.detailModel = self.detailDataArray[indexPath.row];
        LTAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LTAlbumTableViewCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = CViewBgColor;
        cell.delegate = self;
        cell.model = self.detailModel;
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

#pragma mark - ================ 详细曲目信息文本编辑 delegate ================

- (void)detailCellTextChange:(LTAlbumTableViewCell *)cell string:(NSString *)string index:(NSInteger)index {NSIndexPath *indexPath = [self.albumTableView indexPathForCell:cell];
    self.detailModel = self.detailDataArray[indexPath.row];
    if (index == 0) {
        self.detailModel.album_tracks = string;
    }
    else if (index == 1) {
        self.detailModel.album_lyricist = string;
    }
    else if (index == 2) {
        self.detailModel.album_composer = string;
    }
    else if (index == 3) {
        self.detailModel.album_arranger = string;
    }
    else if (index == 4) {
        self.detailModel.album_player = string;
    }
    [self.detailDataArray replaceObjectAtIndex:indexPath.row withObject:self.detailModel];
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

#pragma mark - =================== 上传选择的图片 ===================

- (void)sureButtonClick {
    [self.imageresizerView removeFromSuperview];
    kWeakSelf(self);
    [self.imageresizerView originImageresizerWithComplete:^(UIImage *resizeImage) {
        NSData *imageData = UIImageJPEGRepresentation(resizeImage, 0.5f);
        NSMutableDictionary *Exparams = [[NSMutableDictionary alloc]init];
        [Exparams addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:imageData,@"file", nil]];
        [LTNetworking uploadImageWithUrl:@"/img/upload" WithParam:[NSDictionary dictionary] withExParam:Exparams withMethod:POST success:^(id  _Nonnull result) {
            if ([result[@"code"] intValue] == 0) {
                [weakself.albumButton setImage:resizeImage forState:UIControlStateNormal];
                self.imageId = result[@"data"];
            }
            else {
                [MBProgressHUD showErrorMessage:result[@"msg"]];
            }
        } uploadFileProgress:^(NSProgress * _Nonnull uploadProgress) {
            
        } failure:^(NSError * _Nonnull erro) {
            [MBProgressHUD showInfoMessage:@"网络连接失败，请稍后重试"];
        }];
    }];
}

#pragma mark - =================== 添加曲目详细信息 ===================

- (IBAction)addDetailButtonClick:(id)sender {
    if (self.detailDataArray.count == 12) {
        [MBProgressHUD showErrorMessage:@"最多仅支持12个曲信息卡片"];
        return;
    }
    LTAddAlbumDetailModel *model = [[LTAddAlbumDetailModel alloc] init];
    [self.detailDataArray addObject:model];
    [self.albumTableView reloadSection:1 withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - =================== 删除曲目详细信息 ===================

- (void)deleteButtonClick:(LTAlbumTableViewCell *)cell {
    NSIndexPath *index = [self.albumTableView indexPathForCell:cell];
    [self.detailDataArray removeObjectAtIndex:index.row];
    [self.albumTableView reloadSection:1 withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - ================ 时长 ================

- (IBAction)albumTimeButtonClick:(id)sender {
    QFTimePickerView *pickerView = [[QFTimePickerView alloc] initDatePackerWithStartHour:@"0" endHour:@"24" period:1 response:^(NSString *str) {
        self.timeTextField.text = str;
    }];
    [pickerView show];
}

#pragma mark - ================ 聆听时间 ================

- (IBAction)listeningTime:(id)sender {
    self.isListeningTime = YES;
    [[UIApplication sharedApplication].delegate.window addSubview:self.timePicker];
}

#pragma mark - ================ 发布时间 ================

- (IBAction)releaseTime:(id)sender {
    self.isListeningTime = NO;
    [[UIApplication sharedApplication].delegate.window addSubview:self.timePicker];
}

#pragma mark - ================ 聆听、发行时间代理 ================

- (void)timePickerSureButtonClick {
    if (self.isListeningTime) {
        self.listeningTimeTextField.text = self.listeningTimeString;
    }
    else {
        self.releasedTimeTextField.text = self.releaseTimeString;
    }
    [self.timePicker removeFromSuperview];
}

#pragma mark - ================ timePicker delegate ================

- (void)dateChanged:(UIDatePicker *)picker{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    if (self.isListeningTime) {
        self.listeningTimeString = [formatter stringFromDate:picker.date];
    }
    else {
        self.releaseTimeString = [formatter stringFromDate:picker.date];
    }
}

#pragma mark - ================ 发布数量 ================

- (IBAction)releaseCount:(id)sender {
    QFDatePickerView *datePickerView = [[QFDatePickerView alloc]initYearPickerWithView:self.view response:^(NSString *str) {
        self.releasedCountTextField.text = str;
    }];
    [datePickerView show];
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

- (LTAlbumTimePIckerView *)timePicker {
    if (!_timePicker) {
        _timePicker = [LTAlbumTimePIckerView creatXib];
        _timePicker.delegate = self;
        [_timePicker.timePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _timePicker;
}

@end
