//
//  UIColor+JKAdd.h
//  JKBusinessBase
//  UIColor相关的公共扩展方法
//  Created by durgiya on 2022/2/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (JKAdd)

/// 通过十六进制字符串创建UIColor对象
/// @param hexString 十六进制字符串格式，例如:#ARGB、#RRGGBB、#AARRGGBB
+ (UIColor *)jk_colorWithHexString:(NSString *)hexString;

/// 通过十六进制字符串创建UIColor对象
/// @param hexString hexString 十六进制字符串格式，例如:#ARGB、#RRGGBB、#AARRGGBB
/// @param alpha 颜色透明图，取值0-1
+ (UIColor *)jk_colorWithHexString:(NSString *)hexString andAlpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
