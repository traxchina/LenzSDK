//
//  OperationNodeSingle.h
//  sampleSDK
//
//  Created by 王昭威 on 2023/1/17.
//

#import <Foundation/Foundation.h>
#import "OperationNodeProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface OperationNodeSingle : NSObject <OperationNodeProtocol>

@property (nonatomic, weak) PCSBaseViewController* controller;

@end

NS_ASSUME_NONNULL_END
