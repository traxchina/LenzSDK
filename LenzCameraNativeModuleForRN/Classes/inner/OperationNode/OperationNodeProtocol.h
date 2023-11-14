//
//  OperationNodeProtocol.h
//  sampleSDK
//
//  Created by 王昭威 on 2023/1/17.
//

#ifndef OperationNodeProtocol_h
#define OperationNodeProtocol_h

#import "LenzSDKConstant.h"

NS_ASSUME_NONNULL_BEGIN

@class UIImage;
@class  PCSBaseViewController;
typedef void(^WillQuitCompletionBlockType)();
@protocol OperationNodeLongPressProtocol <NSObject>

- (void)takePhotoButtonTouchDownInside;
- (void)takePhotoButtonTouchUpInside;

@end

@protocol OperationNodeBackgroundProtocol <NSObject>

- (void)willEnterBackground: (NSNotification*)noti;

@end

@protocol OperationNodeProtocol <NSObject>

@property (nonatomic, weak) PCSBaseViewController* controller;

@property (nonatomic, readonly) NSString* modeTitleString;
@property (nonatomic, readonly) NSString* modeItemString;
//@property (nonatomic) BOOL needHiddenDir;

@property (nonatomic, assign, readonly) SDKCaptureModeIndex modeIndex;

- (instancetype)initWithController: (PCSBaseViewController*)controller;

//  return NO if shouldnt quit current mode right now.
- (void)willQuitOnCompletion: (WillQuitCompletionBlockType)block;

- (void)save;
//  拍摄按钮被点击时，触发此方法
- (void)takePhotoButtonTouched;
//  Camera数据获取数据完成时调用此方法
- (void)triggered;
- (void)clear;

@optional

@property (nonatomic, assign, readonly) BOOL enable;
@property (nonatomic, readonly) NSUInteger numberOfCaches;
@property (nonatomic, readonly) NSString* segueForAlbum;


@property (nonatomic, readonly, nullable) UIImage* firstCoverImage;

- (void)didQuit;

- (void)cleanOnCompleted:(void(^)(void))block;
- (void)updateUI;
- (void)discardPhotoResultButtonTouchUpInside;

- (void)deleteCacheForKey: (NSString*)key completion: (void(^)(BOOL success))comletion;
- (void)deleteCacheForImage: (UIImage*)image completion: (void(^)(BOOL success))comletion;

@end
NS_ASSUME_NONNULL_END
#endif /* OperationNodeProtocol_h */
