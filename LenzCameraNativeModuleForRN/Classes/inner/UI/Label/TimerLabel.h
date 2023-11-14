//
//  TimerLabel.h
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/31.
//

#import <UIKit/UIKit.h>
#import "PaddingLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimerLabel : PaddingLabel

- (void)updateWith: (NSInteger)seconds;

@end

NS_ASSUME_NONNULL_END
