//
//  PhotoCell.m
//  LenzCameraNativeModuleForRN
//
//  Created by 伯爵 on 2023/2/6.
//

#import "PhotoCell.h"

@implementation PhotoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.imgView.frame = CGRectMake(15, 15, CGRectGetWidth(self.bounds) - 30, CGRectGetHeight(self.bounds) - 30);
}



@end
