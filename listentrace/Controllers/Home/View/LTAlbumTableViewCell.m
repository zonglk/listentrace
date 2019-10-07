//
//  LTAlbumTableViewCell.m
//  listentrace
//
//  Created by luojie on 2019/8/19.
//  Copyright © 2019 listentrace. All rights reserved.
//

#import "LTAlbumTableViewCell.h"

@implementation LTAlbumTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.songTextField addTarget:self action:@selector(songChangedTextField:) forControlEvents:UIControlEventEditingChanged];
    [self.lyricistTextField addTarget:self action:@selector(lyricistChangedTextField:) forControlEvents:UIControlEventEditingChanged];
    [self.composerTextField addTarget:self action:@selector(composerChangedTextField:) forControlEvents:UIControlEventEditingChanged];
    [self.arrangerTextField addTarget:self action:@selector(arrangerChangedTextField:) forControlEvents:UIControlEventEditingChanged];
    [self.songPerformerTextField addTarget:self action:@selector(songPerformerChangedTextField:) forControlEvents:UIControlEventEditingChanged];
    ViewBorderRadius(self.view1, 5, 1, RGBHex(0xE5EAFA));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteButtonClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(deleteButtonClick:)]) {
        [self.delegate deleteButtonClick:self];
    }
}

-(void)songChangedTextField:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(detailCellTextChange:string:index:)]) {
        [self.delegate detailCellTextChange:self string:textField.text index:0];
    }
}

-(void)lyricistChangedTextField:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(detailCellTextChange:string:index:)]) {
        [self.delegate detailCellTextChange:self string:textField.text index:1];
    }
}

-(void)composerChangedTextField:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(detailCellTextChange:string:index:)]) {
        [self.delegate detailCellTextChange:self string:textField.text index:2];
    }
}

-(void)arrangerChangedTextField:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(detailCellTextChange:string:index:)]) {
        [self.delegate detailCellTextChange:self string:textField.text index:3];
    }
}

-(void)songPerformerChangedTextField:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(detailCellTextChange:string:index:)]) {
        [self.delegate detailCellTextChange:self string:textField.text index:4];
    }
}

- (void)setModel:(LTAddAlbumDetailModel *)model {
    _model = model;
    self.songTextField.text = model.album_tracks;
    self.lyricistTextField.text = model.album_lyricist;
    self.composerTextField.text = model.album_composer;
    self.arrangerTextField.text = model.album_arranger;
    self.songPerformerTextField.text = model.album_player;
}

@end
