//
//  ImageCacheLRU.h
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ImageCacheLRUNode;
@interface ImageCacheLRU : NSObject

@property (nonatomic, strong) ImageCacheLRUNode* head;
@property (nonatomic, strong) ImageCacheLRUNode* tail;

- (UIImage*)queryByKey: (NSString*)key;
- (void)insertByKey: (NSString*)key image: (UIImage*)image;

@end

@interface ImageCacheLRUNode : NSObject

@property (nonatomic, copy) NSString* key;
@property (nonatomic, strong, nullable) ImageCacheLRUNode* previous;
@property (nonatomic, strong, nullable) ImageCacheLRUNode* next;
@property (nonatomic, strong, nullable) UIImage* image;

- (instancetype)initWithImage: (nullable UIImage*)image key: (NSString*)key;

@end

NS_ASSUME_NONNULL_END
