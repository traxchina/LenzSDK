//
//  TimerLabel.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/31.
//

#import "TimerLabel.h"

@implementation TimerLabel

- (void)updateWith:(NSInteger)seconds{
    NSInteger hours = seconds / 3600;
    NSInteger minutes = seconds / 60 % 60;
    NSInteger sec = seconds % 60;
    self.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hours, minutes, sec];
    NSLog(@"~~~~~~~~~~~~~~~~~~~~:%@", self.text);
}

@end
