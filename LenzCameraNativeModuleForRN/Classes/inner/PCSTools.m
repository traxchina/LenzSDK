//
//  PCSTools.m
//  sampleSDK
//
//  Created by 王昭威 on 2023/1/15.
//
#import "PCSBaseViewController.h"
#import "PCSTools.h"
#import "OperationNodeProtocol.h"
#import "QuitMultipleModeAlertViewController.h"
#import "SDKParameters.h"
#import "LenzSDKConstant.h"
#import "LenzCachedResourceModel.h"

const NSNotificationName LenzSDKNotificationDiskIsFull = @"LENZ_SDK_NOTIFICATION_DISK_IS_FULL";
const NSNotificationName CameraNotificationNotPermission = @"CameraNotificationNotPermission";
const NSNotificationName MicrophoneNotificationNotPermission = @"MicrophoneNotificationNotPermission";

inline CGFloat dgree_2_rad(CGFloat dgree){
    return dgree / 180.0 * M_PI;
}

void showAlertToDiscardCachesWithTitle(id<OperationNodeProtocol> node, NSString* title, NSString* description, WillQuitCompletionBlockType block){
    
    id<OperationNodeProtocol> curr = node;
    if(curr.controller == nil){
        return;
    }
    if ([SDKParameters shared].retainedMode == SDK_DATA_RETAINED_CLEAR) {
        block();
    }
    else if([SDKParameters shared].retainedMode == SDK_DATA_RETAINED_USER_CONFIRM && [curr respondsToSelector:@selector(numberOfCaches)] && curr.numberOfCaches > 0){
        
        [QuitMultipleModeAlertViewController show: node.controller withSaveButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
            [alertController dismissViewControllerAnimated:NO completion:^{}];
            block();
        } discardButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
            
            if([curr respondsToSelector:@selector(cleanOnCompleted:)]){
                [curr cleanOnCompleted:^{
                    [alertController dismissViewControllerAnimated:NO completion:^{}];
                    block();
                }];
            }
        }];
    }
    else{
        block();
    }
}

@implementation PCSTools

- (void)cleanDiskCache{
}

- (NSString *)mainStoryboardName{
    return @"VC";
}

+ (PCSTools *)shared{
    static PCSTools* tool = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        tool = [[self alloc] init];
    });
    
    return tool;
}

- (NSString *)documentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    return path;
}

- (NSString *)tmpPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    return path;
}

- (NSURL *)moviesDir{
    return [[NSURL fileURLWithPath:self.tmpPath] URLByAppendingPathComponent:@"movies" isDirectory:YES];
}

- (NSString*)imagePathByName: (NSString*)name{
    NSString* tmpPath = [PCSTools shared].tmpPath;
    return [tmpPath stringByAppendingPathComponent:name];
}


- (NSString *)libraryPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    
    return path;
}

//+ (NSBundle*)resourceBundle{
//    NSBundle* classBundle = [NSBundle bundleForClass:self];
//    NSBundle* resourceBundle = [classBundle URLForResource:@"LenzCameraNativeModuleForRN" withExtension:@"bundle"];
//    return resourceBundle;
//}

+ (NSBundle*)sdkBundle{
    NSBundle* classBundle = [NSBundle bundleForClass:self];
    NSURL* url = [classBundle URLForResource:@"LenzCameraNativeModuleForRN" withExtension:@"bundle"];
    if(url == nil){
        return nil;
    }
    NSBundle* resourceBundle = [NSBundle bundleWithURL:url];
    return resourceBundle;
    
    return [NSBundle bundleWithIdentifier:@"LenzCameraNativeModuleForRN"];
}

@end
