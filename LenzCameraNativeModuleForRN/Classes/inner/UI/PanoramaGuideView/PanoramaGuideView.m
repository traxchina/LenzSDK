//
//  PanoramaGuideView.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/25.
//

#import "PanoramaGuideView.h"
#import <YYText/NSAttributedString+YYText.h>
#import <AVFoundation/AVFoundation.h>
#import <YYText/YYLabel.h>
#import <MetalKit/MetalKit.h>
#import "Renderer.h"
#import "LenzHeader.h"


CGFloat const PanoramaGuideViewWOrH = 120;

@interface PanoramaGuideViewPreviewContainer : MTKView

@end

@implementation PanoramaGuideViewPreviewContainer

@end

@interface PanoramaGuideView() <MTKViewDelegate>

@property (nonatomic, strong) PanoramaGuideViewPreviewContainer* container;

@property (nonatomic, assign) CGFloat aspect;

@property (nonatomic, assign) CGFloat offset;

@property (nonatomic, strong) NSTimer* timer;


@property (nonatomic, strong) UIImageView *whiteArrow;

@property (nonatomic, strong) UIView* line;
@property (nonatomic, weak) UIView* superV;
@property (nonatomic, strong)YYLabel *label;


@property (nonatomic) UIImageView *showImageView;
@property (nonatomic) PanoramaArrowDir lastArrowDir;

@property (nonatomic) NSNumber *offSetTop;
@property (nonatomic) NSNumber *offSetLeft;
@property (nonatomic) PanoramaOrientationViewDirectionEnum currentDirection;

@end

@implementation PanoramaGuideView

- (instancetype)init{
    self = [super init];
    self.backgroundColor = [UIColor jk_colorWithHexString:@"#000000" andAlpha:0.5];
    [self addSubview:self.showImageView];
    self.offSetTop = @((120-38)/2);
    self.offSetLeft = @((120-38)/2);
    return self;
}

- (void)willMoveToSuperview:(nullable UIView *)newSuperview;{
    [super willMoveToSuperview:newSuperview];
    self.superV = newSuperview;
}

- (void)updatePreviewAspect:(CGFloat)aspect{
    if(aspect > 0.01){
        self.aspect = 1.0 / aspect;
    }
    else{
        self.aspect = 1;
    }
    
    [self.container mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self).offset(self.offset);
        make.height.equalTo(self);
        //  it means aspect > 0
        make.width.equalTo(self.container.mas_height).multipliedBy(self.aspect);
    }];
}

- (void)updateOffset:(CGFloat)offset{
    self.offset = offset;
    [self.container mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(self.offset);
        make.top.equalTo(self);
        make.height.equalTo(self);
        make.width.equalTo(self.container.mas_height).multipliedBy(self.aspect);
    }];
}

