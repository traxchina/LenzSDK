//
//  VerticalButton.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/23.
//

#import "VerticalButton.h"

@implementation VerticalButton

- (CGSize)intrinsicContentSize{
    CGSize newSize;
    newSize.width = MAX(CGRectGetWidth(self.imageView.frame), CGRectGetWidth(self.titleLabel.frame));
    newSize.height = CGRectGetHeight(self.imageView.frame) + CGRectGetHeight(self.titleLabel.frame);
    return newSize;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
