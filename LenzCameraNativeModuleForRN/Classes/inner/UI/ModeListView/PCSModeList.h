//
//  PCSModeList.h
//  sampleSDK
//
//  Created by 王昭威 on 2023/1/15.
//

#import <UIKit/UIKit.h>
#import "LenzSDKConstant.h"
#import "LenzHeader.h"

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^PCSModeListIndexChanged)(NSUInteger newMode, NSUInteger oldMode, NSUInteger newIndex);

@interface PCSModeList : UIView

@property (nonatomic, assign) SDKCaptureModeIndex mode;

@property (nonatomic, copy) PCSModeListIndexChanged indexChangedHandler;
@property (nonatomic, assign) NSUInteger index;

@property (nonatomic, assign) NSUInteger selectMode;

- (void)reloadWith: (NSArray<id<OperationNodeProtocol>>*)items;

- (void)updateIndexByTanslation: (CGPoint)translation;
- (void)updateItemsConstraints;
//- (void)selectItemAt:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
