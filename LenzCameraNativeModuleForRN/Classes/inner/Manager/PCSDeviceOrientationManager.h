//
//  PCSDeviceOrientationManager.h
//  LenzSDK
//
//  Created by lr on 2023/5/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,TgDirection) {
    TgDirectionUnkown,
    TgDirectionPortrait,
    TgDirectionDown,
    TgDirectionRight,
    TgDirectionLeft,
};

@protocol PCSDeviceOrientationDelegate <NSObject>

- (void)directionChange:(TgDirection)direction;

@end

@interface PCSDeviceOrientationManager : NSObject


@property (nonatomic) id<PCSDeviceOrientationDelegate> delegate;
@property (nonatomic) TgDirection currentDirection;

- (instancetype)initWithDelegate:(id<PCSDeviceOrientationDelegate>) delegate;
/**
 开启监听
 */
- (void)startMonitor;
/**
 结束监听，请stop
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
