//
//  LenStitcher.h
//  LenzCameraNativeModuleForRN
//
//  Created by lr on 2023/2/9.
//


#import "lenz_stitch_jni.hpp"

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, LenVideoStitchResult) {
    
    LenVideoStitchResultStitchFail = -1,   // -1 拍摄完成后拼接大图失败
    LenVideoStitchResultFail,             //0: 拍摄过程中产生拼接缩略图失败
    LenVideoStitchResultSuccess,         //1: 视频拼接成功
    LenVideoStitchResultSlowMore,       // 2:特征点变少，放慢速度
    LenVideoStitchResultSlow,          //3 : 特征点极少，即将失败
    LenVideoStitchResultModerate,     //4
    LenVideoStitchResultParallel,    //5
    LenVideoStitchResultDirectError, // 6 当前拍摄固定了方向，请勿往反方向移动
};

typedef NS_ENUM(NSInteger, LenVideoStitchNeedSave) {
    LenVideoStitchUnNeedSaveImage, //拼接结果不需要保存
    LenVideoStitchNeedSaveImage, //需要保存

};


typedef NS_ENUM(NSInteger, LenVideoPathRestResult) {
    
    LenVideoPathRestResultFail,
    LenVideoPathRestResultSuccess,
};


typedef NS_ENUM(int, LenVideoStitchDirction) {
    LenVideoStitchDirctionAny,
    LenVideoStitchDirctionUp,
    LenVideoStitchDirctionDown,
    LenVideoStitchDirctionLeft,
    LenVideoStitchDirctionRight,
};


NS_ASSUME_NONNULL_BEGIN

@interface LenStitcher : NSObject



/// videostitch with default path,
+ (void)videoStitchWith:(CMSampleBufferRef)sampleBuffer
               dirction:(LenVideoStitchDirction)dirction
                 isStop:(BOOL)isStop
               complete:(void (^)(LenVideoStitchResult result, LenVideoStitchNeedSave needSave))complete;

/// video reset path with default path
+ (LenVideoPathRestResult)videoResetPath;

/// video current stitch local path
+ (NSString *)getCurrentPanoramaShow;


/// show last stitch image
+ (UIImage *)getCurrentPanoramaShowImage;

/// reset video  path with custom path
/// @param path  image local path
+ (LenVideoPathRestResult)videoResetPathWith:(NSString *)path;




/// just for test
+ (UIImage *)testImageWith:(CMSampleBufferRef)sampleBuffer;
+ (NSString *)getTestCurrentPanoramaShow;

@end

NS_ASSUME_NONNULL_END
