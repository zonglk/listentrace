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

@interface LTAlbumTableViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, LTAlbumTableViewCellDelegate, UIPickerViewDelegate, LTAlbumTimePickerDelegate, UITextFieldDelegate>
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
@property (weak, nonatomic) IBOutlet UIButton *addDetailButton;
@property (weak, nonatomic) IBOutlet UIButton *arrowButton; // 指示箭头 （做显隐处理）
@property (weak, nonatomic) IBOutlet UIButton *arrowButton1;
@property (weak, nonatomic) IBOutlet UIButton *arrowButton2;
@property (weak, nonatomic) IBOutlet UIButton *arrowButton3;


@property (weak, nonatomic) IBOutlet UITextField *listeningTimeTextField; // 聆听时间
@property (weak, nonatomic) IBOutlet UITextField *releasedTimeTextField; // 发行时间
@property (weak, nonatomic) IBOutlet UITextField *releasedCountTextField; // 发行数目
@property (weak, nonatomic) IBOutlet UITextField *producerTextField; // 制作人
@property (weak, nonatomic) IBOutlet UITextField *mixerTextField; // 录音师
@property (weak, nonatomic) IBOutlet UITextField *mixingTextField; // 混音师
@property (weak, nonatomic) IBOutlet UITextField *masteringTextField; // 母带工程师
@property (weak, nonatomic) IBOutlet UITextField *coverTextField; // 封面设计师
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UIView *view4;
@property (weak, nonatomic) IBOutlet UIView *view5;
@property (weak, nonatomic) IBOutlet UIView *view6;
@property (weak, nonatomic) IBOutlet UIView *footerView;

@property (nonatomic, weak) LTAlbumStyleView *styleView;
@property (nonatomic, strong) UIButton *cancleButton;
@property (nonatomic, strong) UIButton *sureButton;
@property (nonatomic, strong) JPImageresizerView *imageresizerView;
@property (nonatomic, strong) UIView *styleCoverView;
@property (nonatomic, strong) NSMutableArray *detailDataArray; // 曲目详细信息
@property (nonatomic, strong) LTAlbumTimePIckerView *timePicker;
@property (nonatomic, copy) NSString *listeningTimeString;
@property (nonatomic, copy) NSString *releaseTimeString;
@property (nonatomic, assign) BOOL isListeningTime;
@property (nonatomic, strong) LTAddAlbumDetailModel *detailModel;
@property (nonatomic, copy) NSString *imageId; // 上传图片拿到的后台的id
@property (nonatomic, strong) UIButton *rightNavButton;
@property (nonatomic, assign) BOOL isSave; // 专辑已存在时候的保存
@property (nonatomic, assign) BOOL isChange; // 是否有修改
@property (nonatomic, assign) BOOL isEditImage; // 编辑图片时按钮不可用
@property (nonatomic,strong) LTAlbumTableViewCell *detailCell;

- (IBAction)albumButtonClick:(id)sender; // 专辑封面
- (IBAction)loveButtonClick:(id)sender; // 喜欢
- (IBAction)albumStyle:(id)sender; // 风格
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
        self.tipsImageLabel.hidden = YES;
    }
    else {
        NSDate *date = [NSDate date];
        NSDateFormatter *forMatter = [[NSDateFormatter alloc] init];
        [forMatter setDateFormat:@"yyyy-MM-dd"];
        NSString *dateStr = [forMatter stringFromDate:date];
        self.listeningTimeString = dateStr;
        self.listeningTimeTextField.text = self.listeningTimeString;
    }
}

