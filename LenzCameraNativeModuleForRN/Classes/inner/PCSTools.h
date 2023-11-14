//
//  PCSTools.h
//  sampleSDK
//
//  Created by 王昭威 on 2023/1/15.
//


#import <Foundation/Foundation.h>
#import "OperationNodeProtocol.h"
#import <math.h>

NS_ASSUME_NONNULL_BEGIN

extern inline CGFloat dgree_2_rad(CGFloat dgree);

extern void showAlertToDiscardCachesWithTitle(id<OperationNodeProtocol> node, NSString* title, NSString* description, WillQuitCompletionBlockType block);

@interface PCSTools : NSObject

@property (nonatomic, readonly) NSString* documentPath;
@property (nonatomic, readonly) NSString* tmpPath;
@property (nonatomic, readonly) NSURL* moviesDir;
@property (nonatomic, readonly) NSString* libraryPath;

@property (nonatomic, readonly) NSString* mainStoryboardName;

+ (NSBundle*)sdkBundle;
+ (PCSTools*)shared;

- (void)cleanDiskCache;

- (NSString*)imagePathByName: (NSString*)name;

@end

NS_ASSUME_NONNULL_END
