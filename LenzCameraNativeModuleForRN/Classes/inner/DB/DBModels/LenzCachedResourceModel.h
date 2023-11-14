//
//  LenzCachedResourceModel.h
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/29.
//

#import <Foundation/Foundation.h>
#import "LenzSDKConstant.h"
//typedef NS_ENUM(NSInteger, LenFileType) {
//    LenFileTypeConous,
//    LenFileTypeSingle,
//    LenFileTypeMovie,
//    LenFileTypePanoram,
//    LenFileTypeAiPanoram,
//};

NS_ASSUME_NONNULL_BEGIN

@interface LenzResourceItemModel : NSObject

@property (nonatomic) NSString *idString; //唯一ID
@property (nonatomic) NSString *path; //文件存放的路径
@property (nonatomic) NSString *cameraType;//back|front
@property (nonatomic) NSString *cameraMode;//相机模式    continuous|single|video|panorama|panoramaPlus
@property (nonatomic) BOOL isRemake;
@property (nonatomic) SDKCaptureModeIndex mode;
@property (nonatomic) UIImage *image;
@property (nonatomic) UIImage *previewImage;
@property (nonatomic) NSMutableArray *keyFrame;
@property (nonatomic) BOOL isStitch;

@end



@interface LenzCachedResourceModel : NSObject

@property (nonatomic, copy) NSString* name;
@property (nonatomic, assign) NSInteger type;



@property (nonatomic) NSMutableArray <LenzResourceItemModel *> *continousArray;
@property (nonatomic) NSMutableArray <LenzResourceItemModel *> *singleArray;
@property (nonatomic) NSMutableArray <LenzResourceItemModel *> *movieArray;
@property (nonatomic) NSMutableArray <LenzResourceItemModel *> *panoramArray;
@property (nonatomic) NSMutableArray <LenzResourceItemModel *> *aiPanoramArray;

@property (nonatomic) SDKCaptureModeIndex lastIndex;
//@property (nonatomic) NSMutableArray <UIImage *> *lastShowArray;


@end

NS_ASSUME_NONNULL_END
