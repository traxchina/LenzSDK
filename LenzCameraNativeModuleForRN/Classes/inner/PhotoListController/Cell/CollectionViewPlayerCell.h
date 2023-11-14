//
//  CollectionViewPlayerCell.h
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/24.
//

#import "PhotoCollectionViewCell.h"
#import "LenzHeader.h"

NS_ASSUME_NONNULL_BEGIN

@class MoviePlayerViewController;
@interface CollectionViewPlayerCell : PhotoCollectionViewCell

@property (nonatomic, weak) IBOutlet UIView* playIconView;

@property (nonatomic, readonly) MoviePlayerViewController* playerController;

- (AVPlayer*)play;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
