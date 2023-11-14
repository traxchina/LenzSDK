//
//  PCSPreviewViewController.h
//  LenzCameraNativeModuleForRN
//
//  Created by lr on 2023/3/11.
//

#import <UIKit/UIKit.h>
#import "LenzCachedResourceModel.h"
NS_ASSUME_NONNULL_BEGIN


typedef void(^PCSDataDidChangeBlock)(void);

@interface PCSPreviewViewController : UIViewController

@property (nonatomic) PCSDataDidChangeBlock dataChangeBlock;
@property (nonatomic) LenzCachedResourceModel *model;
@property (nonatomic) SDKCaptureModeIndex selectIndex;

@end

NS_ASSUME_NONNULL_END
