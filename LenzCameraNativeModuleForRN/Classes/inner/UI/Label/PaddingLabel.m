//
//  PaddingLabel.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/31.
//

#import "PaddingLabel.h"

@implementation PaddingLabel

- (void)setPadding:(UIEdgeInsets)padding{
    _padding = padding;
    [self invalidateIntrinsicContentSize];
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    _padding = UIEdgeInsetsMake(10, 2.5, 10, 2.5);
    
    self.textAlignment = NSTextAlignmentCenter;
}

- (void)drawTextInRect:(CGRect)rect{
    [super drawTextInRect:CGRectInset(rect, self.padding.left + self.padding.right, self.padding.top + self.padding.bottom)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
