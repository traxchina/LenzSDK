//
//  UIImage+ext.h
//  PanoramicCameraSDK
//
//  Created by 王昭威 on 2023/1/14.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (ext)

+ (UIImageOrientation)imageOrientationByDeviceOrientation: (UIDeviceOrientation)deviceOrientation isFrontCamera: (BOOL)front;

+ (nullable UIImage*)sdkImageNamed:(NSString *)name;

- (CVPixelBufferRef)toCVPixelBufferRef;

- (float)checkRemake;
- (float)checkRemakeForFrame: (CVPixelBufferRef)frameBuffer;

- (instancetype)initWithBuffer:(CMSampleBufferRef)sampledBuffer isFrontCamera: (BOOL)front motionOrientation: (UIDeviceOrientation)motionOrientation;

@end

NS_ASSUME_NONNULL_END
