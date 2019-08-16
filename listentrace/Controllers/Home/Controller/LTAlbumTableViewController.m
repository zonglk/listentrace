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
#import "IQKeyboardManager.h"

@interface LTAlbumTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *albumTableView;
@property (weak, nonatomic) IBOutlet UILabel *tipsImageLabel;
@property (weak, nonatomic) IBOutlet UIButton *albumButton;
@property (weak, nonatomic) IBOutlet UIButton *loveButton;
- (IBAction)albumButtonClick:(id)sender;
- (IBAction)loveButtonClick:(id)sender;

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
    [rightNavButton setTitleColor:RGBHex(0x007AFF) forState:UIControlStateNormal];
    [rightNavButton addTarget:self action:@selector(saveButtonClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightNavButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [self ]
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager]setKeyboardDistanceFromTextField:100000];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager]setKeyboardDistanceFromTextField:10];
}

#pragma mark - ================ 保存专辑信息 ================

- (void)saveButtonClick {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 11;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 1;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
     Configure the cell...
 
    return cell;
}
*/

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


- (IBAction)loveButtonClick:(id)sender {
}
@end
