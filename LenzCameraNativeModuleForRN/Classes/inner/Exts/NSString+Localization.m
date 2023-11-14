//
//  NSString+Localization.m
//  sampleSDK
//
//  Created by 王昭威 on 2023/1/18.
//

#import "NSString+Localization.h"
#import <UIKit/UIKit.h>
#import "PCSTools.h"

@implementation NSString (Localization)

-(NSString *)localization{
    return NSLocalizedStringFromTableInBundle(self, @"Localizable", PCSTools.sdkBundle, @"");
}

@end