- (void)creatAllViews {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [backItem setTintColor:RGBHex(0xE6E6E6)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.title = @"专辑信息";
    self.tableView.backgroundColor = CViewBgColor;
    UIButton *rightNavButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    if (self.albumId.length) {
        [rightNavButton setTitle:@"编辑" forState:UIControlStateNormal];
        self.footerView.hidden = YES;
        self.footerView.height = 50;
    }
    else {
        [rightNavButton setTitle:@"保存" forState:UIControlStateNormal];
        self.footerView.hidden = NO;
        self.footerView.height = 100;
    }
    [rightNavButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [rightNavButton setTitleColor:RGBHex(0x007AFF) forState:UIControlStateNormal];
    [rightNavButton addTarget:self action:@selector(saveButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.rightNavButton = rightNavButton;
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightNavButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    [self.albumTableView registerNib:[UINib nibWithNibName:@"LTAlbumTableViewCell" bundle:nil] forCellReuseIdentifier:@"LTAlbumTableViewCell"];
    self.albumTableView.estimatedRowHeight = 0;
    self.albumTableView.estimatedSectionHeaderHeight = 0;
    self.albumTableView.estimatedSectionFooterHeight = 0;
    
    ViewBorderRadius(self.view1, 5, 1, RGBHex(0xE5EAFA));
    ViewBorderRadius(self.view2, 5, 1, RGBHex(0xE5EAFA));
    ViewBorderRadius(self.view3, 5, 1, RGBHex(0xE5EAFA));
    ViewBorderRadius(self.view4, 5, 1, RGBHex(0xE5EAFA));
    ViewBorderRadius(self.view5, 5, 1, RGBHex(0xE5EAFA));
    ViewBorderRadius(self.view6, 5, 1, RGBHex(0xE5EAFA));
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(styleChangeNoti:) name:@"AlbumStyleChangeNoti" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChangeValue:) name:UITextFieldTextDidChangeNotification object:self.albumNameTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChangeValue:) name:UITextFieldTextDidChangeNotification object:self.musicianTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChangeValue:) name:UITextFieldTextDidChangeNotification object:self.styleTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChangeValue:) name:UITextFieldTextDidChangeNotification object:self.producerTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChangeValue:) name:UITextFieldTextDidChangeNotification object:self.mixerTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChangeValue:) name:UITextFieldTextDidChangeNotification object:self.mixingTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChangeValue:) name:UITextFieldTextDidChangeNotification object:self.coverTextField];
}

- (void)textFieldDidChangeValue:(NSNotification *)notification {
    self.isChange = YES;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void )styleChangeNoti:(NSNotification *)noti {
    self.styleTextField.text = [NSString stringWithFormat:@"%@",noti.userInfo[@"style"]];
    self.isChange = YES;
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
        if ([result[@"code"] intValue] == 200) {
            [self handleDate:result];
            [self handleUserEnable];
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
    [self.albumButton setImageWithURL:nil forState:UIControlStateNormal placeholder:nil];
    [self.albumImageView sd_setImageWithURL:result[@"data"][@"album_img"] placeholderImage:[UIImage imageNamed:@"album_detail_placeImage"]];
    if ([result[@"data"][@"favorite"] intValue] == 1) {
        self.loveButton.selected = YES;
    }
    self.albumNameTextField.text = result[@"data"][@"album_name"];
    self.musicianTextField.text = result[@"data"][@"album_musician"];
    self.styleTextField.text = result[@"data"][@"album_style"];
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

#pragma mark 保存专辑信息

- (void)saveButtonClick {
    [self handleKeyBoard];
    NSString *userIdString = [[NSUserDefaults standardUserDefaults] objectForKey:@"icloudName"];
    if (!userIdString.length) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请开启 iCloud 同步\n方可使用完整功能" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"prefs:root"]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root"]];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-Prefs:root"]];
            }
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if ([self.rightNavButton.titleLabel.text isEqualToString:@"编辑"]) {
        [self.rightNavButton setTitle:@"保存" forState:UIControlStateNormal];
        self.footerView.hidden = NO;
        self.footerView.height = 100;
        [self handleUserEnable];
        return;
    }
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
    
    if (!self.isChange) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    NSString  *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"icloudName"];
    [parameter setObject:userId forKey:@"user_id"];
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
    
    if (self.isSave) {
        [parameter setValue:@(YES) forKey:@"repeat"];
    }
    else {
        [parameter setValue:@(NO) forKey:@"repeat"];
    }
    
    [LTNetworking requestUrl:url WithParam:parameter withMethod:POST success:^(id  _Nonnull result) {
        if ([result[@"code"] intValue] == 200) {
            self.isSave = NO;
            UIImageView *tipImageView = [[UIImageView alloc] init];
            [tipImageView setImage:[UIImage imageNamed:self.albumId.length ? @"editAlbum_sucess" : @"addAlbum_sucess"]];
            [[UIApplication sharedApplication].delegate.window addSubview:tipImageView];
            [tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.view.mas_centerX);
                [make.centerY.mas_equalTo(self.view.mas_centerY) setOffset:(-30)];
            }];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AddAlbumSucess" object:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [tipImageView removeFromSuperview];
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
        else if ([result[@"code"] intValue] == 1002) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"已添加过该专辑，是否继续保存。"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.isSave = YES;
                [self saveButtonClick];
            }];
            [alert addAction:action];
            [alert addAction:sureAction];
            [self.navigationController presentViewController:alert animated:YES completion:nil];
        }
        else {
            [MBProgressHUD showInfoMessage:result[@"msg"]];
        }
    } failure:^(NSError * _Nonnull erro) {
            [MBProgressHUD showInfoMessage:@"网络连接失败，请稍后重试"];
    } showHUD:self.view];
}

