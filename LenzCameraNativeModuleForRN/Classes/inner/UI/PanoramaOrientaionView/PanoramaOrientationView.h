//
//  PanoramaOrientationView.h
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    PanoramaOrientationViewAny,
    PanoramaOrientationViewUp,
    PanoramaOrientationViewRight,
    PanoramaOrientationViewLeft,
    PanoramaOrientationViewDown,
    
} PanoramaOrientationViewDirectionEnum;

@protocol PanoramaOrientationViewDelegate <NSObject>

//-(void)panoramaOrientationViewslt:(PanoramaOrientationViewDirectionEnum)direction;

- (void)panoramDirDidChange;


@end
@interface PanoramaOrientationView : UIView

@property(nonatomic, weak) id<PanoramaOrientationViewDelegate>delegate;
@property (nonatomic, assign) PanoramaOrientationViewDirectionEnum selectedItemIndex;


@end

NS_ASSUME_NONNULL_END
