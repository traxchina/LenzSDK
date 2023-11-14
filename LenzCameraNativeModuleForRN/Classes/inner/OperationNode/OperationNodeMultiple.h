//
//  OperationNodeMultiple.h
//  sampleSDK
//
//  Created by 王昭威 on 2023/1/17.
//

#import <Foundation/Foundation.h>
#import "OperationNodeProtocol.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OperationNodeMultiple : NSObject <OperationNodeProtocol>

@property (nonatomic, weak) PCSBaseViewController* controller;

//  允许的最大内存缓存数量, 默认10
@property (nonatomic, assign) NSUInteger maxNumberOfImages;

@property (nonatomic, assign, readonly) BOOL hasCache;

@property (nonatomic, readonly) NSArray<UIImage*>* cachesInMemory;

@property (nonatomic, readonly) NSArray<NSString*>* cachesOnDisk;

@property (nonatomic, readonly, nullable) UIImage* lastImage;

@property (nonatomic, readonly) NSUInteger numberOfCaches;

//清除所有缓存数据
- (void)cleanOnCompleted: (void(^)(void))block;

@end

NS_ASSUME_NONNULL_END
