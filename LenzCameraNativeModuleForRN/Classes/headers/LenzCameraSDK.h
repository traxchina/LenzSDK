//
//  LenzCameraSDK.h
//  LenzCameraNativeModuleForRN
//
//  Created by lr on 2023/3/16.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef void(^LenzCameraSDKComplete)(NSDictionary *dict);

@interface LenzCameraSDK : NSObject

+ (void)showCameraSDKWithParams:(NSDictionary *)params
                       complete:(LenzCameraSDKComplete)complete;

+ (void)showCameraSDKWithParams:(NSDictionary *)params
                      presentVC:(__kindof UIViewController *)presentVC
                       complete:(LenzCameraSDKComplete)complete;


@end

NS_ASSUME_NONNULL_END
