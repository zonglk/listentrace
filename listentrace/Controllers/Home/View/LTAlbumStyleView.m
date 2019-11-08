//
//  LTAlbumStyleView.m
//  listentrace
//
//  Created by luojie on 2019/8/19.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTAlbumStyleView.h"

@interface LTAlbumStyleView ()<UITabBarDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *styleTableView;
@property (nonatomic, strong) NSArray *styleDataArray;

@end

@implementation LTAlbumStyleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"LTAlbumStyleView" owner:self options:nil] lastObject];
        
        self.frame = frame;
        [self cratAllViews];
    }
    return self;
}

- (void)cratAllViews {
    self.styleTableView.separatorColor = RGBHex(0xE5EAFA);
    self.styleTableView.layer.cornerRadius = 8;
    self.styleTableView.clipsToBounds = YES;
    NSArray *array = [[NSArray alloc] initWithObjects:@"Anime & Game",@"Alternative", @"Blues",@"Cantopop",@"Children’s",@"Classical",@"Country",@"Dance",@"Easy Listening",@"Electronic",@"Experimental",@"Folk",@"Hip Hop",@"Indie",@"Jazz",@"J-Pop",@"K-Pop",@"Latin",@"Live",@"Mandopop",@"Metal",@"New Age",@"Pop",@"R&B",@"Reggae",@"Religious",@"Rock",@"Soundtrack",@"Singer/Songwriter",@"World Music",nil];
    self.styleDataArray = array;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.styleDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellId"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.styleDataArray[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = RGBHex(0x545C77);

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AlbumStyleChangeNoti" object:nil userInfo:@{@"style" : self.styleDataArray[indexPath.row]}];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
