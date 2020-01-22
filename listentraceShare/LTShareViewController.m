//
//  LTShareViewController.m
//  listentraceShare
//
//  Created by luojie on 2020/1/14.
//  Copyright © 2020 listentrace. All rights reserved.
//

#import "LTShareViewController.h"
#import "LTAlbumTableViewController.h"

@interface LTShareViewController ()

@end

@implementation LTShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    //获取分享链接
    __block BOOL hasGetUrl = NO;
    [self.extensionContext.inputItems enumerateObjectsUsingBlock:^(NSExtensionItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.attachments enumerateObjectsUsingBlock:^(NSItemProvider *  _Nonnull itemProvider, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([itemProvider hasItemConformingToTypeIdentifier:@"public.url"]) {
                [itemProvider loadItemForTypeIdentifier:@"public.url" options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {

                    if ([(NSObject *)item isKindOfClass:[NSURL class]])  {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIStoryboard *story = [UIStoryboard storyboardWithName:@"LTAlbumTableViewController" bundle:[NSBundle mainBundle]];
                            LTAlbumTableViewController *albumVC = [story instantiateViewControllerWithIdentifier:@"LTAlbumTableViewController"];
                            albumVC.urlString = ((NSURL *)item).absoluteString;
                            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:albumVC];
                            nav.modalPresentationStyle = UIModalPresentationFullScreen;
                            [self presentViewController:nav animated:YES completion:nil];
                        });
                    }
                }];
                hasGetUrl = YES;
                *stop = YES;
            }
            else if ([itemProvider hasItemConformingToTypeIdentifier:@"public.plain-text"]) {
                [itemProvider loadItemForTypeIdentifier:@"public.plain-text" options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {

                    if ([(NSObject *)item isKindOfClass:[NSString class]])  {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIStoryboard *story = [UIStoryboard storyboardWithName:@"LTAlbumTableViewController" bundle:[NSBundle mainBundle]];
                            LTAlbumTableViewController *albumVC = [story instantiateViewControllerWithIdentifier:@"LTAlbumTableViewController"];
                            albumVC.urlString = (NSString *)item;
                            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:albumVC];
                            nav.modalPresentationStyle = UIModalPresentationFullScreen;
                            [self presentViewController:nav animated:YES completion:nil];
                        });
                    }
                }];
                hasGetUrl = YES;
                *stop = YES;
            }
            *stop = hasGetUrl;
        }];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disMisSelf) name:@"DisMisSelf" object:nil];
}

- (void)disMisSelf {
    [self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
