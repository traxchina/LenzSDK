//
//  OperationNodePanoramic.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/25.
//
#import "PCSBaseViewController.h"
#import "OperationNodePanorama.h"
#import "PanoramaGuideView.h"
#import "PanoramaOrientationView.h"
#import "LenzSDKConstant.h"

@interface OperationNodePanorama ()

@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTaskToken;

@end

@implementation OperationNodePanorama

@dynamic isRecording;

@synthesize controller = _controller;
@synthesize modeTitleString = _modeTitleString;

- (NSString *)modeTitleString{
    return LOCALIZATION_STRING_KEY_MODE_TITLE_PANORAMIC;
}

- (SDKCaptureModeIndex)modeIndex{
    return SDK_CAPTURE_MODE_PANORAMA;
}

- (NSString *)modeItemString{
    return @"全景";
}

- (nonnull instancetype)initWithController:(nonnull PCSBaseViewController *)controller {
    self = [super init];
    if(self){
        _controller = controller;
    }
    
    return self;
}

- (void)cleanOnCompleted:(void (^)(void))block{
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}

- (BOOL)start{
    [super start];
    BOOL ret = [self.controller startVideoDataOutputing];
    if(ret){
        self.controller.panoramaGuideView.hidden = NO;
        self.controller.panoramOrientationGuideView.hidden = NO;
    }
    return ret;
}

- (void)stop{
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
//            weakSelf.controller.switchButton.hidden = NO;
//            weakSelf.controller.panoramaGuideView.hidden = YES;
//            weakSelf.controller.panoramOrientationGuideView.hidden = YES;
        });
    } else {
//        self.controller.switchButton.hidden = NO;
//        self.controller.panoramaGuideView.hidden = YES;
//        self.controller.panoramOrientationGuideView.hidden = YES;
    }
    
    [super stop];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.controller stopVideoDataOutputing];
    });
}

- (void)save {
//    [self.controller show]
}


- (void)triggered {
    [self stop];
}


- (void)willQuitOnCompletion:(nonnull WillQuitCompletionBlockType)block {
    self.controller.panoramaGuideView.hidden = YES;
    self.controller.panoramOrientationGuideView.hidden = YES;
}

#pragma mark - background
- (void)willEnterBackground:(NSNotification *)noti{
    self.bgTaskToken = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTaskToken];
        self.bgTaskToken = UIBackgroundTaskInvalid;
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self triggered];
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTaskToken];
        self.bgTaskToken = UIBackgroundTaskInvalid;
    });
}

@end