#pragma mark UITableView Delegate\dataSource

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
        if ([self.rightNavButton.titleLabel.text isEqualToString:@"编辑"]) {
            cell.songTextField.enabled = NO;
            cell.lyricistTextField.enabled = NO;
            cell.composerTextField.enabled = NO;
            cell.arrangerTextField.enabled = NO;
            cell.songPerformerTextField.enabled = NO;
            cell.deleteButton.hidden = YES;
        }
        else {
            cell.songTextField.enabled = YES;
            cell.lyricistTextField.enabled = YES;
            cell.composerTextField.enabled = YES;
            cell.arrangerTextField.enabled = YES;
            cell.songPerformerTextField.enabled = YES;
            cell.deleteButton.hidden = NO;
        }
        cell.songTextField.delegate = self;
        cell.lyricistTextField.delegate = self;
        cell.composerTextField.delegate = self;
        cell.arrangerTextField.delegate = self;
        cell.songPerformerTextField.delegate = self;
        self.detailCell = cell;
        
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

#pragma mark 详细曲目信息文本编辑 delegate

- (void)detailCellTextChange:(LTAlbumTableViewCell *)cell string:(NSString *)string index:(NSInteger)index {
    NSIndexPath *indexPath = [self.albumTableView indexPathForCell:cell];
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
    self.isChange = YES;
}

#pragma mark  添加/修改专辑照片

- (IBAction)albumButtonClick:(id)sender {
    [self handleKeyBoard];
    if ([self.rightNavButton.titleLabel.text isEqualToString:@"编辑"]) {
        return;
    }
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
        [self handleUserEnable];
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
    line.hidden = YES;
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
        make.left.mas_equalTo(self.imageresizerView.mas_left).offset(25);
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
        make.right.mas_equalTo(self.imageresizerView.mas_right).offset(-25);
        make.top.mas_equalTo(line.mas_bottom).offset(16);
    }];
    self.sureButton = sureButton;
}

#pragma mark 红心喜欢按钮

- (IBAction)loveButtonClick:(id)sender {
    if ([self.rightNavButton.titleLabel.text isEqualToString:@"编辑"]) {
        return;
    }
    self.loveButton.selected = !self.loveButton.selected;
    self.isChange = YES;
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
    [self.styleCoverView removeAllSubviews];
    [self.styleCoverView removeFromSuperview];
}

#pragma mark 取消图片选择

- (void)cancleButtonClick {
    [self.imageresizerView removeFromSuperview];
}

