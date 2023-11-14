//
//  PhotoListCellModel.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/23.
//

#import "PhotoListCellModel.h"

@implementation PhotoListCellModel

- (instancetype)initWithName:(NSString *)name andImage:(UIImage *)image{
    self = [super init];
    if(self){
        _name = name;
        _image = image;
    }
    
    return self;
}

@end
