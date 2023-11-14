//
//  OperationNodeSingle.m
//  sampleSDK
//
//  Created by 王昭威 on 2023/1/17.
//
#import "PCSBaseViewController.h"
#import "OperationNodeSingle.h"
#import "LenzSDKConstant.h"
#import "LenzHeader.h"

@implementation OperationNodeSingle

- (instancetype)initWithController:(PCSBaseViewController *)controller{
    self = [super init];
    if(self){
        _controller = controller;
    }
    
    return self;
}

- (SDKCaptureModeIndex)modeIndex{
    return SDK_CAPTURE_MODE_SINGLE;
}

- (NSString *)modeItemString{
    return @"单拍";
}

- (NSString *)modeTitleString{
    return LOCALIZATION_STRING_KEY_MODE_TITLE_SINGLE;
}

- (void)save {
//    UIImageWriteToSavedPhotosAlbum(self.controller.capturedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    if ([self.controller respondsToSelector:@selector(savePhotoButtonTouchUpInside:)]) {
        [self.controller savePhotoButtonTouchUpInside:[NSObject new]];
    }
}
- (void)clear {
    [self.controller clearSingleData];
}

- (void)takePhotoButtonTouched{
    [self.controller takeStillPhoto];
}

- (void)triggered {
//    NSLog(@"12321");
}

- (void)discardPhotoResultButtonTouchUpInside{
    [self.controller startCaptureSession];
    [self.controller showPreviewView:YES];
}

- (void)updateUI{
//    self.controller.backButton.hidden = NO;
//    self.controller.savePhotoButton.hidden = YES;
//    self.controller.discardPhotoButton.hidden = YES;
//    self.controller.albumButton.hidden = YES;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{

    if(error != nil){
        return;
    }
    [self.controller dismissViewControllerAnimated:YES completion:^{}];
}

- (void)willQuitOnCompletion: (WillQuitCompletionBlockType)block{
    block();
}

@end
