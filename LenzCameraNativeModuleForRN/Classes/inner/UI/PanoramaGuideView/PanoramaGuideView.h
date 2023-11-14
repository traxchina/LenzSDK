//
//  PanoramaGuideView.h
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/25.
//

#import <UIKit/UIKit.h>
#import "PanoramaOrientationView.h"
#import "PCSDeviceOrientationManager.h"

UIKIT_EXTERN  CGFloat const PanoramaGuideViewWOrH;


typedef NS_ENUM(NSInteger, PanoramaArrowDir) {
    PanoramaArrowDirCenter,
    PanoramaArrowDirUp,
    PanoramaArrowDirDown,
    PanoramaArrowDirLeft,
    PanoramaArrowDirRight,
    
};


NS_ASSUME_NONNULL_BEGIN

@interface PanoramaGuideView : UIView

@property (nonatomic) TgDirection dir;
@property (nonatomic) PanoramaOrientationViewDirectionEnum orginDir;
//@property (nonatomic) UIImage *lastImage;


- (void)direction:(PanoramaOrientationViewDirectionEnum)dir;

- (void)updatePreviewAspect: (CGFloat)aspect;
- (void)updateOffset:(CGFloat)offset;

- (void)showImageWith:(UIImage *_Nullable)image;
//- (void)updatePromptLabelWith:(TgDirection)dir;
- (void)clearImage;

- (void)updateArrowWith:(PanoramaArrowDir)arrowDir dir:(PanoramaOrientationViewDirectionEnum)dir;

@end

NS_ASSUME_NONNULL_END