- (void)direction:(PanoramaOrientationViewDirectionEnum)dir{
    self.currentDirection = dir;
    [self insertSubview:self.line atIndex:0];
    self.line.hidden = YES;
//    self.label.hidden = YES;
    [self.superV addSubview:self.label];
    [self addSubview:self.whiteArrow];
    [self.line mas_remakeConstraints:^(MASConstraintMaker *make) {
        switch (dir) {
            case PanoramaOrientationViewLeft:
            case PanoramaOrientationViewRight:
            {
                make.left.right.offset(0);
                make.height.offset(0.5);
                make.centerY.mas_equalTo(self);
            }
                break;
            case PanoramaOrientationViewUp:
            case PanoramaOrientationViewDown:
            {
                make.top.bottom.offset(0);
                make.width.offset(0.5);
                make.centerX.mas_equalTo(self);
            }
                break;
                
            default:
                break;
        }
    }];
    
    
//    [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
//        switch (dir) {
//            case PanoramaOrientationViewLeft:
//            case PanoramaOrientationViewRight:  // 横
//            {
//                make.top.mas_equalTo(self.mas_bottom).offset(5);
//                make.centerX.mas_equalTo(self.superV);
//                make.height.offset(20);
//                make.width.offset(160);
//                self.label.verticalForm = NO;
//            }
//                break;
//            case PanoramaOrientationViewUp:
//            case PanoramaOrientationViewDown: // 上下
//            {
//                make.right.mas_equalTo(self.mas_left).offset(-5);
//                make.centerY.mas_equalTo(self.superV);
//                make.width.offset(20);
//                make.height.offset(160);
//                self.label.verticalForm = YES;
//            }
//                break;
//                
//            default:
//                break;
//        }
//    }];
    [self updatePromptLabel];

    [self.showImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        switch (dir) {
            case PanoramaOrientationViewUp: {
                make.left.right.top.mas_equalTo(0);
                make.height.mas_equalTo(0);
                make.height.mas_lessThanOrEqualTo(self);

            }
                break;
            case PanoramaOrientationViewDown: {
                make.left.right.bottom.mas_equalTo(0);
                make.height.mas_equalTo(0);


            }
                break;
            case PanoramaOrientationViewLeft: {
                make.left.top.bottom.mas_equalTo(0);
                make.width.mas_equalTo(0);
                make.width.mas_lessThanOrEqualTo(self);

            }
                break;
            case PanoramaOrientationViewRight: {
                make.top.right.bottom.mas_equalTo(0);
                make.width.mas_equalTo(0);
                make.width.mas_lessThanOrEqualTo(self);
                

            }
                break;
            default:
                break;
        }
    }];
    
    [UIView animateWithDuration:0.2 animations:^{
        __block UIImage *arrow = nil;
        /// 白色的箭头
        [self.whiteArrow mas_remakeConstraints:^(MASConstraintMaker *make) {
            switch (dir) {
                case PanoramaOrientationViewLeft: //左
                {
                    
                    make.centerY.mas_equalTo(self);
                    make.left.offset(0);
                    arrow = [UIImage loadNamed:@"ai_right_arrow"];
                }
                    break;
                case PanoramaOrientationViewRight:  // 右
                {
                    make.centerY.mas_equalTo(self);
                    make.right.offset(0);
                    arrow = [UIImage loadNamed:@"ai_left_arrow"];

                }
                    break;
                case PanoramaOrientationViewUp: //上
                {
                    
                    make.centerX.mas_equalTo(self);
                    make.top.offset(0);
                    arrow = [UIImage loadNamed:@"ai_down_arrow"];
                }
                    break;
                case PanoramaOrientationViewDown: // 下
                {
                    make.centerX.mas_equalTo(self);
                    make.bottom.offset(0);
                    arrow = [UIImage loadNamed:@"ai_up_arrow"];

                }
                    break;
                    
                default:
                    break;
            }
        }];
        self.whiteArrow.image = arrow;
        [self setNeedsLayout];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.line.hidden = NO;
//        self.label.hidden = NO;
    }];
}

