//
//  LenzFileManager.m
//  LenzCameraNativeModuleForRN
//
//  Created by lr on 2023/3/8.
//

#import "LenzDataManager.h"

NSString *const LenFileDirectoryVideoPath = @"/Len_VideoStitch_Resources/";

NSString *const LenFileDirectorySinglePath = @"/single/";
NSString *const LenFileDirectoryContinuousPath = @"/continuous/";
NSString *const LenFileDirectoryMoviePath = @"/movie/";
NSString *const LenFileDirectoryPanoramaPath = @"/panorama/";
NSString *const LenFileDirectoryAiPanoramaPath = @"/aiPanorama/";


@implementation LenzDataManager


+ (NSString *)saveImageWith:(NSData *)data mode:(SDKCaptureModeIndex)mode {
    switch (mode) {
        case SDK_CAPTURE_MODE_CONTINUOUS: {
            NSString *path = [self continuousPath];
            if ([data writeToFile:path atomically:NO]) {
                return path;
            }
        }
            break;
        case SDK_CAPTURE_MODE_SINGLE: {
            NSString *path = [self singlePath];
            if ([data writeToFile:path atomically:NO]) {
                return path;
            }
        }
            break;
        case SDK_CAPTURE_MODE_PANORAMA:{
            NSString *path = [self panoramPath];
            if ([data writeToFile:path atomically:NO]) {
                return path;
            }
        }
            
            break;
        case SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA:{
            NSString *path = [self aiPanoramPath];
            if ([data writeToFile:path atomically:NO]) {
                return path;
            }
        }
            
            break;
            
        default:
            return nil;
            break;
    }
    return nil;
}
//+ (NSString *)saveVideoUrl:(NSURL *)url model:(SDKCaptureModeIndex)mode {
//    NSString *path = [self moviePath];
////
//    NSError *error = nil;
//    NSData *data = [NSData dataWithContentsOfFile:url.absoluteString];
//    BOOL success = [data writeToFile:path atomically:YES];
//    BOOL success1  = [[NSFileManager defaultManager] copyItemAtPath:url.absoluteString toPath:path error:&error];
////     = [[NSFileManager defaultManager] moveItemAtPath:url.absoluteString toPath:path error:nil];
//    if (success) {
//        return path;
//    } else {
//        return nil;
//    }
//}


+ (NSString *)singlePath {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *key = [NSString stringWithFormat:@"%.0f", timeInterval];
    return [[LenzDataManager singleDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"i_single_%@.jpg",key]];
}

+ (NSString *)continuousPath {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *key = [NSString stringWithFormat:@"%.0f", timeInterval];
    return [[LenzDataManager continuousDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"i_continuous_%@.jpg",key]];
}

+ (NSString *)panoramPath {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *key = [NSString stringWithFormat:@"%.0f", timeInterval];
    return [[LenzDataManager panoramsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"i_panorama_%@.jpg",key]];
}

+ (NSString *)aiPanoramPath {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *key = [NSString stringWithFormat:@"%.0f", timeInterval];
    return [[LenzDataManager aiPanoramsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"i_panoramaPlus_%@.jpg",key]];
}

+ (NSString *)moviePath {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *key = [NSString stringWithFormat:@"%.0f", timeInterval];
    return [[LenzDataManager movieDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"i_video_%@.mov",key]];
}


#pragma mark - Directory
+ (NSString *)creatDirectory {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [LenzDataManager rootDirectory];
    BOOL fileExisted = [fileManager fileExistsAtPath:path isDirectory:nil];
    if (!fileExisted) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"create root directory fail");
        } else {
            [self creatALLDirectoryIfNeeded];
            return path;
        }
    } else {
        [self creatALLDirectoryIfNeeded];
    }
    return path;
}


+ (void)creatALLDirectoryIfNeeded {
    [self createSingleDir];
    [self creatContinuousDir];
    [self createMovieDir];
    [self createPanoramsDir];
    [self createAiPanoramsDir];
}

+ (NSString *)rootDirectory {
    return [[LenzDataManager documentDirectory] stringByAppendingString:LenFileDirectoryVideoPath];
}

+ (NSString *)documentDirectory {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([documentDirectories count] > 0) {
        return [documentDirectories objectAtIndex:0];
    }
    
    return @"";
}

+ (NSString *)singleDirectory {
    return [[LenzDataManager rootDirectory] stringByAppendingPathComponent:LenFileDirectorySinglePath];
}
+ (void)createSingleDir {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExisted = [fileManager fileExistsAtPath:[LenzDataManager singleDirectory] isDirectory:nil];
    if (!fileExisted) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:[LenzDataManager singleDirectory] withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"创建single directory失败");
        } else {
            // fail try
        }
    }
}



+ (NSString *)continuousDirectory {
    return [[LenzDataManager rootDirectory] stringByAppendingPathComponent:LenFileDirectoryContinuousPath];
}

+ (void)creatContinuousDir {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExisted = [fileManager fileExistsAtPath:[LenzDataManager continuousDirectory] isDirectory:nil];
    if (!fileExisted) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:[LenzDataManager continuousDirectory] withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"创建single directory失败");
        } else {
            // fail try
        }
    }
}

+ (NSString *)movieDirectory {
    return [[LenzDataManager rootDirectory] stringByAppendingPathComponent:LenFileDirectoryMoviePath];
}
+ (void)createMovieDir {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExisted = [fileManager fileExistsAtPath:[LenzDataManager movieDirectory] isDirectory:nil];
    if (!fileExisted) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:[LenzDataManager movieDirectory] withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"创建single directory失败");
        } else {
            // fail try
        }
    }
}
+ (NSString *)panoramsDirectory {
    return [[LenzDataManager rootDirectory] stringByAppendingPathComponent:LenFileDirectoryPanoramaPath];
}
+ (void)createPanoramsDir {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExisted = [fileManager fileExistsAtPath:[LenzDataManager panoramsDirectory] isDirectory:nil];
    if (!fileExisted) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:[LenzDataManager panoramsDirectory] withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"创建single directory失败");
        } else {
            // fail try
        }
    }
}
+ (NSString *)aiPanoramsDirectory {
    return [[LenzDataManager rootDirectory] stringByAppendingPathComponent:LenFileDirectoryAiPanoramaPath];
}

+ (void)createAiPanoramsDir {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExisted = [fileManager fileExistsAtPath:[LenzDataManager aiPanoramsDirectory] isDirectory:nil];
    if (!fileExisted) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:[LenzDataManager aiPanoramsDirectory] withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"创建single directory失败");
        } else {
            // fail try
        }
    }
}


@end
