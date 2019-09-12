//
//  LTAddAlbumDetailModel.h
//  listentrace
//
//  Created by luojie on 2019/9/12.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LTAddAlbumDetailModel : NSObject

/*
 [{"album_tracks":"111","album_lyricist":"222","album_composer":"333","album_arranger":"444","album_player":"555"},{"album_tracks":"111","album_lyricist":"222","album_composer":"333","album_arranger":"444","album_player":"555"},{"album_tracks":"111","album_lyricist":"222","album_composer":"333","album_arranger":"444","album_player":"555"}]
 */

@property (nonatomic, copy) NSString *album_tracks; // 曲目
@property (nonatomic, copy) NSString *album_lyricist; // 作词人
@property (nonatomic, copy) NSString *album_composer; // 作曲人
@property (nonatomic, copy) NSString *album_arranger; // 编曲人
@property (nonatomic, copy) NSString *album_player; // 乐器演奏者

@end

NS_ASSUME_NONNULL_END