- (void)updatePromptLabel {
    
//    self.backgroundColor = [UIColor redColor];
//    self.superV.backgroundColor = [UIColor yellowColor];
    self.label.transform = CGAffineTransformMakeRotation(0);

    switch (self.dir) {
        case TgDirectionPortrait: {
            [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
                switch (self.orginDir) {
                    case PanoramaOrientationViewLeft:
                    case PanoramaOrientationViewRight:  // 横
                    {
                        make.top.mas_equalTo(self.mas_bottom).offset(5);
                        make.centerX.mas_equalTo(self.superV);
                        make.height.offset(20);
                        make.width.offset(160);
                        self.label.verticalForm = NO;
                    }
                        break;
                    case PanoramaOrientationViewUp:
                    case PanoramaOrientationViewDown: // 上下
                    {
                        make.right.mas_equalTo(self.mas_left).offset(-5);
                        make.centerY.mas_equalTo(self.superV);
                        make.width.offset(20);
                        make.height.offset(160);
                        self.label.verticalForm = YES;
                    }
                        break;
        
                    default:
                        break;
                }
            }];
            
        }
            break;
        case TgDirectionDown: {
            switch (self.orginDir) {
                case PanoramaOrientationViewLeft: {
                    self.label.transform = CGAffineTransformMakeRotation(-M_PI);
                    [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.bottom.mas_equalTo(self.mas_top).mas_offset(-20);
                        make.centerX.mas_equalTo(self);
                        make.height.offset(20);
                        make.width.offset(160);
                        self.label.verticalForm = NO;
                    }];

                }
                    break;
                case PanoramaOrientationViewRight:  // 横
                {
//                        self.label.transform = CGAffineTransformMakeRotation(0);
                    self.label.transform = CGAffineTransformMakeRotation(-M_PI/2);
                    [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_equalTo(self.mas_right).offset(-60);
                        make.centerY.mas_equalTo(self);
                        make.height.offset(20);
                        make.width.offset(160);
                        self.label.verticalForm = NO;
                    }];

                }
                    break;
                case PanoramaOrientationViewUp: {
                    self.label.transform = CGAffineTransformMakeRotation(M_PI);

                    [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {

                        make.right.mas_equalTo(self.mas_left).offset(-5);
                        make.centerY.mas_equalTo(self.superV);
                        make.width.offset(20);
                        make.height.offset(160);
                        self.label.verticalForm = YES;
                    }];
                }
                    break;
                case PanoramaOrientationViewDown: // 上下
                {
                    self.label.transform = CGAffineTransformMakeRotation(M_PI);

                    [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {

                        make.right.mas_equalTo(self.mas_left).offset(-5);
                        make.centerY.mas_equalTo(self.superV);
                        make.width.offset(20);
                        make.height.offset(160);
                        self.label.verticalForm = YES;
                    }];

                }
                    break;
    
                default:
                    break;
            }
            
        }
            break;
        case TgDirectionLeft: {

                switch (self.orginDir) {
                    case PanoramaOrientationViewLeft: {
//                        self.label.transform = CGAffineTransformMakeRotation(0);
                        self.label.transform = CGAffineTransformMakeRotation(M_PI/2);
                        [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
                            make.right.mas_equalTo(self.mas_left).mas_offset(60);
                            make.centerY.mas_equalTo(self);
                            make.height.offset(20);
                            make.width.offset(160);
                            self.label.verticalForm = NO;
                        }];

                    }
                        break;
                    case PanoramaOrientationViewRight:  // 横
                    {
                        
//                        self.label.transform = CGAffineTransformMakeRotation(0);
                        self.label.transform = CGAffineTransformMakeRotation(M_PI/2);
                        [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
                            make.right.mas_equalTo(self.mas_left).mas_offset(60);
                            make.centerY.mas_equalTo(self);
                            make.height.offset(20);
                            make.width.offset(160);
                            self.label.verticalForm = NO;
                        }];

                    }
                        break;
                    case PanoramaOrientationViewUp:{
                        self.label.transform = CGAffineTransformMakeRotation(M_PI/2);
                        [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
                            make.top.mas_equalTo(self.mas_bottom).offset(-60);
                            make.centerX.mas_equalTo(self.superV);
                            make.width.offset(20);
                            make.height.offset(160);
                            self.label.verticalForm = YES;
                        }];
                    }
                        break;
                    case PanoramaOrientationViewDown: // 上下
                    {
                        self.label.transform = CGAffineTransformMakeRotation(M_PI/2);
                        [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
                            make.top.mas_equalTo(self.mas_bottom).offset(-60);
                            make.centerX.mas_equalTo(self.superV);
                            make.width.offset(20);
                            make.height.offset(160);
                            self.label.verticalForm = YES;
                        }];

                    }
                        break;
        
                    default:
                        break;
                }
            
            
        }
            break;
        case TgDirectionRight: {
            switch (self.orginDir) {
                case PanoramaOrientationViewLeft: {
                    self.label.transform = CGAffineTransformMakeRotation(-M_PI/2);
                    [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_equalTo(self.mas_right).offset(-60);
                        make.centerY.mas_equalTo(self);
                        make.height.offset(20);
                        make.width.offset(160);
                        self.label.verticalForm = NO;
                    }];

                }
                    break;
                case PanoramaOrientationViewRight:  // 横
                {
                    self.label.transform = CGAffineTransformMakeRotation(-M_PI/2);
                    [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_equalTo(self.mas_right).offset(-60);
                        make.centerY.mas_equalTo(self);
                        make.height.offset(20);
                        make.width.offset(160);
                        self.label.verticalForm = NO;
                    }];

                }
                    break;
                case PanoramaOrientationViewUp:{
                    self.label.transform = CGAffineTransformMakeRotation(-M_PI/2);
                    [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(self.mas_bottom).offset(-60);
                        make.centerX.mas_equalTo(self.superV);
                        make.width.offset(20);
                        make.height.offset(160);
                        self.label.verticalForm = YES;
                    }];
                }
                    break;
                case PanoramaOrientationViewDown: // 上下
                {
                    self.label.transform = CGAffineTransformMakeRotation(-M_PI/2);
                    [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(self.mas_bottom).offset(-60);
                        make.centerX.mas_equalTo(self.superV);
                        make.width.offset(20);
                        make.height.offset(160);
                        self.label.verticalForm = YES;
                    }];

                }
                    break;
    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
}



