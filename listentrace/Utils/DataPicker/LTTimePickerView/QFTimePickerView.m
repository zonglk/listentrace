//
//  QFTimePickerView.m
//  QFDatePickerView
//
//  Created by iosyf-02 on 2017/11/14.
//  Copyright © 2017年 情风. All rights reserved.
//

#import "QFTimePickerView.h"

@interface QFTimePickerView () <UIPickerViewDataSource,UIPickerViewDelegate>{
    UIView *contentView;
    void(^backBlock)(NSString *);
    
    NSMutableArray *hourArray;
    NSMutableArray *minArray;
    NSMutableArray *secArray;
    NSInteger currentHour;
    NSInteger currentMin;
    NSInteger currentSec;
    NSString *restr;
    
    NSString *selectedHour;
    NSString *selectedMin;
    NSString *selectedSec;
}

@property (nonatomic, assign) NSString *startTime;
@property (nonatomic, assign) NSString *endTime;
@property (nonatomic, assign) NSInteger period;
@property (nonatomic, copy) NSString *timeString;

@end

@implementation QFTimePickerView

/**
 初始化方法
 
 @param startHour 其实时间点 时
 @param endHour 结束时间点 时
 @param period 间隔多少分中
 @param block 返回选中的时间
 @return QFTimePickerView实例
 */
- (instancetype)initDatePackerWithStartHour:(NSString *)startHour endHour:(NSString *)endHour period:(NSInteger)period timeString:(NSString *)timeString response:(void (^)(NSString *))block {
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
    }
    _startTime = startHour;
    _endTime = endHour;
    _period = period;
    _timeString = timeString;
    
    [self initDataSource];
    [self initAppreaence];
    
    if (block) {
        backBlock = block;
    }
    return self;
}

#pragma mark - initDataSource
- (void)initDataSource {
    
    [self configHourArray];
    [self configMinArray];
    [self configSecArray];
    
    selectedHour = hourArray[0];
    selectedMin = minArray[0];
    selectedSec = secArray[0];
}

- (void)configHourArray {//配置小时数据源数组
    //初始化小时数据源数组
    hourArray = [[NSMutableArray alloc]init];
    
    NSString *startHour = [_startTime substringWithRange:NSMakeRange(0, 1)];
    NSString *endHour = [_endTime substringWithRange:NSMakeRange(0, 2)];
    
    if ([startHour integerValue] > [endHour integerValue]) {//跨天
        NSString *minStr = @"";
        for (NSInteger i = [startHour integerValue]; i < 24; i++) {//加当天的小时数
            if (i < 10) {
                minStr = [NSString stringWithFormat:@"0%ld",i];
            } else {
                minStr = [NSString stringWithFormat:@"%ld",i];
            }
            [hourArray addObject:minStr];
        }
        for (NSInteger i = 0; i <= [endHour integerValue]; i++) {//加次天的小时数
            if (i < 10) {
                minStr = [NSString stringWithFormat:@"0%ld",i];
            } else {
                minStr = [NSString stringWithFormat:@"%ld",i];
            }
            [hourArray addObject:minStr];
        }
        
    } else {
        for (NSInteger i = [startHour integerValue]; i < [endHour integerValue]; i++) {//加小时数
            NSString *minStr = @"";
            if (i < 10) {
                minStr = [NSString stringWithFormat:@"0%ld",i];
            } else {
                minStr = [NSString stringWithFormat:@"%ld",i];
            }
            [hourArray addObject:minStr];
        }
    }
    
}

- (void)configMinArray {//配置分钟数据源数组
    minArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 1 ; i <= 60; i++) {
        NSString *minStr = @"";
        if (i % _period == 0) {
            if (i < 10) {
                minStr = [NSString stringWithFormat:@"0%ld",(long)i];
            } else {
                minStr = [NSString stringWithFormat:@"%ld",(long)i];
            }
            [minArray addObject:minStr];
        }
    }
    [minArray insertObject:@"00" atIndex:0];
    [minArray removeLastObject];
}

