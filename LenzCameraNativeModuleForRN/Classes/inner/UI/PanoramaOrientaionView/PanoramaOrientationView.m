//
//  PanoramaOrientationView.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/25.
//

#import "PanoramaOrientationView.h"
#import <Masonry/Masonry.h>

@interface PanoramaOrientationViewItem : UIView

@property (nonatomic, strong) UILabel* paddingLabel;
@property (nonatomic, assign) BOOL isSel;

- (instancetype)initText: (NSString*)text;

@end

@implementation PanoramaOrientationViewItem

- (void)setIsSel:(BOOL)isSel{
    self.backgroundColor = UIColor.clearColor;
    self.paddingLabel.backgroundColor = UIColor.clearColor;
    if(isSel){
        self.paddingLabel.textColor = UIColor.blackColor;
    }else{
        self.paddingLabel.textColor = UIColor.whiteColor;
    }
}

- (instancetype)initText:(NSString*)text{
    self = [super init];
    if(self){
        _isSel = NO;
        self.backgroundColor = UIColor.clearColor;
        UILabel* paddingLabel = [[UILabel alloc] init];
        paddingLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:paddingLabel];
        paddingLabel.font = [UIFont systemFontOfSize:13];
        paddingLabel.text = text;
        paddingLabel.textColor = UIColor.whiteColor;
        paddingLabel.backgroundColor = UIColor.clearColor;
        [paddingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        _paddingLabel = paddingLabel;
    }
    return self;
}

@end

@interface PanoramaOrientationView ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSDictionary<NSNumber*, __kindof PanoramaOrientationViewItem*>* items;

@property (nonatomic, strong) UIView *inserView;
@property (nonatomic, assign) CGFloat left;
@end

@implementation PanoramaOrientationView

- (UIView *)inserView{
    if (_inserView == nil) {
        _inserView = [[UIView alloc]init];;
        _inserView.backgroundColor = UIColor.whiteColor;
        _inserView.layer.cornerRadius = 4;
        _inserView.layer.masksToBounds = YES;
    }
    return _inserView;
}

- (void)setSelectedItemIndex:(PanoramaOrientationViewDirectionEnum)selectedItemIndex{
    _selectedItemIndex = selectedItemIndex;
    if(selectedItemIndex >= self.items.count){
        return;
    }
    
    [self.items enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, __kindof PanoramaOrientationViewItem * _Nonnull obj, BOOL * _Nonnull stop) {
        obj.isSel = NO;
    }];
    
    PanoramaOrientationViewItem *item =self.items[@(self.selectedItemIndex)];
    item.isSel = YES;
    [self insertSubview:self.inserView atIndex:0];
    [UIView animateWithDuration:0.25 animations:^{
        [self.inserView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(item);
        }];
        [self layoutIfNeeded];
    }];
    
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.userInteractionEnabled = YES;
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    NSString* titles[] = {@"上", @"下", @"左", @"右",@"异形"};
    NSMutableArray<__kindof PanoramaOrientationViewItem*>* items = [NSMutableArray array];
    PanoramaOrientationViewDirectionEnum directions[] = {PanoramaOrientationViewUp, PanoramaOrientationViewDown, PanoramaOrientationViewLeft, PanoramaOrientationViewRight,PanoramaOrientationViewAny};
    for(int i = 0; i < 5; ++i){
        PanoramaOrientationViewItem* item = [[PanoramaOrientationViewItem alloc] initText:titles[i]];
        item.tag = directions[i];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [item addGestureRecognizer:tap];
        [self addSubview:item];
        [dic setObject:item forKey:@(directions[i])];
        [items addObject:item];
    }
    self.items = [dic copy];
    [items.firstObject mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.top.bottom.equalTo(self);
        make.width.mas_offset(44);
        make.height.mas_equalTo(22);
    }];
    PanoramaOrientationViewItem* previous = items.firstObject;
    for(int i = 1; i < 5; ++i){
        PanoramaOrientationViewItem* item = items[i];
        [item mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(previous.mas_right);
            make.width.equalTo(previous);
            make.top.bottom.equalTo(self);
        }];
        previous = item;
    }
    
    [items.lastObject mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right);
    }];


    self.selectedItemIndex = PanoramaOrientationViewAny;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    self.layer.cornerRadius = 3.5;
    self.layer.masksToBounds = YES;
    [self addGesture];
}

/// 添加滑动的手势,选择全景的拍摄的方向
-(void)addGesture{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
    [self addGestureRecognizer:panGesture];
    panGesture.delegate = self;
}
- (void)tapAction:(UITapGestureRecognizer *)tap {
    UIView *view = tap.view;
    self.selectedItemIndex = view.tag;
    if ([self.delegate respondsToSelector:@selector(panoramDirDidChange)]) {
        [self.delegate panoramDirDidChange];
    }

}

-(void)panDirection:(UIPanGestureRecognizer *)sender{
    [self handleSwipe:sender];
}

- (void)handleSwipe:( UIPanGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.left = self.inserView.frame.origin.x;
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        [self commitTranslation:[gesture translationInView:self] left:self.left];
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint center =  self.inserView.center;
        [self.items enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, __kindof PanoramaOrientationViewItem * _Nonnull obj, BOOL * _Nonnull stop) {
            if (CGRectContainsPoint(obj.frame, center)) {
                self.selectedItemIndex = key.integerValue;
                if ([self.delegate respondsToSelector:@selector(panoramDirDidChange)]) {
                    [self.delegate panoramDirDidChange];
                }
            }
        }];
    }
}

- (void)commitTranslation:(CGPoint)translation left:(CGFloat)left{
    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);
    // 设置滑动有效距离
    if (MAX(absX, absY) < 10) return;
    CGFloat margin = left + translation.x;
    if (margin < 0) {
        margin = 0;
    }
    
    if (margin+self.inserView.frame.size.width >= self.bounds.size.width) {
        margin = self.bounds.size.width - CGRectGetWidth(self.inserView.bounds);
    }
    [self.inserView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(0);
        make.width.mas_equalTo(self.items[@0].mas_width);
        make.left.mas_equalTo(margin);
    }];
    
    CGPoint center =  self.inserView.center;
    [self.items enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, __kindof PanoramaOrientationViewItem * _Nonnull obj, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(obj.frame, center)) {
            obj.isSel = YES;
        }else{
            obj.isSel = NO;
        }
    }];
}
@end
