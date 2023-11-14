//
//  Renderer.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/26.
//

#import "Renderer.h"
#import "CameraTextureRenderPass.h"

@interface Renderer ()

@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) CameraTextureRenderPass* cameraPass;

@end

@implementation Renderer

+ (instancetype)shared{
    static dispatch_once_t token;
    static Renderer* instance = nil;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (void)drawInMTKView:(MTKView *)view{
    if(self.commandQueue == nil || view.currentDrawable == nil){
        return;
    }
    id<MTLCommandBuffer> cmdBuf = [self.commandQueue commandBuffer];
    [self.cameraPass renderIn:view withCommandBuffer: cmdBuf];
    
    [cmdBuf presentDrawable:view.currentDrawable];
    [cmdBuf commit];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size{
    
    
}

- (void)setup{
    self.cameraPass = [[CameraTextureRenderPass alloc] init];
}

- (instancetype)init{
    self = [super init];
    if(self){
        _device = MTLCreateSystemDefaultDevice();
        _commandQueue = [_device newCommandQueue];
    }
    
    return self;
}

@end
