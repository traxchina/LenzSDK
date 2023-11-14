//
//  PCSMotionManager.h
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/27.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "LenzHeader.h"

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const PCS_NotificationNameOrientationDidChange;

typedef void(^OrientationDidChangeHandler)(UIDeviceOrientation current, UIDeviceOrientation old);
@class CMAccelerometerData;
@interface PCSMotionManager : NSObject

@property (nonatomic, readonly) CMAccelerometerData* accelerometerData;

@property(readonly, nonatomic) CMAcceleration userAcceleration;

@property (nonatomic, assign, readonly) UIDeviceOrientation currentDeviceOrientation;

@property (nonatomic, readonly) CMMotionManager* motionManager;

+ (instancetype)shared;

- (AVCaptureVideoOrientation)videoOrientation:(nullable UIDeviceOrientation*)currentDeviceOrientation;

//  direct to core motion
- (void)startAccelerometerUpdates;
- (void)stopAccelerometerUpdates;

- (void)startDeviceMotionUpdates;
- (void)stopDeviceMotionUpdates;

@end

NS_ASSUME_NONNULL_END
