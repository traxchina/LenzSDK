//
//  YYAnimatedImageView+YYDisplayLayer.m
//  RenJi
//
//  Created by lr on 2022/8/23.
//

#import "YYAnimatedImageView+YYDisplayLayer.h"
#import <objc/runtime.h>

@implementation YYAnimatedImageView (YYDisplayLayer)

+ (void)load {
    Method method1 = class_getInstanceMethod(self, @selector(displayLayer:));
    Method method2 = class_getInstanceMethod(self, @selector(rj_displayLayer:));
    method_exchangeImplementations(method1, method2);

}

- (void)rj_displayLayer:(CALayer *)layer {
    if ([UIImageView instancesRespondToSelector:@selector(displayLayer:)]) {
        [super displayLayer:layer];
    }
}


@end
