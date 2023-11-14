//
//  LenzFileManager.h
//  LenzCameraNativeModuleForRN
//
//  Created by lr on 2023/3/8.
//

#import <Foundation/Foundation.h>
#import "LenzCachedResourceModel.h"
#import "LenzSDKConstant.h"


NS_ASSUME_NONNULL_BEGIN

@interface LenzDataManager : NSObject

+ (NSString *)creatDirectory;
//+ (void)saveModel:(LenzCachedResourceModel *)model;

+ (NSString *)saveImageWith:(NSData *)data mode:(SDKCaptureModeIndex)mode;
//+ (NSString *)saveVideoUrl:(NSURL *)url model:(SDKCaptureModeIndex)mode;
//+ (void)savePath:()
+ (NSString *)moviePath;

@end

NS_ASSUME_NONNULL_END
