//
//  OperationNodeMultiple.m
//  sampleSDK
//
//  Created by 王昭威 on 2023/1/17.
//
#import "PCSBaseViewController.h"
#import "OperationNodeMultiple.h"
#import "PCSTools.h"
#import <Photos/Photos.h>
#import "NSString+Localization.h"
#import <AVFoundation/AVFoundation.h>
#import "QuitMultipleModeAlertViewController.h"
#import "DBManager.h"
#import "LenzSDKConstant.h"
#import "LenzHeader.h"

@interface OperationNodeMultiple ()

@property (nonatomic, strong) NSMutableArray<UIImage*>* caches;

@property (nonatomic, strong) NSMutableArray<NSString*>* imgNamesOnDisk;

@end

@implementation OperationNodeMultiple

- (NSArray<UIImage *> *)cachesInMemory{
    return [NSArray arrayWithArray:self.caches];
}

- (NSArray<NSString *> *)cachesOnDisk{
    return [NSArray arrayWithArray:self.imgNamesOnDisk];
}

- (BOOL)hasCache{
    return self.numberOfCaches != 0;
}

- (UIImage *)lastImage{
//        return self.caches.lastObject;

    if (self.controller.totalArray.count > 0) {
        return self.controller.totalArray.lastObject;
    }else{
        return nil;
    }
}

- (instancetype)initWithController:(PCSBaseViewController *)controller {
    self = [super init];
    if(self){
        _controller = controller;
        _caches = [[NSMutableArray alloc] init];
        _imgNamesOnDisk = [[NSMutableArray alloc] init];
        _maxNumberOfImages = 10lu;
    }
    return self;
}

- (NSString *)modeTitleString{
    return LOCALIZATION_STRING_KEY_MODE_TITLE_MULTIPLE;
}

- (NSString*)imagePathByName: (NSString*)name{
    NSString* tmpPath = [PCSTools shared].tmpPath;
    return [tmpPath stringByAppendingPathComponent:name];
}

- (BOOL)saveIntoDisk{
    
    UIImage* img = self.caches.firstObject;
    if(img != nil){
        NSData* imgData = UIImageJPEGRepresentation(img, 1);
        NSString* imgName = [NSUUID UUID].UUIDString;
        if([[LenzDBManager shared] insertWithName:imgName type:SDKCameraCapturedResourceIndexPhoto] &&
           [imgData writeToURL:[NSURL fileURLWithPath:[[PCSTools shared] imagePathByName:imgName]] atomically:YES]){
            
            [self.imgNamesOnDisk addObject:imgName];
            [self.caches removeObjectAtIndex:0lu];
        }
        else{
            return NO;
        }
    }
    
    return YES;
}

- (void)showAlbumButton{
    self.controller.albumButton.hidden = NO;
    self.controller.backButton.hidden = YES;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{

    if(error != nil){
        return;
    }
    [self showAlbumButton];
}

- (void)saveImage: (NSArray<UIImage*>*)images urls: (NSArray<NSURL*>*)urls group: (dispatch_group_t)group completionHandler: (void(^)(BOOL success, NSError * _Nullable error))completionHandler{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:obj];
            PHObjectPlaceholder *assetPlaceholder = req.placeholderForCreatedAsset;
        }];
        [urls enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:obj];
            PHObjectPlaceholder *assetPlaceholder = req.placeholderForCreatedAsset;
        }];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        if (@available(iOS 15, *)) {
            if(error.code == PHPhotosErrorAccessUserDenied){
            }
            else if(error.code == PHPhotosErrorNotEnoughSpace){
                [[NSNotificationCenter defaultCenter] postNotificationName:LenzSDKNotificationDiskIsFull object:nil];
            }
        } else {
            if(error.code == 2047){
            }
            // Fallback on earlier versions
        }
        
        completionHandler(success, error);
        [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            dispatch_group_leave(group);
        }];
        [urls enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            dispatch_group_leave(group);
        }];
    }];
}

