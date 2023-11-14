//
//  ImageCacheLRU.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/23.
//

#import "ImageCacheLRU.h"

@interface ImageCacheLRU ()

@property (nonatomic, strong) NSMutableDictionary<NSString*, ImageCacheLRUNode*>* hashTable;

@end

@implementation ImageCacheLRU

- (instancetype)init{
    self = [super init];
    if(self){
        _head = [[ImageCacheLRUNode alloc] initWithImage:nil key:@""];
        _tail = [[ImageCacheLRUNode alloc] initWithImage:nil key:@""];
        _head.next = _tail;
        _tail.previous = _head;
        _hashTable = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (UIImage *)queryByKey:(NSString *)key{
    return [self.hashTable objectForKey:key].image;
}

- (void)insertByKey:(NSString *)key image:(UIImage *)image{
    ImageCacheLRUNode* node = self.hashTable[key];
    if(node != nil){
        ImageCacheLRUNode* previous = node.previous;
        ImageCacheLRUNode* next = node.next;
        previous.next = next;
        next.previous = previous;
    }
    else{
        node = [[ImageCacheLRUNode alloc] initWithImage:image key:key];
        [self.hashTable setObject:node forKey:key];
    }
    
    node.previous = self.head;
    node.next = self.head.next;
    self.head.next = node;
    node.next.previous = node;
    
    if([self.hashTable count] > 10){
        ImageCacheLRUNode* toBeRemoved = self.hashTable[self.tail.previous.key];
        if(self.tail.previous.key != nil){
            [self.hashTable removeObjectForKey:self.tail.previous.key];
        }
        ImageCacheLRUNode* previous = toBeRemoved.previous;
        ImageCacheLRUNode* next = toBeRemoved.next;
        previous.next = next;
        next.previous = previous;
        toBeRemoved.previous = nil;
        toBeRemoved.next = nil;
    }
}

@end

@implementation ImageCacheLRUNode

- (instancetype)initWithImage:(UIImage *)image key:(nonnull NSString *)key{
    self = [super init];
    if(self){
        _image = image;
        _previous = nil;
        _next = nil;
        _key = [key copy];
    }
    
    return self;
}

@end
