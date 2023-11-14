//
//  LenzTensorFlow.h
//  LenzNormalCapture_Example
//
//  Created by Zero on 2020/6/12.
//  Copyright © 2020 zero. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>

@interface LenzTensorFlow : NSObject


- (instancetype)initWithFileName:(NSString *)fileName;

/// take photo is remake
/// @param image  CVPixelBufferRef
- (BOOL)remake:(UIImage *)image;


/// result
/// @param image CVPixelBufferRef
- (NSDictionary *)resultsDictWith:(UIImage *)image;



+ (NSDictionary *)checkIsRemakeWith:(NSDictionary *)param;



@end

