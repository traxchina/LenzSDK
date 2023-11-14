//
//  PCSRoundButton.m
//  sampleSDK
//
//  Created by 王昭威 on 2023/1/14.
//

#import "PCSRoundButton.h"
#import <Masonry/Masonry.h>

@implementation PCSRoundButton

- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.titleLabel.alpha = 0;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect bounds = self.layer.bounds;
    bounds.size.height = bounds.size.width;
    self.layer.bounds = bounds;
    self.layer.cornerRadius = CGRectGetHeight(self.bounds) * 0.5;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer

{

 return YES;

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
