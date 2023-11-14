//
//  PhotoCollectionViewCell.h
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PhotoListCellModel;
@interface PhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, readonly) UIView* coverView;

@property (nonatomic, weak) IBOutlet UIImageView* imageView;

@property (nonatomic, strong) PhotoListCellModel* cellModel;

@end

NS_ASSUME_NONNULL_END