- (void)deleteCacheForKey:(NSString *)key completion:(void (^)(BOOL))completion{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString* imgName = key;
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        NSString* path = [self imagePathByName:imgName];
        NSError* err = nil;
        if([self.imgNamesOnDisk containsObject:key] && [fileMgr fileExistsAtPath:path]){
            if([fileMgr removeItemAtPath:path error:&err]){
                [[LenzDBManager shared] deleteByName:key type:SDKCameraCapturedResourceIndexPhoto];
                [self.imgNamesOnDisk removeObject:key];
            }
            else{
                NSLog(@"%@", err);
            }
        }
        completion(err == nil);
    });
}

- (void)deleteCacheForImage:(UIImage *)image completion:(void (^)(BOOL))completion{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.caches removeObject:image];
        [self.controller.totalArray removeObject:image];
        completion(YES);
    });
}

- (void)save {
    if(!self.hasCache){
        return;
    }
    
    //  loading indicator
    dispatch_block_t block = dispatch_block_create(0, ^{
        self.controller.loadingIndicator.hidden = NO;
        [self.controller.loadingIndicator.layer removeAnimationForKey:@"rotation"];
        CATransform3D myRotationTransform = CATransform3DRotate(self.controller.loadingIndicator.layer.transform, dgree_2_rad(359), 0.0, 0.0, 1.0);
        self.controller.loadingIndicator.layer.transform = CATransform3DIdentity;
        CABasicAnimation *rotateAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotateAnim.duration = 0.75;
        rotateAnim.fromValue = @(0);
        rotateAnim.toValue = @(dgree_2_rad(359));
        rotateAnim.repeatCount = INFINITY;
//        rotateAnim.autoreverses = YES;
        [self.controller.loadingIndicator.layer addAnimation:rotateAnim forKey:@"rotation"];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 200 * NSEC_PER_MSEC), dispatch_get_main_queue(), block);
        
    dispatch_group_t group = dispatch_group_create();
    [self.caches enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_enter(group);
    }];
    [self.imgNamesOnDisk enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_enter(group);
    }];
    
//    self.controller.view.userInteractionEnabled = NO;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self.caches removeAllObjects];
        [self.imgNamesOnDisk removeAllObjects];
        dispatch_block_cancel(block);
//        self.controller.view.userInteractionEnabled = YES;
        self.controller.loadingIndicator.hidden = YES;
        [self.controller.loadingIndicator.layer removeAnimationForKey:@"rotation"];
        [self.controller dismissViewControllerAnimated:YES completion:^{}];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray<UIImage*>* images = [[NSMutableArray alloc] initWithArray:self.caches];
        NSMutableArray<NSString*>* imgPaths = [NSMutableArray array];
        NSMutableArray<NSURL*>* imgUrls = [NSMutableArray array];
        [self.imgNamesOnDisk enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString* imgPath = [[PCSTools shared] imagePathByName:obj];
            if([[NSFileManager defaultManager] fileExistsAtPath:imgPath]){
                [imgUrls addObject:[NSURL fileURLWithPath:imgPath]];
                [imgPaths addObject:imgPath];
            }
            else{
                dispatch_group_leave(group);
            }
        }];

        [self saveImage:images urls: imgUrls group:group completionHandler:^(BOOL success, NSError * _Nullable error) {
            if(success){
                
                [imgPaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSError* err = nil;
                    if([[NSFileManager defaultManager] removeItemAtPath:obj error:&err]){
                        [[LenzDBManager shared] deleteByName:obj type:SDKCameraCapturedResourceIndexPhoto];
                    }
                    else{
                        NSLog(@"%@", err);
                    }
                }];
            }
        }];
    });
}

- (void)cleanOnCompleted:(void(^)(void))block{
    if(self.caches.count == 0 && self.imgNamesOnDisk == 0){
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
    [self.caches removeAllObjects];
    
    dispatch_group_t group = dispatch_group_create();
    [self.imgNamesOnDisk enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_enter(group);
    }];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self.imgNamesOnDisk removeAllObjects];
        block();
    });
    NSString* tmpPath = [PCSTools shared].tmpPath;
    [self.imgNamesOnDisk enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString* imgPath = [tmpPath stringByAppendingPathComponent:obj];
        if([[NSFileManager defaultManager] fileExistsAtPath:imgPath]){
            NSError* error;
            if([[NSFileManager defaultManager] removeItemAtPath:imgPath error:&error]){
                [[LenzDBManager shared] deleteByName:obj type:SDKCameraCapturedResourceIndexPhoto];
            }
        }
        dispatch_group_leave(group);
    }];
}

