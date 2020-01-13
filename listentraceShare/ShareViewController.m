//
//  ShareViewController.m
//  listentraceShare
//
//  Created by luojie on 2020/1/13.
//  Copyright © 2020 listentrace. All rights reserved.
//

#import "ShareViewController.h"

@interface ShareViewController ()

@property (copy, nonatomic) NSString *linkUrl;

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
//    __block BOOL hasExistsUrl = NO;
//    [self.extensionContext.inputItems enumerateObjectsUsingBlock:^(NSExtensionItem * _Nonnull extItem, NSUInteger idx, BOOL * _Nonnull stop) {
//
//        [extItem.attachments enumerateObjectsUsingBlock:^(NSItemProvider * _Nonnull itemProvider, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([itemProvider hasItemConformingToTypeIdentifier:@"public.url"]) {
//                [itemProvider loadItemForTypeIdentifier:@"public.url"
//                                                options:nil
//                                      completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
//                                          if ([(NSObject *)item isKindOfClass:[NSURL class]]) {
//                                              self.linkUrl = [NSString stringWithFormat:@"%@",item];
//                                          }
//                                      }];
//                hasExistsUrl = YES;
//                *stop = YES;
//            }
//        }];
//        if (hasExistsUrl)  {
//            *stop = YES;
//        }
//    }];
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
//    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
