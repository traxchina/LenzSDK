//
//  OperationNodeMovie.m
//  sampleSDK
//
//  Created by 王昭威 on 2023/1/19.
//

#import "OperationNodeMovie.h"
#import "PCSBaseViewController.h"
#import "PCSRoundButton.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "QuitMultipleModeAlertViewController.h"
#import "TimerLabel.h"
#import "DBManager.h"
#import "LenzSDKConstant.h"

@implementation RecordedMovieModel

- (instancetype)initWithFileUrl:(NSURL *)fileUrl thumbnail:(UIImage *)thumbnail{
    self = [super init];
    if(self){
        _fileUrl = fileUrl;
        _thumbnail = thumbnail;
    }
    
    return self;
}

@end

@interface OperationNodeMovie ()

@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) NSUInteger maximumRecording;
@property (nonatomic, strong) NSMutableArray<RecordedMovieModel*>* recordedMovies;

@property (nonatomic, assign, readonly) BOOL hasCache;

@property (nonatomic, strong) UIImage* lastImage;

@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTaskToken;

@end

@implementation OperationNodeMovie

@dynamic isRecording;

- (NSArray<RecordedMovieModel *> *)cachedMovies{
    return [[NSArray alloc] initWithArray:self.recordedMovies];
}

- (UIImage *)lastImage{
    if (self.controller.totalArray.count > 0) {
        return [self.controller.totalArray lastObject];
    }else{
        return nil;
    }
}

- (BOOL)hasCache{
    return self.controller.totalArray.count > 0;
}

- (NSUInteger)numberOfCaches{
    return [self.recordedMovies count];
}

- (instancetype)initWithController:(PCSBaseViewController *)controller {
    self = [super initWithController:controller];
    if(self){
        
        _maximumRecording = 3;
        _recordedMovies = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)save {
    
}

- (void)didQuit{
    self.controller.modeLabel.hidden = NO;
    self.controller.timerLabel.hidden = YES;
}

- (void)updateUI{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.controller.modeLabel.hidden = YES;
        
        self.controller.timerLabel.backgroundColor = !self.isRecording ? [UIColor clearColor] : [PCSThemeColorManager orange];
        self.controller.timerLabel.hidden = NO;
        [self.controller.timerLabel updateWith:0];
        self.controller.timerLabel.padding = UIEdgeInsetsMake(0, 2.5, 0, 2.5);
    });
    
}

- (void)discardPhotoResultButtonTouchUpInside{
    [QuitMultipleModeAlertViewController show:self.controller title:@"确认提醒" text:@"返回会清空已拍摄图片，请确认！" leftBtnTitle:@"取消" rightBtnTitle:@"确定" withLeftButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
        
        [alertController dismissViewControllerAnimated:NO completion:^{}];
    } rightButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
        
        [alertController dismissViewControllerAnimated:NO completion:^{
            [self cleanOnCompleted:^{
                [self.controller dismissViewControllerAnimated:YES completion:^{}];
            }];
        }];
    }];
}

- (void)triggered {
    if(self.controller.recordedFileUrl == nil){
        return;
    }

    NSURL* outputFileURL = self.controller.recordedFileUrl;
    NSURL* moviesDir = [PCSTools shared].moviesDir;
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if(![fileMgr fileExistsAtPath:moviesDir.path isDirectory:&isDir]){
        NSError* err = nil;
        [fileMgr createDirectoryAtURL:moviesDir withIntermediateDirectories:YES attributes:nil error:&err];
        if(err != nil){
            return;
        }
    }
    NSError* err = nil;
    NSString* movieName = [[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"mov"];
    NSURL* desUrl = [moviesDir URLByAppendingPathComponent: movieName isDirectory:NO];
    if([[LenzDBManager shared] insertWithName:movieName type:SDKCameraCapturedResourceIndexMovie] &&
       [fileMgr moveItemAtURL:outputFileURL toURL:desUrl error:&err]){
        
        AVURLAsset* asset = [[AVURLAsset alloc] initWithURL:desUrl options:nil];
        AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        NSError *err = NULL;
        CMTime time = CMTimeMake(1, 65);
        CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&err];

        UIImage *frameImage= [[UIImage alloc] initWithCGImage:refImg scale:1.0 orientation:self.controller.thumbnailOritaionByCurrentVideoOrientation];
        
        [self.recordedMovies addObject:[[RecordedMovieModel alloc] initWithFileUrl:desUrl thumbnail:frameImage]];
        [self.controller.totalArray addObject:frameImage];
        self.isRecording = NO;
        [self updateUI];
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.controller.switchButton.alpha = 1;
        } completion:^(BOOL finished) {}];
    }
    else{
        NSLog(@"disk is full");
    }
}




- (SDKCaptureModeIndex)modeIndex{
    return SDK_CAPTURE_MODE_MOVIE;
}

- (void)willQuitOnCompletion: (WillQuitCompletionBlockType)block{

    showAlertToDiscardCachesWithTitle(self, @"", @"", block);
}

- (void)cleanOnCompleted:(void (^)(void))block{
    
    NSMutableArray<RecordedMovieModel*>* recordedMovies = self.recordedMovies;
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    [recordedMovies enumerateObjectsUsingBlock:^(RecordedMovieModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isDir = NO;
        if([fileMgr fileExistsAtPath:obj.fileUrl.path isDirectory: &isDir]){
            NSError* err = nil;
            if([fileMgr removeItemAtURL:obj.fileUrl error:&err]){
                NSString* name = [obj.fileUrl lastPathComponent];
                [[LenzDBManager shared] deleteByName: name type:SDKCameraCapturedResourceIndexMovie];
            }
            NSLog(@"%@", err);
        }
    }];
    
    [self.recordedMovies removeAllObjects];
    block();
}

- (BOOL)start{
    [super start];
    BOOL ret = [self.controller startRecording];
    return ret;
}

- (void)stop{
    self.isRecording = NO;
    [self.controller stopRecording];
}

- (BOOL)enable{
    return self.recordedMovies.count < self.maximumRecording;
}

- (NSString *)modeTitleString{
    return LOCALIZATION_STRING_KEY_MODE_TITLE_MOVIE;
}

- (NSString *)modeItemString{
    return @"视频";
}

- (NSString *)segueForAlbum{
    return @"show-movies";
}

- (UIImage *)firstCoverImage{
    return self.recordedMovies.firstObject.thumbnail;
}

- (void)deleteCacheForKey:(NSString *)key completion:(void (^)(BOOL))completion{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString* path = key;
        __block RecordedMovieModel* model = nil;
        [self.recordedMovies enumerateObjectsUsingBlock:^(RecordedMovieModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if([obj.fileUrl.path isEqualToString:path]){
                *stop = YES;
                model = obj;
            }
        }];
        
        if(model == nil){
            return;
        }
        
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        NSError* err = nil;
        if([fileMgr fileExistsAtPath:path]){
            if([fileMgr removeItemAtPath:path error:&err]){
                NSString* name = [model.fileUrl lastPathComponent];
                [[LenzDBManager shared] deleteByName:name type:SDKCameraCapturedResourceIndexMovie];
                [self.recordedMovies removeObject:model];
            }
            else{
                NSLog(@"%@", err);
            }
        }
        completion(err == nil);
    });
}

#pragma mark - background
- (void)willEnterBackground:(NSNotification *)noti{
    
    self.bgTaskToken = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTaskToken];
        self.bgTaskToken = UIBackgroundTaskInvalid;
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.controller stopRecording];
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTaskToken];
        self.bgTaskToken = UIBackgroundTaskInvalid;
    });
}

@end
