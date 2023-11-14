//
//  OperationNodeVideoBase.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/25.
//
#import "PCSBaseViewController.h"
#import "OperationNodeVideoBase.h"
#import "PCSRoundButton.h"
#import "TimerLabel.h"
#import "PCSModeList.h"
#import "PanoramaGuideView.h"
#import "SVProgressHUD.h"

@interface OperationNodeVideoBase()

@property (nonatomic) dispatch_source_t stitchTimer;

@end


@implementation OperationNodeVideoBase

- (instancetype)initWithController:(PCSBaseViewController *)controller{
    self = [super init];
    if(self){
        _controller = controller;
        _isRecording = NO;
    }
    
    return self;
}

#pragma mark - strategy
- (void)discardPhotoResultButtonTouchUpInside{
    [self cleanOnCompleted:^{
        [self.controller dismissViewControllerAnimated:YES completion:^{}];
    }];
}

- (BOOL)start{
    return YES;
}

- (void)stop{
    
    self.isRecording = NO;
    [self updateButtonStatusByCurrentRecordingState];
    
}

#pragma mark - button
- (void)takePhotoButtonTouched{
    BOOL updatedRecording = !self.isRecording;
    self.controller.isVideoStitchStopedWhenRecording = NO;
    self.isRecording = updatedRecording && [self start];

    if(self.isRecording){
        if (self.controller.mode == SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA) {
            self.controller.panoramaGuideView.hidden = NO;
        }
        if ([self.controller.panoramOrientationGuideView.delegate respondsToSelector:@selector(panoramDirDidChange)]) {
            [self.controller.panoramOrientationGuideView.delegate panoramDirDidChange];
        }
    }
    
    self.controller.panGesture.enabled = !self.isRecording;
    self.controller.timerLabel.backgroundColor = !self.isRecording ? [UIColor clearColor] : [PCSThemeColorManager orange];
    [self updateTakePhotoButtonStatus];
    if(!self.isRecording){
        if (self.stitchResult != LenVideoStitchResultStitchFail && self.stitchResult != LenVideoStitchResultFail) {
            self.controller.isVideoStitchStopedWhenRecording = YES;
        } else {
            self.controller.isVideoStitchStopedWhenRecording = NO;
        }
        [self updateButtonStatusByCurrentRecordingState];
        if (self.modeIndex == SDK_CAPTURE_MODE_PANORAMA || self.modeIndex == SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self stop];
            });
        } else {
            [self stop];
        }
    }
    else{
        
        if (self.modeIndex == SDK_CAPTURE_MODE_PANORAMA || self.modeIndex == SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA) {
            [self.controller.timerLabel updateWith:0];
            self.controller.timerLabel.padding = UIEdgeInsetsMake(0, 2.5, 0, 2.5);

            self.stitchTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
            uint64_t duration = (uint64_t)(1.0 * NSEC_PER_SEC);
            __block NSInteger count = 0;
            dispatch_source_set_timer(self.stitchTimer, DISPATCH_TIME_NOW, duration, 0 * NSEC_PER_SEC);
            dispatch_source_set_event_handler(self.stitchTimer, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!self.isRecording) {
                        dispatch_source_cancel(self.stitchTimer);
                        self.controller.timerLabel.hidden = YES;
                        self.controller.modeLabel.hidden = NO;
                        return;
                    }

                    if (self.recTime == 0 || count <= self.recTime) {

                        self.controller.timerLabel.backgroundColor =  [PCSThemeColorManager orange];
                        [self.controller.timerLabel updateWith:count];
                        self.controller.timerLabel.hidden = NO;
                        self.controller.modeLabel.hidden = YES;
                        self.controller.flashButton.hidden = YES;
                        self.controller.ai_fullView.hidden = YES;
                        self.controller.panoramOrientationGuideView.hidden = YES;
                        
                        count++;
                    } else {
                        
                        [SVProgressHUD showImage:[UIImage imageNamed:@""] status:@"超过最大拼接时长，拼接结束"];
                        self.controller.timerLabel.backgroundColor = [UIColor clearColor];
                        [self.controller.timerLabel updateWith:0];
                        self.controller.timerLabel.hidden = YES;
                        self.controller.modeLabel.hidden = NO;
                        self.controller.flashButton.hidden = NO;
                        self.controller.ai_fullView.hidden = NO;
                        self.controller.panoramOrientationGuideView.hidden = NO;
                        self.controller.isVideoStitchStopedWhenRecording = YES;

                        UIImage* img = self.isRecording ? [UIImage loadNamed:@"btn-stop-recording"] : [UIImage loadNamed:@"take-photo-btn"];
                        [self.controller.takePhotoButton setImage:img forState:UIControlStateNormal];
                        
                        dispatch_source_cancel(self.stitchTimer);
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self stop];
                            [self.controller stopVideoDataOutputing];

                        });
                        [SVProgressHUD dismissWithDelay:3 completion:^{

                        }];
                    }
                });

            });
            dispatch_resume(self.stitchTimer);
        }
        
        [self updateUI];

    }
}

- (void)updateUI{
    
}

#pragma mark - update UI
- (void)updateButtonStatusByCurrentRecordingState{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.controller.timerLabel.hidden = YES;
        self.controller.modeLabel.hidden = NO;
    });
}

#pragma mark - Accessor

- (void)updateTakePhotoButtonStatus {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage* img = self.isRecording ? [UIImage loadNamed:@"btn-stop-recording"] : [UIImage loadNamed:@"take-photo-btn"];
        [self.controller.takePhotoButton setImage:img forState:UIControlStateNormal];
        
        if (!self.isRecording) {
            [self.controller.timerLabel updateWith:0];
            self.controller.flashButton.hidden = NO;
            self.controller.discardPhotoButton.hidden = NO;
            self.controller.savePhotoButton.hidden = NO;
            if (self.modeIndex == SDK_CAPTURE_MODE_PANORAMA || self.modeIndex == SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA) {
                self.controller.switchButton.hidden = YES;
            } else {
                self.controller.switchButton.hidden = NO;
            }
            self.controller.modeList.hidden = NO;
            self.controller.ablumImageView.hidden = NO;
        } else {
            self.controller.flashButton.hidden = YES;
            self.controller.discardPhotoButton.hidden = YES;
            self.controller.savePhotoButton.hidden = YES;
            self.controller.switchButton.hidden = YES;
            self.controller.backButton.hidden = YES;
            self.controller.modeList.hidden = YES;
            self.controller.ablumImageView.hidden = YES;
            self.controller.numberOfImagesLabel.hidden = YES;
            
        }
    });
}


@end
