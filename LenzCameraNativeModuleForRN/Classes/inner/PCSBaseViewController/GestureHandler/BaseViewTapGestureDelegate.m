//
//  BaseViewTapGestureDelegate.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/30.
//
#import "PCSBaseViewController.h"
#import "BaseViewTapGestureDelegate.h"

@implementation BaseViewTapGestureDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint pt = [gestureRecognizer locationInView:self.controller.controlPanelBackground];
    return !CGRectContainsPoint(self.controller.controlPanelBackground.bounds, pt);
}

@end
