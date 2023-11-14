//
//  LenzTensorFlow.h
//  LenzNormalCapture_Example
//
//  Created by Zero on 2020/6/12.
//  Copyright © 2020 zero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

// Set TFLITE_USE_GPU_DELEGATE to 1 to use TFLite GPU Delegate.
#ifndef TFLITE_USE_GPU_DELEGATE
#define TFLITE_USE_GPU_DELEGATE 0
#endif

@interface LenzTensorFlowLib : NSObject

//default 0.1
@property (nonatomic,assign) float threshold;

//modelPath不能为空
- (id)initWithModelPath:(NSString *)modelPath labels:(NSArray <NSString *> *)labels;

- (NSDictionary *)runModelOnFrame:(CVPixelBufferRef)pixelBuffer;

@end

