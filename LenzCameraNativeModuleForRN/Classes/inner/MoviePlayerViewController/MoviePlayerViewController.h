//
//  MoviePlayerViewController.h
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/24.
//

#import <UIKit/UIKit.h>
#import "LenzHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface MoviePlayerViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIView* videoView;

@property (nonatomic, strong) AVPlayer* player;

@property (nonatomic, strong) NSURL* movieFileURL;

- (void)replaceWith: (NSURL*)fileURL;

@end

NS_ASSUME_NONNULL_END
