//
//  PCSModeList.m
//  sampleSDK
//
//  Created by 王昭威 on 2023/1/15.
//

#import "PCSModeList.h"
#import <Masonry/Masonry.h>
#import "PCSTools.h"
#import "PCSThemeColorManager.h"
#import "OperationNodeProtocol.h"

@interface PCSModeList ()

@property (nonatomic, strong) UIView* list;


@property (nonatomic, assign, readonly) CGFloat space;

@property (nonatomic, strong) NSArray<__kindof UILabel*>* itemViews;

@property (nonatomic, copy) NSArray<id<OperationNodeProtocol>>* items;

@property (nonatomic) CGPoint nextPoint;

@end

@implementation PCSModeList

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}


- (void)reloadWith:(NSArray<id<OperationNodeProtocol>>*)items{
    self.items = items;
    self.index = 0;
    self.itemViews = [self reloadItemViews];
    [self selectItemAt:self.index];
}

- (void)setMode:(SDKCaptureModeIndex)mode{
    __block NSUInteger index = NSUIntegerMax;
    
    [self.items enumerateObjectsUsingBlock:^(id<OperationNodeProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.modeIndex == mode){
            index = idx;
            *stop = YES;
        }
    }];
    if(_index == index){
        return;
    }
    if(NSUIntegerMax == index){
        return;
    }
    _index = index;
    [self updateItemsConstraints];
}

- (SDKCaptureModeIndex)mode{
    return (SDKCaptureModeIndex)self.index;
}

- (void)updateItemsConstraints{

    __block UILabel* previous = self.itemViews.firstObject;
    [self.itemViews enumerateObjectsUsingBlock:^(__kindof UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.textColor = UIColor.whiteColor;
        [obj mas_remakeConstraints:^(MASConstraintMaker *make) {
            if(idx != 0){
                make.left.equalTo(previous.mas_right).offset(self.space);
            }
            make.centerY.equalTo(self);
            if (obj.tag == SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA) {
                make.width.mas_offset(60);
            } else {
                make.width.mas_offset(44);
            }
            make.height.mas_offset(44);
        }];
        previous = obj;
    }];
    
    [self selectItemAt:self.index];
}

- (CGFloat)space{
    return 0;
}

- (void)updateIndexByTanslation:(CGPoint)translation{
    NSUInteger oldIndex = self.index;
    NSUInteger oldMode = self.selectMode;

    if(self.index < self.items.count - 1 && translation.x < 0){
        self.index += 1;
    }
    else if(self.index > 0 && translation.x > 0){
        self.index -= 1;
    }
    
    if (self.itemViews.count > self.index) {
        self.selectMode = self.itemViews[self.index].tag;
    }
    
    if (oldIndex != self.index) {
        if(self.indexChangedHandler){
            
            if (self.indexChangedHandler(self.selectMode, oldMode, self.index)) {
                [self updateItemsConstraints];
            } else {
                self.index = oldIndex;
                self.selectMode = oldMode;
            }
        }
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {}];
    }
    
}


- (void)selectItemAt: (NSUInteger)index{
    if(index >= self.itemViews.count){
        return;
    }
    self.itemViews[index].textColor = [PCSThemeColorManager orange];
    [self.itemViews[index] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
    }];
}

- (NSMutableArray*)reloadItemViews{
    NSArray<id<OperationNodeProtocol>>* items = self.items;
    __block UILabel* previous = nil;
    NSMutableArray* labels = [NSMutableArray array];
    [items enumerateObjectsUsingBlock:^(id<OperationNodeProtocol> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            self.selectMode = obj.modeIndex;
        }
        UILabel* label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:13];
        [labels addObject:label];
        label.textAlignment = NSTextAlignmentCenter;
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.text = obj.modeItemString;
        label.textColor = UIColor.whiteColor;
        label.tag = obj.modeIndex;
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            if(previous != nil){
                make.left.equalTo(previous.mas_right).offset(self.space);
            }
            make.centerY.equalTo(self);
            if (obj.modeIndex == SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA) {
                make.width.mas_offset(60);
            } else {
                make.width.mas_offset(44);
            }
            make.height.mas_offset(44);
        }];
        previous = label;
    }];
    
    return labels;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = UIColor.clearColor;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    [self addGestureRecognizer:tap];
    
    if(self.items == nil || self.items.count == 0){
        return;
    }
    self.index = 0;
    self.selectMode = 0;
    
    NSMutableArray* labels = [self reloadItemViews];
    self.itemViews = [labels copy];
    [self selectItemAt:self.index];
    

}

- (void)tapHandler: (UITapGestureRecognizer*)gesture{
    
    CGPoint pt = [gesture locationInView:self];
    [self.itemViews enumerateObjectsUsingBlock:^(__kindof UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(CGRectContainsPoint(obj.frame, pt)){
            *stop = YES;
            NSUInteger oldIndex = self.index;
            NSUInteger oldMode = self.selectMode;

            self.index = idx;
            self.selectMode = obj.tag;
            
            if (oldIndex != self.index) {
                if(self.indexChangedHandler){
                    if (self.indexChangedHandler(self.selectMode, oldMode, self.index)) {
                        [self updateItemsConstraints];
                    } else {
                        self.index = oldIndex;
                        self.selectMode = oldMode;
                    }
                }
                [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    
                    [self layoutIfNeeded];
                } completion:^(BOOL finished) {}];
            }
            
        }
    }];
}


@end
