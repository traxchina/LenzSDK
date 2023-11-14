//
//  CameraTextureRenderPass.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/26.
//

#import "CameraTextureRenderPass.h"
#import <MetalKit/MetalKit.h>
#import "Renderer.h"
#import "PCSTools.h"

@interface CameraTextureRenderPass ()

@property (nonatomic, strong) UIImage* img;

@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;

@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineStateObject;

@end

@implementation CameraTextureRenderPass

- (instancetype)init{
    self = [super init];
    if(self){
        CVReturn ret = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, [Renderer shared].device, nil, &_textureCache);
        if(ret != kCVReturnSuccess){
            return nil;
        }
        
        id<MTLDevice> device = [Renderer shared].device;
        NSError* err = nil;
        id <MTLLibrary> library = [device newDefaultLibraryWithBundle:[PCSTools sdkBundle] error:&err];
        if(library == nil){
            return nil;
        }
        id <MTLFunction> vertFunc = [library newFunctionWithName:@"vert_main"];
        id <MTLFunction> fragFunc = [library newFunctionWithName:@"frag_main"];
        MTLRenderPipelineDescriptor* desc = [[MTLRenderPipelineDescriptor alloc] init];
        desc.label = @"camera";
        desc.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
        desc.vertexFunction = vertFunc;
        desc.fragmentFunction = fragFunc;
        desc.sampleCount = 1;
        desc.depthAttachmentPixelFormat = MTLPixelFormatInvalid;
        _pipelineStateObject = [device newRenderPipelineStateWithDescriptor:desc error:nil];
    }
    
    return self;
}

//- (id<MTLTexture>)makeTextureWith: (CMSampleBufferRef)sampleBuffer{
//
//    CVImageBufferRef imgBufRef = CMSampleBufferGetImageBuffer(sampleBuffer);
//    CVMetalTextureCacheRef textureCache = self.textureCache;
//
//    if(imgBufRef != nil && textureCache != nil){
//
//        size_t width = CVPixelBufferGetWidth(imgBufRef);
//        size_t height = CVPixelBufferGetHeight(imgBufRef);
//
//        CVMetalTextureRef imageTexture = nil;
//        CVReturn result = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, imgBufRef, nil, MTLPixelFormatBGRA8Unorm, width, height, 0, &imageTexture);
//        if(result != kCVReturnSuccess){
//            return nil;
//        }
//        id<MTLTexture> texture = CVMetalTextureGetTexture(imageTexture);
//        @synchronized (self) {
//            self.texture = texture;
//        }
//        CFRelease(imageTexture);
//
//        return texture;
//    }
//    return nil;
//}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size{
    
}

- (void)renderIn:(MTKView *)view withCommandBuffer:(id<MTLCommandBuffer>)cmdBuf{

    MTLRenderPassDescriptor* renderPassDes = view.currentRenderPassDescriptor;
    if(renderPassDes == nil){
        return;
    }
    id <MTLRenderCommandEncoder> renderEncoder = [cmdBuf renderCommandEncoderWithDescriptor:view.currentRenderPassDescriptor];
    if(renderEncoder == nil){
        return;
    }
    
    [renderEncoder setRenderPipelineState:self.pipelineStateObject];

    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [renderEncoder endEncoding];
}

@end
