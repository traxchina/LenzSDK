//
//  MovieListCellModel.h
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/24.
//

#import "PhotoListCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@class RecordedMovieModel;
@interface MovieListCellModel : PhotoListCellModel

@property (nonatomic, strong) RecordedMovieModel* movieModel;

@end

NS_ASSUME_NONNULL_END
