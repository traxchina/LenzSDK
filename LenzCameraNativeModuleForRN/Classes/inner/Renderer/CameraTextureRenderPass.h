//
//  CameraTextureRenderPass.h
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/26.
//

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MTKView;
@interface CameraTextureRenderPass : NSObject

@property (nonatomic, strong, nullable) id<MTLTexture> texture;

//- (id<MTLTexture>)makeTextureWith: (CMSampleBufferRef)sampleBuffer;
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size;
- (void)renderIn:(MTKView *)view withCommandBuffer: (id<MTLCommandBuffer>)cmdBuf;

@end

NS_ASSUME_NONNULL_END
