//
//  Renderer.h
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/26.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CameraTextureRenderPass;
@interface Renderer : NSObject

@property (nonatomic, strong, readonly) id<MTLDevice> device;

@property (nonatomic, strong, readonly) CameraTextureRenderPass* cameraPass;

+ (instancetype)shared;

- (void)drawInMTKView:(MTKView *)view;
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size;
- (void)setup;

@end

NS_ASSUME_NONNULL_END
