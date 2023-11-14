//
//  SDKParameters.h
//  sampleSDK
//
//  Created by 王昭威 on 2023/1/21.
//

#import <Foundation/Foundation.h>
#import "LenzSDKConstant.h"

NS_ASSUME_NONNULL_BEGIN


@interface SDKParametersItem : NSObject

@property (nonatomic) SDKFlashModeIndex flashMode;
@property (nonatomic) BOOL isRemake;
@property (nonatomic) SDKCaptureModeIndex model;
@property (nonatomic) SDKVideoQuality videoQuality;
@property (nonatomic) CGFloat quality; //照片质量
@property (nonatomic) NSInteger recTime;
@property (nonatomic) NSInteger quantity;//视频数量 0 不限制
@property (nonatomic) SDKCameraPosition cameraPosition;
@property (nonatomic) NSString *cameraPositionString;
@property (nonatomic) NSNumber *keyFrame;
@property (nonatomic) NSInteger limitRecordTime;
@property (nonatomic) NSString *flashModeString;
@property (nonatomic) bool showPreviewForPanorama;
@property (nonatomic) CGSize resolution;
@property (nonatomic) CGSize videoResolution;

//      "flashMode": "auto",
//      "isRemake": true,
//      "mode": "video",
//      "quantity": 0,
//      "recTime": 30,
//      "type": "back",
//      "videoQuality": 480

@end



@interface SDKParameters : NSObject

//@property (nonatomic, assign) NSInteger limitRecordTime;

//@property (nonatomic, assign, readonly) CGSize resolution;

//@property (nonatomic, assign) CGSize videoResolution;

//@property (nonatomic, assign) SDKFlashModeIndex flashMode;
//@property (nonatomic) NSString *flashModeString;
//@property (nonatomic) NSNumber *keyFrame;

@property (nonatomic, assign) SDKCaptureModeIndex modeIndex;
@property (nonatomic) NSString *modeIndexString;
//  SDKCaptureModeIndex
@property (nonatomic, copy) NSArray<NSNumber*>* modeIndices;

//@property (nonatomic, assign) SDKCameraPosition cameraPosition;
//@property (nonatomic) NSString *cameraPositionString;

@property (nonatomic, assign) SDKDataRetainedModeIndex retainedMode;

//@property (nonatomic, assign) SDKVideoQuality videoQuality;

//@property (nonatomic) NSInteger quality;

//@property (nonatomic, assign) bool showPreviewForPanorama;

@property (nonatomic) NSArray <SDKParametersItem *> *items;

+ (instancetype)shared;

@end

NS_ASSUME_NONNULL_END
