//
//  ViewController.m
//  Demo
//
//  Created by lr on 2023/2/1.
//
#import <LenzSDK/LenzCameraSDK.h>

#import "LENZViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <Masonry/Masonry.h>
#import <MobileCoreServices/MobileCoreServices.h>
//#import "LenzTensorFlow.h"

@interface LENZViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>


@property (nonatomic) UIImagePickerController *imagePickerVc;

@property (nonatomic) UIButton *takeButton;
//@property (nonatomic) LenzTensorFlow *tensor;

@property (nonatomic) UILabel *resultLabel;
@property (nonatomic) UILabel *remakeLabel;


@property (nonatomic) UITextView *textView;
@property (nonatomic) UIButton *photoButton;


@end

@implementation LENZViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.view.backgroundColor = [UIColor whiteColor];
    
        
    self.photoButton = [[UIButton alloc]init];
    self.photoButton.backgroundColor = [UIColor grayColor];
    [self.photoButton setTitle:@"打开相机" forState:UIControlStateNormal];
    [self.photoButton addTarget:self action:@selector(photoAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.photoButton];
    [self.photoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_offset(-80);
        make.width.mas_offset(80);
        make.height.mas_offset(44);
    }];
    
    self.textView = [[UITextView alloc]init];
    self.textView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(20);
        make.right.mas_offset(-20);
        make.top.mas_offset(50);
        make.bottom.mas_equalTo(self.photoButton.mas_top).mas_offset(-50);
    }];
    
}

- (void)photoAction {
    
//    {
//     "cameraMode": [{
//      "flashMode": "auto",
//      "isRemake": true,
//      "mode": "continuous",
//      "quality": 100,
//      "type": "back"
//     }, {
//      "flashMode": "auto",
//      "isRemake": true,
//      "mode": "single",
//      "quality": 100,
//      "type": "back"
//     }, {
//      "flashMode": "auto",
//      "isRemake": true,
//      "mode": "video",
//      "quantity": 0,
//      "recTime": 30,
//      "type": "back",
//      "videoQuality": 480
//     }, {
//      "flashMode": "auto",
//      "isRemake": true,
//      "mode": "parnorama",
//      "type": "back",
//      "videoQuality": 480
//     }],
//     "dataRetainedMode": "retain"
//    }
    
    self.textView.text = nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"dataRetainedMode"] = @"retain";
    NSArray *array = @[
    @{@"flashMode": @"auto", @"isRemake":@(0),@"mode":@"continuous", @"quality":@(100),@"type":@"back"  },
    @{@"flashMode": @"auto", @"isRemake":@(0),@"mode":@"single", @"quality":@(100),@"type":@"back"  },
    @{@"flashMode": @"auto", @"isRemake":@(1),@"mode":@"video", @"quality":@(100),@"type":@"back", @"videoQuality":@(480)},
    @{@"flashMode": @"auto", @"isRemake":@(1),@"mode":@"panorama", @"quality":@(100),@"type":@"back", @"videoQuality":@(1080)},
    @{@"flashMode": @"auto", @"isRemake":@(1),@"mode":@"panoramaPlus", @"quality":@(100),@"type":@"back", @"videoQuality":@(480)}
    ];
    
    
    dict[@"cameraMode"] = array;
//    dict[@"flashMode"] = @"auto";
//    dict[@"type"] = @"back";
//    dict[@"videoQuality"] = @(720);
//    dict[@"recTime"] = @(100);
//    dict[@"keyframe"] = @(1);
    [LenzCameraSDK showCameraSDKWithParams:dict presentVC:self complete:^(NSDictionary * _Nonnull dict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                               options:NSJSONWritingSortedKeys
                                                                 error:&error];
        NSString *jsonString;
        if (!jsonData) {
            NSLog(@"%@",error);
        } else {
            jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        self.textView.text = jsonString;
    }];
}

@end
