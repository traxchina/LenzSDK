//
//  UIView+JKAdd.h
//  JKBusinessBase
//  UIView相关的公共扩展方法
//  Created by durgiya on 2022/3/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (JKAdd)

#pragma mark - 视图添加边线相关方法

/// 视图底部添加线条
/// @param color 线条颜色
- (void)jk_addBottomLine:(UIColor *)color;

/// 视图底部添加线条
/// @param color 线条颜色
/// @param left 线条距离视图左侧的距离
- (void)jk_addBottomLine:(UIColor *)color marginLeft:(CGFloat)left;

/// 视图底部添加线条
/// @param color 线条颜色
/// @param right 线条距离视图右侧的距离
- (void)jk_addBottomLine:(UIColor *)color marginRight:(CGFloat)right;

/// 视图中间添加水平线条
/// @param color 线条颜色
- (void)jk_addMiddleLine:(UIColor *)color;

/// 视图顶部添加线条
/// @param color 线条颜色
- (void)jk_addTopLine:(UIColor *)color;

#pragma mark - 添加阴影的相关方法

/// 视图添加阴影
/// @param color        阴影颜色
/// @param opacity      阴影透明度
/// @param radius       阴影半径
/// @param offset       阴影偏移
/// @param shadowRect   阴影路径   若不设置则使用 CGRectNull
- (void)jk_addShadowWithShadowColor:(UIColor *)color
                      shadowOpacity:(CGFloat)opacity
                       shadowRadius:(CGFloat)radius
                       shadowOffset:(CGSize)offset
                     shadowPathRect:(CGRect)shadowRect;

#pragma mark - 坐标相关方法

/// 视图左侧距父视图的距离
@property (nonatomic, assign) CGFloat jk_left;

/// 视图顶部距父视图的距离
@property (nonatomic, assign) CGFloat jk_top;

/// 视图右侧距父视图的距离
@property (nonatomic, assign) CGFloat jk_right;

/// 视图底部距父视图的距离
@property (nonatomic, assign) CGFloat jk_bottom;

/// 视图中心在父视图水平方向的位置
@property (nonatomic, assign) CGFloat jk_centerX;

/// 视图中心在父视图垂直方向的位置
@property (nonatomic, assign) CGFloat jk_centerY;

/// 视图的宽度
@property (nonatomic, assign) CGFloat jk_width;

/// 视图的高度
@property (nonatomic, assign) CGFloat jk_height;

/// 视图的位置
@property (nonatomic, assign) CGPoint jk_origin;

/// 视图的尺寸
@property (nonatomic, assign) CGSize jk_size;

#pragma mark - 视图操作相关方法

/// 移除所有子视图
- (void)jk_removeAllSubviews;

/// 为视图添加圆角
/// @param corners 圆角的位置
/// @param radii 圆角直径
/// @param size 待绘制区域的尺寸
- (void)jk_setCorners:(UIRectCorner)corners
            withRadii:(CGSize)radii
                 size:(CGSize)size;

/// 为视图添加圆角Layer
/// @param color Layer背景颜色
/// @param radius 圆角半径
- (void)jk_addCornerLayer:(UIColor *)color cornerRadius:(CGFloat)radius;

/// 通过xib加载对应的视图
+ (id)jk_loadFromXib;

/// 加载pod私有库中的xib
/// @param bundleName xib所在的bundle名称
+ (id)jk_podLoadFromXibWithBundleName:(NSString *)bundleName;

/// 当UITableViewCell等视图的重用标识使用，实际就是当前类的类名
+ (NSString *)jk_cellIdentifier;

/// 获取父视图中的UITableView
- (UITableView *)jk_tableView;

#pragma mark - 视图层级发生变更的相关逻辑

/// 视图调用了addSubview之后的回调block，该block目前是在基类中给侧滑返回逻辑使用。如果其他地方使用，需要注意是否会影响控制器侧滑返回功能
@property (nonatomic, copy) void(^jk_didAddsubView)(UIView *view);

@end

NS_ASSUME_NONNULL_END
