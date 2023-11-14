//
//  CameraManager.h
//  PanoramicCameraSDK
//
//  Created by 王昭威 on 2023/1/14.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LenzSDKConstant.h"
NS_ASSUME_NONNULL_BEGIN

@class AVCaptureDevice;
@interface CameraManager : NSObject

@property (nonatomic, assign, nullable, readonly) AVCaptureDevice* back;

@property (nonatomic, readonly, nullable) AVCaptureDevice* front;

@property (nonatomic, assign, readonly) CGFloat backAspect;

@property (nonatomic, assign, readonly) CGFloat frontAspect;

+ (instancetype)shared;

- (void)focusOn:(CGPoint)point;
- (void)focusOn:(CGPoint)point device: (AVCaptureDevice*)device;

- (void)setResolutionFor:(AVCaptureDevicePosition)position with: (NSInteger)desiredHeight model:(SDKCaptureModeIndex)model;
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position;

@end

NS_ASSUME_NONNULL_END
