//
//  AlbumCounterLabel.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/23.
//

#import "AlbumCounterLabel.h"

@implementation AlbumCounterLabel

- (CGSize)intrinsicContentSize{
    
    return CGSizeMake([super intrinsicContentSize].width + 25, [super intrinsicContentSize].height + 7);
}

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.layer.cornerRadius = CGRectGetHeight(self.frame) * 0.5;
    self.clipsToBounds = YES;
}

- (void)drawTextInRect:(CGRect)rect{
    [super drawTextInRect:CGRectInset(rect, 10, 2.5)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
