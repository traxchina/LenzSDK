//
//  OperationNodeAIPanorama.h
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/31.
//
#import "PCSBaseViewController.h"
#import <Foundation/Foundation.h>
#import "OperationNodeProtocol.h"
#import "OperationNodeVideoBase.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, OperationAIType) {
    OperationAITypeTap,
    OperationAITypeLongPress,
};


@interface OperationNodeAIPanorama : OperationNodeVideoBase <OperationNodeBackgroundProtocol, OperationNodeProtocol>

@property (nonatomic) OperationAIType AIType;

@property (nonatomic, weak) PCSBaseViewController* controller;


@end

NS_ASSUME_NONNULL_END