- (void)showImageWith:(UIImage * _Nullable)image {
        
//    self.lastImage = image;
    dispatch_async(dispatch_get_main_queue(), ^{
       __block CGFloat imageWH = 0;
        if (!image) {
            self.offSetTop = @((120-38)/2);
            self.offSetLeft = @((120-38)/2);
        }
        

        self.showImageView.image = image;
        [UIView animateWithDuration:.15 animations:^{
            if (self.dir == TgDirectionPortrait) {
                if (self.orginDir == PanoramaOrientationViewDown) {
                    if (image) {
                        imageWH = (PanoramaGuideViewWOrH * image.size.height)/image.size.width;
                    }
                    [self.showImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(imageWH);
                        make.height.mas_lessThanOrEqualTo(self);
                        make.left.right.bottom.mas_equalTo(0);
                    }];
                    [self.whiteArrow mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.bottom.mas_offset(-imageWH);
                        make.left.mas_equalTo(self.offSetLeft.doubleValue);
                    }];
                } else if (self.orginDir == PanoramaOrientationViewUp) {
                    if (image) {
                        imageWH = (PanoramaGuideViewWOrH * image.size.height)/image.size.width;
                    }
                    [self.showImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.right.top.mas_equalTo(0);
                        make.height.mas_equalTo(imageWH);
                        make.height.mas_lessThanOrEqualTo(self);
                    }];
                    [self.whiteArrow mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_offset(imageWH);
                        make.left.mas_equalTo(self.offSetLeft.doubleValue);

                    }];
                } else if (self.orginDir == PanoramaOrientationViewLeft) {
                    
                    if (image) {
                        imageWH = (PanoramaGuideViewWOrH * image.size.width)/image.size.height;
                    }
                    [self.showImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.width.mas_equalTo(imageWH);
                        make.width.mas_lessThanOrEqualTo(self);
                        make.left.top.bottom.mas_equalTo(0);
                    }];
                    
                    [self.whiteArrow mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_offset(imageWH);
                        make.top.mas_equalTo(self.offSetTop.doubleValue);

                    }];
                } else if (self.orginDir == PanoramaOrientationViewRight) {
                    if (image) {
                        imageWH = (PanoramaGuideViewWOrH * image.size.width)/image.size.height;
                    }
                    [self.showImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.width.mas_equalTo(imageWH);
                        make.width.mas_lessThanOrEqualTo(self);
                        make.top.right.bottom.mas_equalTo(0);
                    }];
                    
                    [self.whiteArrow mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.right.mas_offset(-imageWH);
                        make.top.mas_equalTo(self.offSetTop.doubleValue);

                    }];
                }
                
            } else if (self.dir == TgDirectionLeft) {
                if (self.orginDir == PanoramaOrientationViewLeft) {
                    if (image) {
                        imageWH = (PanoramaGuideViewWOrH * image.size.height)/image.size.width;
                    }
                    [self.showImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.right.top.mas_equalTo(0);
                        make.height.mas_equalTo(imageWH);
                        make.height.mas_lessThanOrEqualTo(self);
                    }];
                    [self.whiteArrow mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_offset(imageWH);
                        make.left.mas_equalTo(self.offSetLeft.doubleValue);

                    }];
                } else if (self.orginDir == PanoramaOrientationViewRight) {
                    if (image) {
                        imageWH = (PanoramaGuideViewWOrH * image.size.height)/image.size.width;
                    }
                    [self.showImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(imageWH);
                        make.height.mas_lessThanOrEqualTo(self);
                        make.left.right.bottom.mas_equalTo(0);
                    }];
                    [self.whiteArrow mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.bottom.mas_offset(-imageWH);
                        make.left.mas_equalTo(self.offSetLeft.doubleValue);
                    }];
                } else if (self.orginDir == PanoramaOrientationViewUp) {
                    if (image) {
                        imageWH = (PanoramaGuideViewWOrH * image.size.width)/image.size.height;
                    }
                    [self.showImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.width.mas_equalTo(imageWH);
                        make.width.mas_lessThanOrEqualTo(self);
                        make.top.right.bottom.mas_equalTo(0);
                    }];
                    
                    [self.whiteArrow mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.right.mas_offset(-imageWH);
                        make.top.mas_equalTo(self.offSetTop.doubleValue);

                    }];
                } else if (self.orginDir == PanoramaOrientationViewDown) {

                    
                    if (image) {
                        imageWH = (PanoramaGuideViewWOrH * image.size.width)/image.size.height;
                    }
                    [self.showImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.width.mas_equalTo(imageWH);
                        make.width.mas_lessThanOrEqualTo(self);
                        make.left.top.bottom.mas_equalTo(0);
                    }];
                    
                    [self.whiteArrow mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_offset(imageWH);
                        make.top.mas_equalTo(self.offSetTop.doubleValue);

                    }];
                }
                
            } else if (self.dir == TgDirectionRight) {
                if (self.orginDir == PanoramaOrientationViewLeft) {
                    if (image) {
                        imageWH = (PanoramaGuideViewWOrH * image.size.height)/image.size.width;
                    }
                    [self.showImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(imageWH);
                        make.height.mas_lessThanOrEqualTo(self);
                        make.left.right.bottom.mas_equalTo(0);
                    }];
                    [self.whiteArrow mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.bottom.mas_offset(-imageWH);
                        make.left.mas_equalTo(self.offSetLeft.doubleValue);
                    }];
                } else if (self.orginDir == PanoramaOrientationViewRight) {
                    if (image) {
                        imageWH = (PanoramaGuideViewWOrH * image.size.height)/image.size.width;
                    }
                    [self.showImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.right.top.mas_equalTo(0);
                        make.height.mas_equalTo(imageWH);
                        make.height.mas_lessThanOrEqualTo(self);
                    }];
                    [self.whiteArrow mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_offset(imageWH);
                        make.left.mas_equalTo(self.offSetLeft.doubleValue);

                    }];
                } else if (self.orginDir == PanoramaOrientationViewUp) {
                    if (image) {
                        imageWH = (PanoramaGuideViewWOrH * image.size.width)/image.size.height;
                    }
                    [self.showImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.width.mas_equalTo(imageWH);
                        make.width.mas_lessThanOrEqualTo(self);
                        make.left.top.bottom.mas_equalTo(0);
                    }];
                    
                    [self.whiteArrow mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_offset(imageWH);
                        make.top.mas_equalTo(self.offSetTop.doubleValue);

                    }];
                } else if (self.orginDir == PanoramaOrientationViewDown) {

                    if (image) {
                        imageWH = (PanoramaGuideViewWOrH * image.size.width)/image.size.height;
                    }
                    [self.showImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.width.mas_equalTo(imageWH);
                        make.width.mas_lessThanOrEqualTo(self);
                        make.top.right.bottom.mas_equalTo(0);
                    }];
                    
                    [self.whiteArrow mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.right.mas_offset(-imageWH);
                        make.top.mas_equalTo(self.offSetTop.doubleValue);

                    }];
                }
            } else if (self.dir == TgDirectionDown) {
                if (self.orginDir == PanoramaOrientationViewLeft) {

                    if (image) {
                        imageWH = (PanoramaGuideViewWOrH * image.size.width)/image.size.height;
                    }
                    [self.showImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.width.mas_equalTo(imageWH);
                        make.width.mas_lessThanOrEqualTo(self);
                        make.top.right.bottom.mas_equalTo(0);
                    }];
                    
                    [self.whiteArrow mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.right.mas_offset(-imageWH);
                        make.top.mas_equalTo(self.offSetTop.doubleValue);

                    }];
                } else if (self.orginDir == PanoramaOrientationViewRight) {
                    if (image) {
                        imageWH = (PanoramaGuideViewWOrH * image.size.width)/image.size.height;
                    }
                    [self.showImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.width.mas_equalTo(imageWH);
                        make.width.mas_lessThanOrEqualTo(self);
                        make.left.top.bottom.mas_equalTo(0);
                    }];
                    
                    [self.whiteArrow mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_offset(imageWH);
                        make.top.mas_equalTo(self.offSetTop.doubleValue);

                    }];
                } else if (self.orginDir == PanoramaOrientationViewUp) {
                    if (image) {
                        imageWH = (PanoramaGuideViewWOrH * image.size.height)/image.size.width;
                    }
                    [self.showImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(imageWH);
                        make.height.mas_lessThanOrEqualTo(self);
                        make.left.right.bottom.mas_equalTo(0);
                    }];
                    [self.whiteArrow mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.bottom.mas_offset(-imageWH);
                        make.left.mas_equalTo(self.offSetLeft.doubleValue);
                    }];
                } else if (self.orginDir == PanoramaOrientationViewDown) {
                    if (image) {
                        imageWH = (PanoramaGuideViewWOrH * image.size.height)/image.size.width;
                    }
                    [self.showImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.right.top.mas_equalTo(0);
                        make.height.mas_equalTo(imageWH);
                        make.height.mas_lessThanOrEqualTo(self);
                    }];
                    [self.whiteArrow mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_offset(imageWH);
                        make.left.mas_equalTo(self.offSetLeft.doubleValue);

                    }];
                }
            }

            [self setNeedsLayout];
            [self layoutIfNeeded];
        }];
    });
    
    
    
}

