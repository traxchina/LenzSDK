//
//  LenzCameraSDK.m
//  LenzCameraNativeModuleForRN
//
//  Created by lr on 2023/3/16.
//
#import "PCSBaseViewController.h"

#import "LenzCameraSDK.h"

@implementation LenzCameraSDK



+ (void)showCameraSDKWithParams:(NSDictionary *)params
                       complete:(LenzCameraSDKComplete)complete {

    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *vc = [LenzCameraSDK topmostViewController];
        if (vc) {
            [LenzCameraSDK showCameraSDKWithParams:params presentVC:vc complete:complete];
        }
    });
}

+ (void)showCameraSDKWithParams:(NSDictionary *)params
                      presentVC:(__kindof UIViewController *)presentVC
                       complete:(LenzCameraSDKComplete)complete {
    if ([NSThread isMainThread]) {
        __block PCSBaseViewController *vc = [PCSBaseViewController initWithParams:params complete:^(NSDictionary * _Nonnull dict) {
            if (complete) {
                complete(dict);
            }
            vc = nil;
        }];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [presentVC presentViewController:vc animated:YES completion:nil];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            __block PCSBaseViewController *vc = [PCSBaseViewController initWithParams:params complete:^(NSDictionary * _Nonnull dict) {
                if (complete) {
                    complete(dict);
                }
                vc = nil;
            }];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [presentVC presentViewController:vc animated:YES completion:nil];
        });
    }

}



+ (UIViewController * __nullable)topmostViewController {
    UIViewController *topViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    
    if (topViewController == nil) {
        return nil;
    }
    
    while (true) {
        if (topViewController.presentedViewController != nil) {
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navi = (UINavigationController *)topViewController;
            topViewController = navi.topViewController;
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else {
            break;
        }
    }
    
    return topViewController;
}

@end
