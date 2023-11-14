//
//  MovieListCellModel.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/24.
//

#import "MovieListCellModel.h"
#import "OperationNodeMovie.h"

@implementation MovieListCellModel

- (UIImage *)image{
    return self.movieModel.thumbnail;
}

- (NSString *)name{
    return nil;
}

- (void)setName:(NSString *)name{
    
}

- (void)setImage:(UIImage *)image{
    
}

@end
