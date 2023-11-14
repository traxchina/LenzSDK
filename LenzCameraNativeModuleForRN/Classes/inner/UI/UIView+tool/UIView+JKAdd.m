//
//  UIView+JKAdd.m
//  JKBusinessBase
//
//  Created by durgiya on 2022/3/1.
//

#import "UIView+JKAdd.h"
#import <objc/runtime.h>
#import "Masonry.h"

@implementation UIView (JKAdd)

#pragma mark - 分类加载方法

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(addSubview:);
        SEL swizzledSelector = @selector(jk_swizzlingAddSubview:);
        
        Method originalMethod = class_getInstanceMethod(self, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(self,
                                            originalSelector,
                                            method_getImplementation(swizzledMethod),
                                            method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            class_replaceMethod(self,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - 视图添加边线相关方法

- (void)jk_addBottomLine:(UIColor *)color {
    [self jk_addBottomLine:color marginLeft:0];
}

- (void)jk_addBottomLine:(UIColor *)color marginLeft:(CGFloat)left {
    UIView *line = [UIView new];
    line.backgroundColor = color;
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.offset(0);
        make.height.offset(0.5);
        make.left.offset(left);
    }];
}

- (void)jk_addBottomLine:(UIColor *)color marginRight:(CGFloat)right {
    UIView *line = [UIView new];
    line.backgroundColor = color;
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.offset(0);
        make.height.offset(0.5);
        make.right.offset(right);
    }];
}


- (void)jk_addMiddleLine:(UIColor *)color {
    UIView *line = [UIView new];
    line.backgroundColor = color;
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.height.offset(0.5);
        make.centerY.mas_equalTo(self);
    }];
}

- (void)jk_addTopLine:(UIColor *)color {
    UIView *line = [UIView new];
    line.backgroundColor = color;
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.offset(0);
        make.height.offset(0.5);
    }];
}

#pragma mark - 添加阴影的相关方法
- (void)jk_addShadowWithShadowColor:(UIColor *)color shadowOpacity:(CGFloat)opacity shadowRadius:(CGFloat)radius shadowOffset:(CGSize)offset shadowPathRect:(CGRect)shadowRect {
    //阴影颜色
    self.layer.shadowColor = color.CGColor;
    //阴影偏移
    self.layer.shadowOffset = offset;
    //阴影透明度
    self.layer.shadowOpacity = opacity;
    //阴影半径
    self.layer.shadowRadius = radius;
    
    if (!CGRectIsNull(shadowRect)) {
        //阴影路径
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:shadowRect];
        self.layer.shadowPath = path.CGPath;
    }
}

#pragma mark - 坐标相关方法

- (CGFloat)jk_left {
    return self.frame.origin.x;
}

- (void)setJk_left:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)jk_top {
    return self.frame.origin.y;
}

- (void)setJk_top:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)jk_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setJk_right:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)jk_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setJk_bottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)jk_centerX {
    return self.center.x;
}

- (void)setJk_centerX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)jk_centerY {
    return self.center.y;
}

- (void)setJk_centerY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)jk_width {
    return self.frame.size.width;
}

- (void)setJk_width:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)jk_height {
    return self.frame.size.height;
}

- (void)setJk_height:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGPoint)jk_origin {
    return self.frame.origin;
}

- (void)setJk_origin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)jk_size {
    return self.frame.size;
}

- (void)setJk_size:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

#pragma mark - 视图操作相关方法

- (void)jk_removeAllSubviews {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)jk_setCorners:(UIRectCorner)corners
            withRadii:(CGSize)radii
                 size:(CGSize)size {
    CGRect rect = self.bounds;
    rect.size = size;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                   byRoundingCorners:corners
                                                         cornerRadii:radii];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)jk_addCornerLayer:(UIColor *)color cornerRadius:(CGFloat)radius {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = radius;
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = 1;
}

+ (id)jk_loadFromXib {
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:self options:nil] lastObject];
}

+ (id)jk_podLoadFromXibWithBundleName:(NSString *)bundleName {
    NSURL *bundleURL = [[NSBundle bundleForClass:self.class] URLForResource:bundleName withExtension:@"bundle"];
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    if (bundleURL) {
        bundle = [NSBundle bundleWithURL:bundleURL];
    }
    
    return [[bundle loadNibNamed:NSStringFromClass(self.class) owner:self options:nil] lastObject];
}

+ (NSString *)jk_cellIdentifier {
    return NSStringFromClass(self);
}

- (UITableView *)jk_tableView {
    UIView *superView = self.superview;
    while (superView != nil && ![superView isKindOfClass:[UITableView class]]) {
        superView = superView.superview;
    }
    
    if (![superView isKindOfClass:UITableView.class]) {
        return nil;
    }
    
    return (UITableView *)superView;
}

#pragma mark - 视图层级发生变更的相关逻辑

- (void)jk_swizzlingAddSubview:(UIView *)view {
    [self jk_swizzlingAddSubview:view];
    
    if (self.jk_didAddsubView) {
        self.jk_didAddsubView(view);
    }
}

- (void (^)(UIView *))jk_didAddsubView {
    return objc_getAssociatedObject(self, @selector(jk_didAddsubView));
}

- (void)setJk_didAddsubView:(void (^)(UIView *))jk_didAddsubView {
    objc_setAssociatedObject(self, @selector(jk_didAddsubView), jk_didAddsubView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