- (void)updateArrowWith:(PanoramaArrowDir)arrowDir dir:(PanoramaOrientationViewDirectionEnum)dir {

//    self.lastArrowDir = arrowDir;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.showImageView.image) {
            return;
        }
        if (self.dir == TgDirectionPortrait || self.dir == TgDirectionDown) {
            if (dir == PanoramaOrientationViewDown || dir == PanoramaOrientationViewUp) {
                if (arrowDir == PanoramaArrowDirCenter) {
                    self.offSetLeft = @((120-38)/2);
                } else if (arrowDir == PanoramaArrowDirLeft) {
                    self.offSetLeft = @(0);
                } else if (arrowDir == PanoramaArrowDirRight) {
                    self.offSetLeft = @(120-38);
                }
            } else if (dir == PanoramaOrientationViewLeft || dir == PanoramaOrientationViewRight) {
                if (arrowDir == PanoramaArrowDirCenter) {
                    self.offSetTop = @((120-38)/2);
                } else if (arrowDir == PanoramaArrowDirUp) {
                    self.offSetTop = @(0);
                } else if (arrowDir == PanoramaArrowDirDown) {
                    self.offSetTop = @(120-38);
                }
                
            }
        } else if (self.dir == TgDirectionLeft || self.dir == TgDirectionRight) {
            if (dir == PanoramaOrientationViewLeft || dir == PanoramaOrientationViewRight) {
                if (arrowDir == PanoramaArrowDirCenter) {
                    self.offSetLeft = @((120-38)/2);
                } else if (arrowDir == PanoramaArrowDirLeft) {
                    self.offSetLeft = @(0);
                } else if (arrowDir == PanoramaArrowDirRight) {
                    self.offSetLeft = @(120-38);
                }
            } else {
                if (arrowDir == PanoramaArrowDirCenter) {
                    self.offSetTop = @((120-38)/2);
                } else if (arrowDir == PanoramaArrowDirUp) {
                    self.offSetTop = @(0);
                } else if (arrowDir == PanoramaArrowDirDown) {
                    self.offSetTop = @(120-38);
                }
            }
        }
        
        [self showImageWith:self.showImageView.image];

    });
}

