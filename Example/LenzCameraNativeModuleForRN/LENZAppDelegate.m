//
//  AppDelegate.m
//  Demo
//
//  Created by lr on 2023/2/1.
//

#import "LENZAppDelegate.h"
@interface LENZAppDelegate ()

@end

@implementation LENZAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    LENZViewController *vc = [[LENZViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    
    return YES;
}





@end