- (NSUInteger)numberOfCaches{
    return self.controller.totalArray.count + self.imgNamesOnDisk.count;
//    return self.caches.count + self.imgNamesOnDisk.count;
}

- (void)takePhotoButtonTouched{
    [self.controller takeStillPhoto];
}

- (void)updateUI{
    
//    self.controller.savePhotoButton.hidden = !self.hasCache;
//    self.controller.discardPhotoButton.hidden = !self.hasCache;
//
//    self.controller.albumButton.hidden = !self.hasCache;
//    self.controller.backButton.hidden = self.hasCache;
//    
//    [self.controller.albumButton setImage:self.lastImage forState:UIControlStateNormal];
    
    self.controller.numberOfImagesLabel.hidden = !self.hasCache;
    self.controller.numberOfImagesLabel.text = [NSString stringWithFormat:LOCALIZATION_STRING_KEY_NUM_OF_PHOTOS, [@(self.numberOfCaches) stringValue]];
}

- (void)discardPhotoResultButtonTouchUpInside{
//    [QuitMultipleModeAlertViewController show:self.controller title:@"确认提醒" text:@"返回会清空已拍摄图片，请确认！" leftBtnTitle:@"取消" rightBtnTitle:@"确定" withLeftButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
//        
//        [alertController dismissViewControllerAnimated:NO completion:^{}];
//    } rightButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
//        
//        [alertController dismissViewControllerAnimated:NO completion:^{
////            [self cleanOnCompleted:^{
////                [self.controller dismissViewControllerAnimated:YES completion:^{}];
////            }];
//        }];
//    }];
}

- (SDKCaptureModeIndex)modeIndex{
    return SDK_CAPTURE_MODE_CONTINUOUS;
}

- (NSString *)modeItemString{
    return @"连拍";
}

- (void)triggered {
    
    if (self.controller.capturedImage == nil) {
        return;
    }
    if (self.caches.count >= self.maxNumberOfImages) {
        if(![self saveIntoDisk]){
            [[NSNotificationCenter defaultCenter] postNotificationName:LenzSDKNotificationDiskIsFull object:nil];
            return;
        }
    }
    
    [self.caches addObject:self.controller.capturedImage];
    
    NSLog(@"-------:%lu",(unsigned long)self.caches.count);

    
    self.controller.numberOfImagesLabel.text = [NSString stringWithFormat:LOCALIZATION_STRING_KEY_NUM_OF_PHOTOS, [@(self.caches.count + self.imgNamesOnDisk.count) stringValue]];
    
    [self showAlbumButton];
    
    [self.controller.albumButton setImage:self.controller.capturedImage forState:UIControlStateNormal];
    self.controller.albumButton.layer.transform = CATransform3DScale(self.controller.albumButton.layer.transform, 0.1, 0.1, 1);
    
    CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    flash.fromValue = [NSNumber numberWithFloat:0.0];
    flash.toValue = [NSNumber numberWithFloat:1.0];
    flash.duration = 0.35;
    flash.autoreverses = NO;
    flash.repeatCount = 0;
    
    NSString* aniKey = @"flashAnimation";
    [self.controller.previewLayer removeAnimationForKey:aniKey];
    [self.controller.previewLayer addAnimation:flash forKey:aniKey];
    
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.controller.albumButton.layer.transform = CATransform3DIdentity;
    } completion:^(BOOL finished) {}];
    
    [self updateUI];
}

- (void)willQuitOnCompletion: (WillQuitCompletionBlockType)block{
    
    showAlertToDiscardCachesWithTitle(self, @"", @"", block);
}

- (NSString *)segueForAlbum{
    return @"show-photos";
}

- ( UIImage * _Nullable )firstCoverImage{
    UIImage* img = nil;
    if(self.imgNamesOnDisk.firstObject != nil){
        NSString* imgName = self.imgNamesOnDisk.firstObject;
        NSData* imgData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[[PCSTools shared].tmpPath stringByAppendingPathComponent:imgName]]];
        img = [UIImage imageWithData:imgData];
    }
    else{
        img = self.caches.firstObject;
    }
    
    return img;
}

@end
