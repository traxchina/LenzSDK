//
//  DBManager.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/29.
//

#import "DBManager.h"
#import <sqlite3.h>
#import "LenzCachedResourceModel.h"
#import "LenzHeader.h"

@interface LenzDBManager ()

@property (nonatomic, strong) dispatch_queue_t serialQueue;

@end

@implementation LenzDBManager{
   sqlite3 *_db;    // 句柄
}

+ (instancetype)shared{
    static dispatch_once_t token;
    static LenzDBManager* instance = nil;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init{
    self = [super init];
    if(self){
        _serialQueue = dispatch_queue_create("db", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

// 打开数据库
- (void)openSqlDataBase {
    dispatch_sync(self.serialQueue, ^{
        // _db是数据库的句柄,即数据库的象征,如果对数据库进行增删改查,就得操作这个示例
        
        // 获取数据库文件的路径
        NSString *docPath = [PCSTools shared].documentPath;
        NSString *fileName = [docPath stringByAppendingPathComponent:@"image_disk_cache.sqlite"];
        NSLog(@"fileNamePath = %@",fileName);
        // 将 OC 字符串转换为 C 语言的字符串
        const char *cFileName = fileName.UTF8String;
        
        // 打开数据库文件(如果数据库文件不存在,那么该函数会自动创建数据库文件)
        int result = sqlite3_open(cFileName, &_db);
        
        if (result != SQLITE_OK) {  // 打开成功
            NSLog(@"打开数据库失败");
            return;
        }
        NSLog(@"打开数据库成功");
        
        // 创建表
        /**
         type
         1: photo
         2: movie
         3: others
         */
        const char *sql = "CREATE TABLE IF NOT EXISTS t_cached_resources (id integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, type integer NOT NULL, unique (name, type));";
        char *errMsg = NULL;
        
        result = sqlite3_exec(_db, sql, NULL, NULL, &errMsg);
        if (result == SQLITE_OK) {
            NSLog(@"创建表成功");
        }
        else {
            NSLog(@"创建表失败");
            printf("创表失败---%s----%s---%d",errMsg,__FILE__,__LINE__);
        }
    });
}

- (BOOL)insertWithName:(NSString*)name type: (int)type{
    __block BOOL success = NO;
    dispatch_sync(self.serialQueue, ^{
        if(_db == NULL){
            return;
        }
        
        const char *sql = "INSERT INTO t_cached_resources (name, type) VALUES (?, ?);";
        sqlite3_stmt* stmt = NULL;
        if(sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL) == SQLITE_OK){
            sqlite3_bind_text(stmt, 1, name.UTF8String, -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(stmt, 2, type);
            int ret = sqlite3_step(stmt);
            success = ret == SQLITE_DONE;
            if(ret == SQLITE_DONE){
                
            }
            else{
                NSLog(@"insert error");
            }
        }
        
        sqlite3_finalize(stmt);
    });
    
    return success;
}

- (LenzCachedResourceModel*)queryByName: (NSString*)name type: (int)type{
    __block LenzCachedResourceModel* ret = nil;
    dispatch_sync(self.serialQueue, ^{
        const char* sql = "SELECT * FROM t_cached_resources where name=? and type =?;";
        sqlite3_stmt* stmt = NULL;
        NSInteger state = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
        sqlite3_bind_text(stmt, 1, name.UTF8String, -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(stmt, 2, type);
        if (state == SQLITE_OK)
            // 成功指向一条记录
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                // 封装的实体
                LenzCachedResourceModel *model = [[LenzCachedResourceModel alloc] init];

                const unsigned char* str = sqlite3_column_text(stmt, 1);
                if(str != NULL){
                    model.name = [NSString stringWithUTF8String:(const char*)str];
                }
                model.type = sqlite3_column_int(stmt, 2);
                ret = model;
            }
        else
            NSLog(@"----- 读取数据失败 -----");
        sqlite3_finalize(stmt);
    });
    
    return ret;
}

- (void)deleteByName: (NSString*)name type: (int)type{
    dispatch_sync(self.serialQueue, ^{
        const char *sql = "DELETE FROM t_cached_resources where name=? and type =?;";
        sqlite3_stmt* stmt = NULL;
        sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
        sqlite3_bind_text(stmt, 1, name.UTF8String, -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(stmt, 2, type);
        sqlite3_step(stmt);
        sqlite3_finalize(stmt);
    });
}

- (void)deleteModels:(NSArray<LenzCachedResourceModel *> *)models{
    dispatch_sync(self.serialQueue, ^{
        const char *sql = "DELETE FROM t_cached_resources where name=? and type =?;";
        sqlite3_stmt* stmt = NULL;
        sqlite3_exec(_db, "BEGIN EXCLUSIVE TRANSACTION", 0, 0, 0);
        if(sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL) == SQLITE_OK){
            [models enumerateObjectsUsingBlock:^(LenzCachedResourceModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                sqlite3_bind_text(stmt, 1, obj.name.UTF8String, -1, SQLITE_TRANSIENT);
                sqlite3_bind_int(stmt, 2, (int)obj.type);
                sqlite3_step(stmt);
                sqlite3_reset(stmt);
            }];
        }
        if(sqlite3_finalize(stmt) != SQLITE_OK){
            NSLog(@"SQL Error: %s",sqlite3_errmsg(_db));
        }
        if (sqlite3_exec(_db, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK)
            NSLog(@"SQL Error: %s",sqlite3_errmsg(_db));
    });
}

- (NSArray<LenzCachedResourceModel*>*)fetchAll{
    NSMutableArray<LenzCachedResourceModel*>* ret = nil;
    @autoreleasepool {
        ret = [NSMutableArray array];
        dispatch_sync(self.serialQueue, ^{
            const char* sql = "SELECT * FROM t_cached_resources;";
            sqlite3_stmt* stmt = NULL;
            NSInteger state = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
            if (state == SQLITE_OK)
                // 成功指向一条记录
                while (sqlite3_step(stmt) == SQLITE_ROW) {
                    // 封装的实体
                    LenzCachedResourceModel *model = [[LenzCachedResourceModel alloc] init];

                    const unsigned char* str = sqlite3_column_text(stmt, 1);
                    if(str != NULL){
                        model.name = [NSString stringWithUTF8String:(const char*)str];
                    }
                    model.type = sqlite3_column_int(stmt, 2);
                    [ret addObject:model];
                }
            else
                NSLog(@"----- 读取数据失败 -----");
            sqlite3_finalize(stmt);
        });
    }

    return [ret copy];
}

- (BOOL)close{
    __block BOOL success = NO;
    dispatch_sync(self.serialQueue, ^{
        int ret = sqlite3_close(_db);
        success = SQLITE_OK == ret;
    });
    
    return !!success;
}

@end
