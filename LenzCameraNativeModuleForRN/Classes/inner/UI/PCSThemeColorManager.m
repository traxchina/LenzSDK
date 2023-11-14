//
//  PCSThemeColorManager.m
//  sampleSDK
//
//  Created by 王昭威 on 2023/1/15.
//

#import "PCSThemeColorManager.h"
#import "PCSTools.h"

@implementation PCSThemeColorManager

+ (UIColor *)orange{
    return [UIColor colorNamed:@"custom-orange" inBundle:[PCSTools sdkBundle] compatibleWithTraitCollection:nil];
}

@end
