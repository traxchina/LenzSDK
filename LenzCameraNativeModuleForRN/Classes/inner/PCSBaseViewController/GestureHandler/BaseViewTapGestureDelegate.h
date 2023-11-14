//
//  BaseViewTapGestureDelegate.h
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PCSBaseViewController;
@interface BaseViewTapGestureDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) PCSBaseViewController* controller;

@end

NS_ASSUME_NONNULL_END
