//
//  LTStyleDetailFlowLayout.h
//  listentrace
//
//  Created by 宗丽康 on 2019/7/29.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LTStyleDetailFlowLayout : UICollectionViewFlowLayout

//总列数
@property (nonatomic, assign) NSInteger columnCount;
//列间距
@property (nonatomic, assign) NSInteger columnSpacing;
//行间距
@property (nonatomic, assign) NSInteger rowSpacing;
//section到collectionView的边距
@property (nonatomic, assign) UIEdgeInsets sctionInset;
//保存每一列最大y值的数组
@property (nonatomic, strong) NSMutableDictionary *maxYDic;
//保存每一个item的attributes的数组
@property (nonatomic, strong) NSMutableArray *attributesArray;
//计算item高度的block，将item的高度与indexPath传递给外界
@property (nonatomic,strong) CGFloat(^itemHeightBlock)(CGFloat itemHeight,NSIndexPath *indexPath);
//设置item间距
- (void)setColumnSpacing:(NSInteger)columnSpacing rowSpacing:(NSInteger)rowSepacing sectionInset:(UIEdgeInsets)sectionInset;
//初始化方法
- (instancetype)initWithColumnCount:(NSInteger)columnCount;

@end

NS_ASSUME_NONNULL_END
