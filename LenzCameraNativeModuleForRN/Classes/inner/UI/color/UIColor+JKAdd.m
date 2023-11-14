//
//  UIColor+JKAdd.m
//  JKBusinessBase
//
//  Created by durgiya on 2022/2/28.
//

#import "UIColor+JKAdd.h"

CGFloat jk_colorComponentFrom(NSString *string, NSUInteger start, NSUInteger length) {
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return hexComponent / 255.0;
}

@implementation UIColor (JKAdd)

+ (UIColor *)jk_colorWithHexString:(NSString *)hexString {
    CGFloat alpha, red, blue, green;
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    switch (colorString.length) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = jk_colorComponentFrom(colorString, 0, 1);
            green = jk_colorComponentFrom(colorString, 1, 1);
            blue  = jk_colorComponentFrom(colorString, 2, 1);
            break;
        case 4: // #ARGB
            alpha = jk_colorComponentFrom(colorString, 0, 1);
            red   = jk_colorComponentFrom(colorString, 1, 1);
            green = jk_colorComponentFrom(colorString, 2, 1);
            blue  = jk_colorComponentFrom(colorString, 3, 1);
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = jk_colorComponentFrom(colorString, 0, 2);
            green = jk_colorComponentFrom(colorString, 2, 2);
            blue  = jk_colorComponentFrom(colorString, 4, 2);
            break;
        case 8: // #AARRGGBB
            alpha = jk_colorComponentFrom(colorString, 0, 2);
            red   = jk_colorComponentFrom(colorString, 2, 2);
            green = jk_colorComponentFrom(colorString, 4, 2);
            blue  = jk_colorComponentFrom(colorString, 6, 2);
            break;
        default:
            return nil;
    }
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)jk_colorWithHexString:(NSString *)hexString andAlpha:(CGFloat)alpha {
    return [[self jk_colorWithHexString:hexString] colorWithAlphaComponent:alpha];
}

@end