#pragma mark 上传选择的图片
- (void)sureButtonClick {
    self.isChange = YES;
    [self.imageresizerView removeFromSuperview];
    kWeakSelf(self);
    [self.imageresizerView originImageresizerWithComplete:^(UIImage *resizeImage) {
        NSData *imageData = UIImageJPEGRepresentation(resizeImage, 0.2f);
        NSMutableDictionary *Exparams = [[NSMutableDictionary alloc]init];
        [Exparams addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:imageData,@"file", nil]];
        [LTNetworking uploadImageWithUrl:@"/img/upload" WithParam:[NSDictionary dictionary] withExParam:Exparams withMethod:POST success:^(id  _Nonnull result) {
            if ([result[@"code"] intValue] == 200) {
                [weakself.albumButton setImage:resizeImage forState:UIControlStateNormal];
                self.imageId = result[@"data"];
                self.tipsImageLabel.hidden = YES;
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

#pragma mark  添加曲目详细信息

- (IBAction)addDetailButtonClick:(id)sender {
    [self handleKeyBoard];
    if (self.detailDataArray.count == 12) {
        [MBProgressHUD showErrorMessage:@"最多仅支持12个曲信息卡片"];
        return;
    }
    LTAddAlbumDetailModel *model = [[LTAddAlbumDetailModel alloc] init];
    [self.detailDataArray addObject:model];
    [self.albumTableView reloadSection:1 withRowAnimation:UITableViewRowAnimationAutomatic];
    self.isChange = YES;
}

#pragma mark  删除曲目详细信息

- (void)deleteButtonClick:(LTAlbumTableViewCell *)cell {
    [self handleKeyBoard];
    NSIndexPath *index = [self.albumTableView indexPathForCell:cell];
    [self.detailDataArray removeObjectAtIndex:index.row];
    [self.albumTableView reloadSection:1 withRowAnimation:UITableViewRowAnimationAutomatic];
    self.isChange = YES;
}

#pragma mark  时长

- (IBAction)albumTimeButtonClick:(id)sender {
    [self handleKeyBoard];
    QFTimePickerView *pickerView = [[QFTimePickerView alloc] initDatePackerWithStartHour:@"0" endHour:@"24" period:1 response:^(NSString *str) {
        self.timeTextField.text = str;
        self.isChange = YES;
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
    [[UIApplication sharedApplication].delegate.window addSubview:self.timePicker];
    self.isChange = YES;
}

#pragma mark 发布时间

- (IBAction)releaseTime:(id)sender {
    [self handleKeyBoard];
    self.isListeningTime = NO;
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSDate *minDate = [fmt dateFromString:@"1902-1-1"];
    self.timePicker.timePicker.minimumDate = minDate;
    [[UIApplication sharedApplication].delegate.window addSubview:self.timePicker];
    self.isChange = YES;
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
    self.isChange = YES;
    [self.timePicker removeFromSuperview];
}

#pragma mark  timePicker delegate

- (void)dateChanged:(UIDatePicker *)picker{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    if (self.isListeningTime) {
        self.listeningTimeString = [formatter stringFromDate:picker.date];
    }
    else {
        self.releaseTimeString = [formatter stringFromDate:picker.date];
    }
    self.isChange = YES;
}

#pragma mark 发布数量

- (IBAction)releaseCount:(id)sender {
    [self handleKeyBoard];
    QFDatePickerView *datePickerView = [[QFDatePickerView alloc] initYearPickerWithView:self.view response:^(NSString *str) {
        if ([str intValue] > 100) {
            str = @"10 首";
        }
        self.isChange = YES;
        self.releasedCountTextField.text = str;
    }];
    [datePickerView show];
}

- (void)handleUserEnable {
    if ([self.rightNavButton.titleLabel.text isEqualToString:@"编辑"] || self.isEditImage) {
        self.albumNameTextField.enabled = NO;
        self.musicianTextField.enabled = NO;
        self.styleButton.enabled = NO;
        self.styleViewButton.hidden = YES;
        self.arrowButton.hidden = YES;
        self.arrowButton1.hidden = YES;
        self.arrowButton2.hidden = YES;
        self.arrowButton3.hidden = YES;
        self.styleTextField.enabled = NO;
        self.timeButton.enabled = NO;
        self.timeTextField.enabled = NO;
        self.listeningTimeTextField.enabled = NO;
        self.releasedTimeTextField.enabled = NO;
        self.releasedCountTextField.enabled = NO;
        self.producerTextField.enabled = NO;
        self.listeningTimeButton.enabled = NO;
        self.releaseButton.enabled = NO;
        self.releaseCountButton.enabled = NO;
        self.mixerTextField.enabled = NO;
        self.mixingTextField.enabled = NO;
        self.masteringTextField.enabled = NO;
        self.coverTextField.enabled = NO;
        self.addDetailButton.enabled = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addAlbumEditEnable" object:nil userInfo:@{@"edit":@"0"}];
    }
    else {
        self.albumNameTextField.enabled = YES;
        self.musicianTextField.enabled = YES;
        self.styleButton.enabled = YES;
        self.styleViewButton.hidden = NO;
        self.arrowButton.hidden = NO;
        self.arrowButton1.hidden = NO;
        self.arrowButton2.hidden = NO;
        self.arrowButton3.hidden = NO;
        self.styleTextField.enabled = YES;
        self.timeButton.enabled = YES;
        self.timeTextField.enabled = YES;
        self.listeningTimeTextField.enabled = YES;
        self.producerTextField.enabled = YES;
        self.listeningTimeButton.enabled = YES;
        self.releaseButton.enabled = YES;
        self.releasedTimeTextField.enabled = YES;
        self.releasedCountTextField.enabled = YES;
        self.releaseCountButton.enabled = YES;
        self.mixerTextField.enabled = YES;
        self.mixingTextField.enabled = YES;
        self.masteringTextField.enabled = YES;
        self.coverTextField.enabled = YES;
        self.addDetailButton.enabled = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addAlbumEditEnable" object:nil userInfo:@{@"edit":@"1"}];
    }
    [self.albumTableView reloadData];
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
    [self.producerTextField resignFirstResponder];
    [self.releasedTimeTextField resignFirstResponder];
    [self.releasedCountTextField resignFirstResponder];
    [self.mixerTextField resignFirstResponder];
    [self.mixingTextField resignFirstResponder];
    [self.masteringTextField resignFirstResponder];
    [self.coverTextField resignFirstResponder];
    [self.detailCell.songTextField resignFirstResponder];
    [self.detailCell.lyricistTextField resignFirstResponder];
    [self.detailCell.composerTextField resignFirstResponder];
    [self.detailCell.arrangerTextField resignFirstResponder];
    [self.detailCell.songPerformerTextField resignFirstResponder];
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
        // 设置显示最大时间（此处为当前时间）
        [_timePicker.timePicker setMaximumDate:[NSDate date]];
        [_timePicker.timePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _timePicker;
}

@end
