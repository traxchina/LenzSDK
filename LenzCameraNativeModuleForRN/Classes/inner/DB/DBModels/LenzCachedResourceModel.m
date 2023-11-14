//
//  LenzCachedResourceModel.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/29.
//

#import "LenzCachedResourceModel.h"

@implementation LenzCachedResourceModel



- (instancetype)init {
    if (self = [super init]) {
        self.continousArray = [NSMutableArray array];
        self.singleArray = [NSMutableArray array];
        self.movieArray = [NSMutableArray array];
        self.panoramArray = [NSMutableArray array];
        self.aiPanoramArray = [NSMutableArray array];
//        self.lastShowArray = [NSMutableArray array];
    }
    return self;
}

@end


@implementation LenzResourceItemModel

- (instancetype)init {
    if (self = [super init]) {
        self.keyFrame = [NSMutableArray array];
    }
    return self;
}
- (NSString *)cameraMode {
    switch (self.mode) {
        case SDK_CAPTURE_MODE_CONTINUOUS:
            return @"continuous";
            break;
        case SDK_CAPTURE_MODE_SINGLE:
            return @"single";
            break;
        case SDK_CAPTURE_MODE_MOVIE:
            return @"video";
            break;
        case SDK_CAPTURE_MODE_PANORAMA:
            return @"panorama";
            break;
        case SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA:
            return @"panoramaPlus";
            break;
            
        default:
            return nil;
            break;
    }
}
@end
