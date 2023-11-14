//
//  UIImage+ext.m
//  PanoramicCameraSDK
//
//  Created by 王昭威 on 2023/1/14.
//

#import "UIImage+ext.h"
#import "PCSTools.h"

#import <LenzTensorFlowSDK/LenzTensorFlowSDK.h>
//#import <LenzTensorFlow/LenzTensorFlow.h>
#import <LenzTensorFlowSDK/LenzTensorFlowLib.h>

@implementation UIImage (ext)

- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
 
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (nullable UIImage *)sdkImageNamed:(NSString *)name{

    return [UIImage imageNamed:name inBundle:[PCSTools sdkBundle] compatibleWithTraitCollection:nil];
}

+ (UIImageOrientation)imageOrientationByDeviceOrientation: (UIDeviceOrientation)deviceOrientation isFrontCamera: (BOOL)front{
    UIImageOrientation orientation = UIImageOrientationRight;
    switch(deviceOrientation){
        case UIDeviceOrientationUnknown: {
            orientation = front ? UIImageOrientationLeftMirrored : UIImageOrientationRight;
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown: {
            orientation = front ? UIImageOrientationRightMirrored : UIImageOrientationLeft;
            break;
        }
        case UIDeviceOrientationLandscapeLeft: {
            orientation = front ? UIImageOrientationDownMirrored : UIImageOrientationUp;
            break;
        }
        case UIDeviceOrientationLandscapeRight: {
            orientation = front ? UIImageOrientationUpMirrored : UIImageOrientationDown;
            break;
        }
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown: {
            orientation = front ? UIImageOrientationLeftMirrored : UIImageOrientationRight;
            break;
        }
    }
    
    return orientation;
}

- (float)checkRemake{
    CVPixelBufferRef buf = [self toCVPixelBufferRef];
    return [self checkRemakeForFrame:buf];
}

- (float)checkRemakeForFrame: (CVPixelBufferRef)frameBuffer{
    if(frameBuffer == nil){
        return 0;
    }
    NSString* path = [[PCSTools sdkBundle] pathForResource:@"moire_mobilenetv2_79" ofType:@"tflite"];
    LenzTensorFlowLib* lib = [[LenzTensorFlowLib alloc] initWithModelPath:path labels:@[@"origin", @"remake"]];
    NSDictionary * ret = [lib runModelOnFrame:frameBuffer];
    float value = 0;
    if(ret[@"remake"] != nil){
        value = [ret[@"remake"] floatValue];
    }
    
    return value;
}

- (CVPixelBufferRef)toCVPixelBufferRef
{
    CGImageRef image = [self CGImage];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CGFloat frameWidth = CGImageGetWidth(image);
    CGFloat frameHeight = CGImageGetHeight(image);
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameWidth,
                                          frameHeight,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 frameWidth,
                                                 frameHeight,
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0,
                                           0,
                                           frameWidth,
                                           frameHeight),
                       image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (instancetype)initWithBuffer:(CMSampleBufferRef)sampledBuffer isFrontCamera: (BOOL)front motionOrientation:(UIDeviceOrientation)motionOrientation{
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampledBuffer);
    if(pixelBuffer == NULL){
        return nil;
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    void* baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    if(context == NULL){
        return nil;
    }
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    if(imgRef == NULL){
        return nil;
    }
    UIImageOrientation orientation = [UIImage imageOrientationByDeviceOrientation:motionOrientation isFrontCamera:front];
    self = [self initWithCGImage:imgRef scale:1 orientation:orientation];
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    CGImageRelease(imgRef);
    return self;
}

@end