- (void)clearImage {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.showImageView.image = nil;
    });
}
- (UIImage *)showDir:(PanoramaOrientationViewDirectionEnum)dir image:(UIImage *)image {
    switch (dir) {
        case PanoramaOrientationViewUp: {
            UIImage *flipImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationRight];

            return flipImage;
        }
            break;
        case PanoramaOrientationViewDown: {
            UIImage *flipImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeft];

            return flipImage;
        }
            
            
            break;
        case PanoramaOrientationViewLeft: {
            return image;
        }
            
            break;
        case PanoramaOrientationViewRight: {
            UIImage *flipImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationUpMirrored];
            return flipImage;
        }
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    self.label.hidden = hidden;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.container = [[PanoramaGuideViewPreviewContainer alloc] initWithFrame:CGRectMake(0, 0, 50, 50) device:[Renderer shared].device];
    self.container.clearColor = MTLClearColorMake(0, 0, 0, 1);
    self.container.backgroundColor = [UIColor redColor];
    [self addSubview:self.container];
    self.container.delegate = self;
    self.container.sampleCount = 1;
    self.container.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self);
        make.height.equalTo(self);
        make.width.equalTo(@(50));
    }];
    
    [[Renderer shared] setup];
    
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size{
    [[Renderer shared] mtkView:view drawableSizeWillChange:size];
}

