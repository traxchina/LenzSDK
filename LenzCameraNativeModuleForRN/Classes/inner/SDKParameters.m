//
//  SDKParameters.m
//  sampleSDK
//
//  Created by 王昭威 on 2023/1/21.
//

#import "SDKParameters.h"
//#import <ui>

@interface SDKParameters ()

//  cgrects
@property (nonatomic, strong) NSDictionary<NSNumber*, NSValue*>* resolutionTable;

@end

@implementation SDKParameters

+ (instancetype)shared{
    static dispatch_once_t token;
    static SDKParameters* instance = nil;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (CGSize)videoResolution{
//    NSValue* value = self.resolutionTable[@(self.videoQuality)];
//    if(value == nil){
//        return [self.resolutionTable[@(SDK_VIDEO_QUALITY_1080)] CGSizeValue];
//    }
//    return [value CGSizeValue];
    
    return CGSizeZero;
}

- (instancetype)init{
    self = [super init];
    if(self){
//        _limitRecordTime = 30;
//        _flashMode = SDK_FLASH_MODE_OFF;
//        _resolutionTable = @{
//            @(SDK_VIDEO_QUALITY_480): [NSValue valueWithCGSize:CGSizeMake(720, 480)],
//            @(SDK_VIDEO_QUALITY_720): [NSValue valueWithCGSize:CGSizeMake(1280, 720)],
//            @(SDK_VIDEO_QUALITY_1080): [NSValue valueWithCGSize:CGSizeMake(1920, 1080)],
//            @(SDK_VIDEO_QUALITY_2160): [NSValue valueWithCGSize:CGSizeMake(3840, 2160)],
//        };
//        _resolution = CGSizeMake(1280, 720);
//        _modeIndex = SDK_CAPTURE_MODE_CONTINUOUS;
//        _cameraPosition = SDK_CAMERA_PISITION_BACK;
//        _retainedMode = SDK_DATA_RETAINED_RETAIN;
//        _videoQuality = SDK_VIDEO_QUALITY_720;
//        _showPreviewForPanorama = NO;
    }
    
    return self;
}

@end

@interface SDKParametersItem ()

@property (nonatomic, strong) NSDictionary<NSNumber*, NSValue*>* resolutionTable;


@end


@implementation SDKParametersItem

- (instancetype)init{
    self = [super init];
    if(self){
        _limitRecordTime = 30;
        _flashMode = SDK_FLASH_MODE_OFF;
        _resolutionTable = @{
            @(SDK_VIDEO_QUALITY_480): [NSValue valueWithCGSize:CGSizeMake(720, 480)],
            @(SDK_VIDEO_QUALITY_720): [NSValue valueWithCGSize:CGSizeMake(1280, 720)],
            @(SDK_VIDEO_QUALITY_1080): [NSValue valueWithCGSize:CGSizeMake(1920, 1080)],
            @(SDK_VIDEO_QUALITY_2160): [NSValue valueWithCGSize:CGSizeMake(3840, 2160)],
        };
        _resolution = CGSizeMake(1920, 1080);
//        _modeIndex = SDK_CAPTURE_MODE_CONTINUOUS;
        _cameraPosition = SDK_CAMERA_PISITION_BACK;
//        _retainedMode = SDK_DATA_RETAINED_RETAIN;
        _videoQuality = SDK_VIDEO_QUALITY_720;
        _showPreviewForPanorama = NO;
    }
    
    return self;
}


- (CGSize)videoResolution{
    NSValue* value = self.resolutionTable[@(self.videoQuality)];
    if(value == nil){
        return [self.resolutionTable[@(SDK_VIDEO_QUALITY_1080)] CGSizeValue];
    }
    return [value CGSizeValue];
}


@end
