//
//  PhotoListCellModel.h
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoListCellModel : NSObject

@property (nonatomic, copy, nullable) NSString* name;
@property (nonatomic, weak, nullable) UIImage* image;

- (instancetype)initWithName: (nullable  NSString*)name andImage:(nullable UIImage*)image;

@end

NS_ASSUME_NONNULL_END
