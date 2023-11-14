//
//  OperationNodeAIPanorama.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/31.
//

#import "OperationNodeAIPanorama.h"
#import "LenzSDKConstant.h"
#import "PanoramaGuideView.h"
#import "PanoramaOrientationView.h"

@implementation OperationNodeAIPanorama

@synthesize controller = _controller;

- (SDKCaptureModeIndex)modeIndex{
    return SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA;
}

- (NSString *)modeItemString{
    return @"智能全景";
}

- (NSString *)modeTitleString{
    return LOCALIZATION_STRING_KEY_MODE_TITLE_AI_PANORAMIC;
}

- (void)updateUI{
//    self.controller.numberOfImagesLabel.hidden = NO;
//    self.controller.numberOfImagesLabel.text = [[NSString alloc] initWithString:LOCALIZATION_STRING_KEY_TIP_FOR_AI_PANORAMA];
}

- (nonnull instancetype)initWithController:(nonnull PCSBaseViewController *)controller {
    self = [super init];
    if(self){
        _controller = controller;
    }
    
    return self;
}

- (void)save {
    
}

- (void)takePhotoButtonTouched {
    if (self.AIType == OperationAITypeTap) {
        [self.controller takeStillPhoto];
    } else {
        [super takePhotoButtonTouched];
    }
}

- (BOOL)start{
    [super start];
    BOOL ret = [self.controller startVideoDataOutputing];
    return ret;
}

- (void)stop{
    
    [super stop];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.controller stopVideoDataOutputing];
    });
}

- (void)triggered {
    [self stop];
//    self.controller.panoramOrientationGuideView.selectedItemIndex = PanoramaOrientationViewUp;

}

- (void)willQuitOnCompletion:(nonnull WillQuitCompletionBlockType)block {
    self.controller.panoramaGuideView.hidden = YES;
    self.controller.panoramOrientationGuideView.hidden = YES;
}


- (void)discardPhotoResultButtonTouchUpInside{
}
@end
