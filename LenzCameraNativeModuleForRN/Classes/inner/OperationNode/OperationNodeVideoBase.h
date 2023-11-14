//
//  OperationNodeVideoBase.h
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/25.
//

#import <Foundation/Foundation.h>
#import "LenzHeader.h"
#import <LenzStitchSDK/LenzStitchSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface OperationNodeVideoBase : NSObject <OperationNodeProtocol>

@property (nonatomic, weak) PCSBaseViewController* controller;

@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic) BOOL needHiddenDir;
@property (nonatomic) NSInteger recTime;
@property (nonatomic) LenVideoStitchResult stitchResult;


- (void)updateButtonStatusByCurrentRecordingState;
- (void)takePhotoButtonTouched;
- (BOOL)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