- (void)configSecArray {//配置秒数据源数组
    secArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 1 ; i <= 60; i++) {
        NSString *minStr = @"";
        if (i % _period == 0) {
            if (i < 10) {
                minStr = [NSString stringWithFormat:@"0%ld",(long)i];
            } else {
                minStr = [NSString stringWithFormat:@"%ld",(long)i];
            }
            [secArray addObject:minStr];
        }
    }
    [secArray insertObject:@"00" atIndex:0];
    [secArray removeLastObject];
}

#pragma mark - initAppreaence
- (void)initAppreaence {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, self.frame.size.height)];
    [button addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 300)];
    [self addSubview:contentView];
    //设置背景颜色为黑色，并有0.4的透明度
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    //添加白色view
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [contentView addSubview:whiteView];
    //添加确定和取消按钮
    for (int i = 0; i < 2; i ++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width - 60) * i, 0, 60, 40)];
        [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [button setTitle:i == 0 ? @"取消" : @"确定" forState:UIControlStateNormal];
        if (i == 0) {
            [button setTitleColor:RGBHex(0x8F8F8F) forState:UIControlStateNormal];
        } else {
            [button setTitleColor:RGBHex(0x007AFF) forState:UIControlStateNormal];
        }
        [whiteView addSubview:button];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 10 + i;
    }
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, CGRectGetWidth(self.bounds), 260)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.backgroundColor = [UIColor whiteColor];
    
    
    //设置pickerView默认第一行 这里也可默认选中其他行 修改selectRow即可
    if (_timeString.length) {
        NSArray *array = [_timeString componentsSeparatedByString:@":"];
        selectedHour = hourArray[[array[0] intValue]];
        selectedMin = minArray[[array[1] intValue]];
        selectedSec = secArray[[array[2] intValue]];
        [pickerView selectRow:[array[0] intValue] inComponent:0 animated:YES];
        [pickerView selectRow:[array[1] intValue] inComponent:1 animated:YES];
        [pickerView selectRow:[array[2] intValue] inComponent:2 animated:YES];
    }
    else {
        [pickerView selectRow:0 inComponent:0 animated:YES];
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [pickerView selectRow:0 inComponent:2 animated:YES];
    }
    
    [contentView addSubview:pickerView];
}

#pragma mark - Actions
- (void)buttonTapped:(UIButton *)sender {
    if (sender.tag == 10) {
        [self dismiss];
    }
    else {
        if ([selectedMin isEqualToString:@"00"] && [selectedHour isEqualToString:@"00"] && [selectedSec isEqualToString:@"00"]) {
            [MBProgressHUD showErrorMessage:@"请选择正确的时间"];
            return;
        }
        restr = [NSString stringWithFormat:@"%@:%@:%@",selectedHour,selectedMin,selectedSec];
        backBlock(restr);
        [self dismiss];
    }
}

#pragma mark - pickerView出现
- (void)show {
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.4 animations:^{
        self->contentView.center = CGPointMake(self.frame.size.width/2, self->contentView.center.y - self->contentView.frame.size.height);
    }];
}

#pragma mark - pickerView消失
- (void)dismiss{
    
    [UIView animateWithDuration:0.4 animations:^{
        self->contentView.center = CGPointMake(self.frame.size.width/2, self->contentView.center.y + self->contentView.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UIPickerViewDataSource UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return hourArray.count;
    }
    else if (component == 1) {
        return minArray.count;
    }
    else {
        return secArray.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return hourArray[row];
    }
    else if (component == 1) {
        return minArray[row];
    }
    else {
        return secArray[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        selectedHour = hourArray[row];
        if ([selectedHour isEqualToString:[hourArray lastObject]]) {
            [pickerView selectRow:0 inComponent:1 animated:YES];
            selectedMin = @"00";
        }
        [pickerView reloadComponent:1];
    }
    else if (component == 1) {
        if ([selectedHour isEqualToString:[minArray lastObject]]) {
            [pickerView selectRow:0 inComponent:1 animated:YES];
            selectedMin = @"00";
        }
        else {
            selectedMin = minArray[row];
        }
    }
    else {
        if ([selectedSec isEqualToString:[minArray lastObject]]) {
            [pickerView selectRow:0 inComponent:1 animated:YES];
            selectedSec = @"00";
        }
        else {
            selectedSec = secArray[row];
        }
    }
}

@end
