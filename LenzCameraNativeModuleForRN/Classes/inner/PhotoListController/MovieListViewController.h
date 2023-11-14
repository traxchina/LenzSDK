//
//  MovieListViewController.h
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/23.
//

#import "PhotoListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class RecordedMovieModel;
@interface MovieListViewController : PhotoListViewController

@property (nonatomic, copy) NSArray<__kindof RecordedMovieModel*>* movieModels;

+ (instancetype)movieMakeViewController;

@end

NS_ASSUME_NONNULL_END
