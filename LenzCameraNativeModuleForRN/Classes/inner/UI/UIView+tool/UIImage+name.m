//
//  UIImage+name.m
//  LenzCameraNativeModuleForRN
//
//  Created by  on 2023/2/4.
//

#import "UIImage+name.h"

@implementation UIImage (name)

+ (instancetype)loadNamed:(NSString *)name{
    NSBundle *b= [NSBundle bundleWithURL:[[NSBundle bundleForClass:NSClassFromString(@"PCSBaseViewController")] URLForResource:@"LenzCameraNativeModuleForRN" withExtension:@"bundle"]];
    if (@available(iOS 8.0, *)) {
        return [UIImage imageNamed:name inBundle:b compatibleWithTraitCollection:nil];
    } else {
        return nil;
    }
}

@end
