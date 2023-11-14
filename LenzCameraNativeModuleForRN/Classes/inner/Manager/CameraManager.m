//
//  CameraManager.m
//  PanoramicCameraSDK
//
//  Created by 王昭威 on 2023/1/14.
//

#import "CameraManager.h"

@interface CameraManager ()

@property (nonatomic, assign) CGFloat backAspect;

@property (nonatomic, assign) CGFloat frontAspect;

@end

@implementation CameraManager

@synthesize front = _front;
@synthesize back = _back;

- (void)setResolutionFor:(AVCaptureDevicePosition)position with: (NSInteger)desiredHeight model:(SDKCaptureModeIndex)model{
    
    AVCaptureDevice* device = [self cameraWithPosition:position];
    
    if(device == nil){
        return;
    }
    
    NSArray *supportedFormats = device.formats;
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    AVCaptureDeviceFormat *bestFormat;
    CGFloat aspect = 1;
    //分辨率
    CGFloat radio = 16.0/9.0;
    if(model == SDK_CAPTURE_MODE_SINGLE || model == SDK_CAPTURE_MODE_CONTINUOUS) {
        radio = height/width;
    }
    [device lockForConfiguration:nil];

    for (AVCaptureDeviceFormat *format in supportedFormats) {
        // 目标格式与当前预览宽高比一致
        CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions((CMVideoFormatDescriptionRef)[format formatDescription]);
//        NSLog(@"~~~~~~: H: %d, W:%D, r:%f", dimensions.width, dimensions.height, (CGFloat)dimensions.width/(CGFloat)dimensions.height);
        if (((CGFloat)dimensions.width/(CGFloat)dimensions.height) == radio && dimensions.height == desiredHeight) {
            bestFormat = format;
            break;
        }
    }
    
    if (!bestFormat) {
        //未找到 匹配格式 查找固定匹配格式 （720  1080  2160）
        for (AVCaptureDeviceFormat *format in supportedFormats) {
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions((CMVideoFormatDescriptionRef)[format formatDescription]);
//            CMVideoDimensions bestVideoDimensions = CMVideoFormatDescriptionGetDimensions((CMVideoFormatDescriptionRef)[bestFormat formatDescription]);
            if (((CGFloat)dimensions.width/(CGFloat)dimensions.height) == radio &&
                (dimensions.height == 720 || dimensions.height == 1080 || dimensions.height == 2160)) {
//                if (bestVideoDimensions.height <= dimensions.height) {
//                    bestFormat = format;
//                }
                if (dimensions.height == 1080) {
                    bestFormat = format;
                }
            }
        }
    }
    
    if (!bestFormat) {
        //未找到 固定格式 （720  1080  2160） 查找最佳格式（目标格式最近的分辨率）
        for (AVCaptureDeviceFormat *format in supportedFormats) {
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions((CMVideoFormatDescriptionRef)[format formatDescription]);
            CMVideoDimensions bestVideoDimensions = CMVideoFormatDescriptionGetDimensions((CMVideoFormatDescriptionRef)[bestFormat formatDescription]);
            if (((CGFloat)dimensions.width/(CGFloat)dimensions.height) == radio && dimensions.height <= desiredHeight ) {
                if (bestVideoDimensions.height <= dimensions.height) {
                    bestFormat = format;
                }
            }
        }
    }
    
    if(bestFormat) {
        [device setActiveFormat:bestFormat];
    }
    
    [device setActiveVideoMaxFrameDuration:CMTimeMake(1, 20)];
    [device setActiveVideoMinFrameDuration:CMTimeMake(1, 20)];
    
    [device unlockForConfiguration];
    
    if(device.position == AVCaptureDevicePositionFront){
        self.frontAspect = aspect;
    }
    else if(device.position == AVCaptureDevicePositionBack){
        self.backAspect = aspect;
    }
}


- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = nil;
    if(@available(iOS 10, *)){
        AVCaptureDeviceDiscoverySession *captureDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera]
                                              mediaType:AVMediaTypeVideo
                                               position:position];
        devices = [captureDeviceDiscoverySession devices];
    }
    else if(@available(iOS 4, *)){
        devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    }
    if(devices == nil){
        return nil;
    }
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
            return device;
    }
    return nil;
}

+ (instancetype)shared{
    static dispatch_once_t token;
    static CameraManager* instance = nil;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init{
    self = [super init];
    if(self){
        _back = [self cameraWithPosition:AVCaptureDevicePositionBack];
        _front = [self cameraWithPosition:AVCaptureDevicePositionFront];
        
        _frontAspect = 1;
        _backAspect = 1;
    }
    
    return self;
}

- (void)focusOn:(CGPoint)point{
    if (self.back == nil) {
        return;
    }
    [self focusOn:point device:self.back];
}

- (void)focusOn:(CGPoint)point device:(AVCaptureDevice *)device{
    NSError* error;
    [device lockForConfiguration:&error];
    if(error != nil){
        return;
    }
    
    if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
        [device setFocusPointOfInterest: point];
        device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    }
    if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [device setExposurePointOfInterest:point];
        device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    }
    [device unlockForConfiguration];
}


@end
