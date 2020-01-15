//
//  LTAlbumTimePIckerView.h
//  listentrace
//
//  Created by luojie on 2019/9/5.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LTAlbumTimePickerDelegate <NSObject>

- (void)timePickerSureButtonClick;

@end

NS_ASSUME_NONNULL_BEGIN

@interface LTAlbumTimePIckerView : UIView
- (IBAction)cancleButtonClick:(id)sender;
- (IBAction)sureButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (nonatomic, weak) id <LTAlbumTimePickerDelegate> delegate;

+ (instancetype)creatXib;

@end

NS_ASSUME_NONNULL_END
