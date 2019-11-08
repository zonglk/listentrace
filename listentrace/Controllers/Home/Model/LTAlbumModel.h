//
//  LTAlbumModel.h
//  listentrace
//
//  Created by 宗丽康 on 2019/9/8.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LTAddAlbumDetailModel;

NS_ASSUME_NONNULL_BEGIN

@interface LTAlbumModel : NSObject



/*
 "data": {
 "2019-8": [
 {
 "album_id": 1564924944435,
 "user_id": 0,
 "album_name": "1",
 "album_musician": null,
 "album_style": "1",
 "album_duration": null,
 "listen_time": "2019-08-04T15:51:16.000+0000",
 "album_release_time": null,
 "song_quantity": null,
 "album_producer": null,
 "sound_engineer": null,
 "sound_mixer": null,
 "mastering_engineer": null,
 "cover_designer": null,
 "album_tracks": null,
 "album_lyricist": null,
 "album_composer": null,
 "album_arranger": null,
 "album_player": null,
 "album_img": "1",
 "favorite": 1
 },
 {
 "album_id": 1564924944436,
 "user_id": 0,
 "album_name": "2",
 "album_musician": null,
 "album_style": "2",
 "album_duration": null,
 "listen_time": "2019-08-04T15:36:35.000+0000",
 "album_release_time": null,
 "song_quantity": null,
 "album_producer": null,
 "sound_engineer": null,
 "sound_mixer": null,
 "mastering_engineer": null,
 "cover_designer": null,
 "album_tracks": null,
 "album_lyricist": null,
 "album_composer": null,
 "album_arranger": null,
 "album_player": null,
 "album_img": "1",
 "favorite": 0
 }
 ],
 "2019-7": [
 {
 "album_id": 1564924944438,
 "user_id": 0,
 "album_name": "4",
 "album_musician": null,
 "album_style": "4",
 "album_duration": null,
 "listen_time": "2019-07-23T15:36:35.000+0000",
 "album_release_time": null,
 "song_quantity": null,
 "album_producer": null,
 "sound_engineer": null,
 "sound_mixer": null,
 "mastering_engineer": null,
 "cover_designer": null,
 "album_tracks": null,
 "album_lyricist": null,
 "album_composer": null,
 "album_arranger": null,
 "album_player": null,
 "album_img": "1",
 "favorite": 0
 }
 ]
 
 */

@property (nonatomic, copy) NSString *album_id;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *album_name;
@property (nonatomic, copy) NSString *album_musician;
@property (nonatomic, copy) NSString *album_style;
@property (nonatomic, copy) NSString *album_duration;
@property (nonatomic, copy) NSString *listen_time;
@property (nonatomic, copy) NSString *album_release_time;
@property (nonatomic, copy) NSString *song_quantity;
@property (nonatomic, copy) NSString *album_producer;
@property (nonatomic, copy) NSString *sound_engineer;
@property (nonatomic, copy) NSString *sound_mixer;
@property (nonatomic, copy) NSString *mastering_engineer;
@property (nonatomic, copy) NSString *cover_designer;
@property (nonatomic, strong) NSArray<LTAddAlbumDetailModel *> *tracks_info;
@property (nonatomic, copy) NSString *album_img;
@property (nonatomic, copy) NSString *favorite;

@end

NS_ASSUME_NONNULL_END
