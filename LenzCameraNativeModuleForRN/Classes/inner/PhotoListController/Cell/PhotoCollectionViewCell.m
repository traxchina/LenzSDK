//
//  PhotoCollectionViewCell.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/22.
//

#import "PhotoCollectionViewCell.h"
#import "PhotoListCellModel.h"

@implementation PhotoCollectionViewCell

- (void)setCellModel:(PhotoListCellModel *)cellModel{
    self.imageView.image = cellModel.image;
    _cellModel = cellModel;
}

- (UIView *)coverView{
    return self.imageView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(15, 15, CGRectGetWidth(self.bounds) - 30, CGRectGetHeight(self.bounds) - 30);
}

@end
