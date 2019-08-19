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

@interface LTAlbumTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *albumTableView;
@property (weak, nonatomic) IBOutlet UILabel *tipsImageLabel;
@property (weak, nonatomic) IBOutlet UIButton *albumButton;
@property (weak, nonatomic) IBOutlet UIButton *loveButton; // 红心
@property (weak, nonatomic) IBOutlet UIButton *styleButton; // 风格
@property (nonatomic, weak) LTAlbumStyleView *styleView;
- (IBAction)albumButtonClick:(id)sender;
- (IBAction)loveButtonClick:(id)sender;
- (IBAction)styleButtonClick:(id)sender;

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
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LTAlbumTableViewCell" bundle:nil] forCellReuseIdentifier:@"LTAlbumTableViewCell"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark 键盘出现
-(void)keyboardWillShow:(NSNotification *)note {
    CGRect keyBoardRect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, keyBoardRect.size.height, 0);
}
#pragma mark 键盘消失
-(void)keyboardWillHide:(NSNotification *)note {
    self.tableView.contentInset = UIEdgeInsetsZero;
}

#pragma mark - ================ 保存专辑信息 ================

- (void)saveButtonClick {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return 1;
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        LTAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LTAlbumTableViewCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = CViewBgColor;
        return cell;
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return 260;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
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
                    [self showAlbum];
                }
                else {
                    [MBProgressHUD showErrorMessage:@"请先打开相册访问权限，否则您无法使用上传专辑图片功能"];
                }
            }];
        }
        else if (status == AVAuthorizationStatusAuthorized) {
            [self showAlbum];
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
    
}

#pragma mark - ================ 红心喜欢按钮 ================

- (IBAction)loveButtonClick:(id)sender {
    self.loveButton.selected = !self.loveButton.selected;
}

#pragma mark - ================ 风格编辑 ================

- (IBAction)styleButtonClick:(id)sender {
   
}

- (LTAlbumStyleView *)styleView {
    if (!_styleView) {
        LTAlbumStyleView *albumView = [LTAlbumStyleView creatStyleView];
        [self.tableView addSubview:albumView];
        _styleView = albumView;
    }
    return _styleView;
}

@end
