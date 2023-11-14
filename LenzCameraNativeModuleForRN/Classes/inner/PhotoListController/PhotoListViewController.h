//
//  PhotoListViewController.h
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MovieListCellModel;
typedef void(^DeleteImageCompletionCallBackType)(BOOL successful);
@protocol PhotoListViewControllerDelegate <NSObject>

- (void)deleteImage: (UIImage*)image completion: (DeleteImageCompletionCallBackType)completion;
- (void)deleteImageWithName: (NSString*)name completion: (DeleteImageCompletionCallBackType)completion;

- (void)deleteMovie: (MovieListCellModel*)model completion: (DeleteImageCompletionCallBackType)completion;

@end

@class AlbumCounterLabel;
@class PCSButton;
@class PhotoListCellModel;
@interface PhotoListViewController : UIViewController<UICollectionViewDelegate>

@property (nonatomic, weak, nullable) id<PhotoListViewControllerDelegate> delegate;

@property (nonatomic, strong) NSMutableArray<__kindof PhotoListCellModel*>* cellModels;

@property (nonatomic, readonly) NSInteger currentPageIndex;

@property (nonatomic, weak) IBOutlet UICollectionView* photoCollectionView;

@property (nonatomic, weak) IBOutlet PCSButton* backButton;
@property (nonatomic, weak) IBOutlet PCSButton* deleteButton;

@property (nonatomic, weak) IBOutlet AlbumCounterLabel* counterLabel;

+ (instancetype)makeViewController;

- (void)setImagesInMemory:(NSArray<UIImage *> * _Nonnull)imagesInMemory andImageNamesOnDisk:(NSArray<NSString *> * _Nonnull)imageNamesOnDisk;

- (IBAction)backButtonTouchUpInside:(id)sender;
- (IBAction)deleteButtonTouchUpInside:(id)sender;

- (void)deletedCachedResourceSuccessfulAtIndex: (NSInteger)deletedPageIndex;

@end

NS_ASSUME_NONNULL_END
