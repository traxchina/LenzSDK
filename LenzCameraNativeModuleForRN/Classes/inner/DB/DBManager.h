//
//  DBManager.h
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class LenzCachedResourceModel;
@interface LenzDBManager : NSObject

+ (instancetype)shared;

- (void)openSqlDataBase;
- (BOOL)close;

- (BOOL)insertWithName:(NSString*)name type: (int)type;

- (void)deleteByName: (NSString*)name type: (int)type;
- (void)deleteModels: (NSArray<LenzCachedResourceModel*>*)models;

- (LenzCachedResourceModel* _Nullable)queryByName: (NSString*)name type: (int)type;

- (NSArray<LenzCachedResourceModel*>*)fetchAll;

@end

NS_ASSUME_NONNULL_END
