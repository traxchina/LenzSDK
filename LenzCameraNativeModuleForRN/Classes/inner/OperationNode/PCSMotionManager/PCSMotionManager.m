//
//  PCSMotionManager.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/27.
//

#import "PCSMotionManager.h"
#import <CoreMotion/CoreMotion.h>

NSNotificationName const PCS_NotificationNameOrientationDidChange = @"OrientationDidChangeHandler";

@interface PCSMotionManager ()

@property(nonatomic) CMAcceleration userAcceleration;

@property (nonatomic, copy) CMAccelerometerData* accelerometerData;

@property (nonatomic, assign) UIDeviceOrientation currentDeviceOrientation;

@property (nonatomic, strong) CMMotionManager* motionManager;

@property (nonatomic, strong) NSOperationQueue* samplingQueue;

@end

@implementation PCSMotionManager

+ (instancetype)shared{
    static dispatch_once_t token;
    static PCSMotionManager* instance = nil;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init{
    self = [super init];
    if(self){
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.accelerometerUpdateInterval = 0.2;
        
        _samplingQueue = [NSOperationQueue mainQueue];
        _samplingQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (AVCaptureVideoOrientation)videoOrientation:(nullable UIDeviceOrientation*)currentDeviceOrientation{
    CMMotionManager* motionMgr = self.motionManager;
    UIDeviceOrientation motionOrientation = UIDeviceOrientationPortrait;
    if(motionMgr.deviceMotion != nil){
        CMAcceleration acc = motionMgr.deviceMotion.gravity;
        if(fabs(acc.y) < fabs(acc.x)){
            motionOrientation = acc.x > 0 ? UIDeviceOrientationLandscapeRight : UIDeviceOrientationLandscapeLeft;
        }
        else{
            motionOrientation = acc.y > 0 ? UIDeviceOrientationPortraitUpsideDown : UIDeviceOrientationPortrait;
        }
    }
    if(currentDeviceOrientation != nil)
        *currentDeviceOrientation = motionOrientation;
    
    AVCaptureVideoOrientation videoOrientation = AVCaptureVideoOrientationPortrait;
    NSDictionary* table = @{
        @(UIDeviceOrientationPortraitUpsideDown): @(AVCaptureVideoOrientationPortraitUpsideDown),
        @(UIDeviceOrientationPortrait): @(AVCaptureVideoOrientationPortrait),
        @(UIDeviceOrientationLandscapeLeft): @(AVCaptureVideoOrientationLandscapeRight),
        @(UIDeviceOrientationLandscapeRight): @(AVCaptureVideoOrientationLandscapeLeft),
    };
    if(table[@(motionOrientation)] != nil){
        videoOrientation = (AVCaptureVideoOrientation)[table[@(motionOrientation)] integerValue];
    }
    return videoOrientation;
}

- (void)startAccelerometerUpdates{
//    if(self.motionManager.deviceMotionAvailable && !self.motionManager.deviceMotionActive){
//        [self startDeviceMotionUpdates];
//    }
//    if(self.motionManager.accelerometerAvailable){
//        [self.motionManager startAccelerometerUpdatesToQueue:self.samplingQueue withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
//            
//            if(error != nil){
//                NSLog(@"%@", error);
//                return;
//            }
//            
//            self.userAcceleration = self.motionManager.deviceMotion.userAcceleration;
//            double pitch = self.motionManager.deviceMotion.attitude.pitch;
//            double x = self.userAcceleration.x;
//            double y = self.userAcceleration.y;
//            double z = self.userAcceleration.z;
////            NSLog(@"x:%lf| y:%lf| z:%lf| pitch:%lf",x,y,z,pitch);
//            
//            self.accelerometerData = accelerometerData;
//            UIDeviceOrientation currentOrientation = UIDeviceOrientationUnknown;
//            [self videoOrientation:&currentOrientation];
//            if(self.currentDeviceOrientation != currentOrientation){
//                UIDeviceOrientation old = self.currentDeviceOrientation;
//                self.currentDeviceOrientation = currentOrientation;
//                [[NSNotificationCenter defaultCenter] postNotificationName:PCS_NotificationNameOrientationDidChange object:@{@"new": @(currentOrientation), @"old": @(old)}];
//            }
//        }];
//    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector{
    if(![self respondsToSelector:aSelector] && [self.motionManager respondsToSelector:aSelector]){
        return self.motionManager;
    }
    
    return nil;
}

- (void)stopAccelerometerUpdates {
    
}

@end
