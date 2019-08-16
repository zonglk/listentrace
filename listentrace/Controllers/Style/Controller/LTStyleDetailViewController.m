//
//  LTStyleDetailViewController.m
//  listentrace
//
//  Created by 宗丽康 on 2019/7/29.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTStyleDetailViewController.h"
#import "LTStyleDetailCollectionViewCell.h"
#import "LTStyleDetailFlowLayout.h"

@interface LTStyleDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation LTStyleDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatAllViews];
}

- (void)creatAllViews {
    self.title = self.navTitle;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    double itemWidth = (KScreenWidth - 40)/3;
    [flowLayout setItemSize:CGSizeMake(itemWidth, itemWidth + 20)];
    [flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 0, 10)];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight) collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"LTStyleDetailCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"LTStyleDetailCollectionViewCell"];
    self.collectionView.backgroundColor = CViewBgColor;
    [self.view addSubview:self.collectionView];
}

#pragma mark - =================== UICollectionView delegate 、 dataSource ===================
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 40;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LTStyleDetailCollectionViewCell *celll = [collectionView dequeueReusableCellWithReuseIdentifier:@"LTStyleDetailCollectionViewCell" forIndexPath:indexPath];
    return celll;
}

@end