- (void)drawInMTKView:(MTKView *)view{
    [[Renderer shared] drawInMTKView:view];
}

- (YYLabel *)label{
    if (_label == nil) {
        NSAttributedString *att = [[NSAttributedString alloc]initWithString:@"请沿箭头方向匀速拍摄"];
        _label = [[YYLabel alloc]init];
//        _label.numberOfLines = 0;
        _label.backgroundColor = [UIColor jk_colorWithHexString:@"000000" andAlpha:0.35];
        _label.attributedText = att;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.layer.cornerRadius = 3;
        _label.layer.masksToBounds = YES;
//        _label.textVerticalAlignment = YYTextVerticalAlignmentCenter; // 文字置顶显示
        _label.textColor = UIColor.whiteColor;
    }
    return _label;
}

- (UIImageView *)showImageView {
    if (!_showImageView) {
        _showImageView = [[UIImageView alloc]init];
        _showImageView.contentMode = UIViewContentModeScaleAspectFill;
        _showImageView.clipsToBounds = YES;
    }
    return _showImageView;
}
- (UIView *)line{
    if (_line == nil) {
        _line = [[UIView alloc]init];
        _line.backgroundColor = UIColor.yellowColor;
    }
    return _line;
}

- (UIImageView *)whiteArrow{
    if (_whiteArrow == nil) {
        _whiteArrow = [[UIImageView alloc]initWithImage:[UIImage loadNamed:@"ai_right_arrow"]];
    }
    return _whiteArrow;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
