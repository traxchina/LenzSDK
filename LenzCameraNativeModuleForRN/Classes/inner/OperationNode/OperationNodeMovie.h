//
//  OperationNodeMovie.h
//  sampleSDK
//
//  Created by 王昭威 on 2023/1/19.
//

#import <Foundation/Foundation.h>
#import "OperationNodeProtocol.h"
#import "OperationNodeVideoBase.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecordedMovieModel : NSObject

@property (nonatomic, strong) NSURL* fileUrl;
@property (nonatomic, strong) UIImage* thumbnail;

- (instancetype)initWithFileUrl: (NSURL*)fileUrl thumbnail: (UIImage*)thumbnail;

@end

@interface OperationNodeMovie : OperationNodeVideoBase <OperationNodeBackgroundProtocol>

@property (nonatomic, weak) PCSBaseViewController* ctr;

@property (nonatomic, assign, readonly) BOOL enable;

@property (nonatomic, readonly) NSArray<RecordedMovieModel*>* cachedMovies;
@property (nonatomic, assign ,readonly) BOOL isRecording;


@end

NS_ASSUME_NONNULL_END
