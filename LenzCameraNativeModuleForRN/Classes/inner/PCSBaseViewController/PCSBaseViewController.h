//
//  PCSBaseViewController.h
//  PanoramicCameraSDK
//
//  Created by 王昭威 on 2023/1/14.
//
//#import "LenStitcher.h"
#import <LenzStitchSDK/LenzStitchSDK.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class BaseViewModel;
@class PCSRoundButton;
@class PCSModeList;
@class PCSBaseViewController;

typedef enum SDKCaptureModeIndex  PhotographModeEnum;

@class TimerLabel;
@protocol OperationNodeProtocol;
@class  SDKParameters;
@class PanoramaOrientationView;
@class AVCaptureVideoPreviewLayer;
@class PanoramaGuideView;


typedef void(^PCSBaseVCCompleteBLock)(NSDictionary *dict);


@interface PCSBaseViewController : UIViewController

@property (atomic, strong) UIImage* capturedImage;

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@property (nonatomic, assign, readonly) __kindof  id<OperationNodeProtocol> currentOperationNode;

@property (nonatomic, strong) NSMutableArray* totalArray;

@property (nonatomic, strong) NSMutableArray* cachesArray;

@property (nonatomic, strong) NSMutableArray* typeArray;


//@property (nonatomic, weak) IBOutlet PanoramaGuideView* panoramaGuideView;
/// 展示图片的方向
@property (nonatomic, strong) PanoramaGuideView *panoramaGuideView;

//  拍照按钮
@property (nonatomic, weak) IBOutlet PCSRoundButton* takePhotoButton;

//  闪光灯
@property (nonatomic, weak) IBOutlet UIButton* flashButton;

@property (nonatomic, weak) IBOutlet UIButton* backButton;

//  切换摄像头
@property (nonatomic, weak) IBOutlet UIButton* switchButton;

@property (nonatomic, weak) IBOutlet UIButton* discardPhotoButton;

@property (nonatomic, weak) IBOutlet UIButton* savePhotoButton;

@property (nonatomic, weak) IBOutlet PCSModeList* modeList;

@property (nonatomic, weak) IBOutlet UIImageView* resultImageView;

@property (nonatomic, weak) IBOutlet UIButton* albumButton;

@property (nonatomic, weak) IBOutlet UILabel* numberOfImagesLabel;

@property (nonatomic, weak) IBOutlet UILabel* modeLabel;

@property (nonatomic, weak) IBOutlet TimerLabel* timerLabel;

/// 控制方向
@property (nonatomic, weak) IBOutlet PanoramaOrientationView* panoramOrientationGuideView;

@property (nonatomic, weak) IBOutlet UIView* controlPanelBackground;
@property (nonatomic, weak) IBOutlet UIButton* ai_fullView;

@property (nonatomic, strong) UIView* loadingIndicator;

@property (nonatomic, strong, nullable) UIVisualEffectView* effectView;

@property (nonatomic, strong) BaseViewModel* viewModel;

@property (nonatomic, assign) PhotographModeEnum mode;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;

@property (nonatomic, strong) NSURL* recordedFileUrl;

@property (nonatomic, readonly) SDKParameters* parameters;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *safeBottom;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *safeTop;

@property (nonatomic, strong) UIPanGestureRecognizer* panGesture;
@property (nonatomic, strong) UITapGestureRecognizer* tapGesture;

@property (nonatomic) PCSBaseVCCompleteBLock completeBlock;
@property (nonatomic) UIImageView *ablumImageView;



@property (nonatomic) BOOL isVideoStitchStopedWhenRecording;

//  根据当前正在录制的视频方向返回视频预览图的方向。
@property (nonatomic, assign) UIImageOrientation thumbnailOritaionByCurrentVideoOrientation;

//+ (instancetype)makeViewController;
+ (instancetype)initWithParams:(NSDictionary *)params complete:(PCSBaseVCCompleteBLock)complete;

- (IBAction)takePhotoButtonTouchUpInside:(id)sender;
- (IBAction)takePhotoButtonTouchDownInside:(id)sender;
- (IBAction)flashButtonTouchUpInside:(id)sender;
- (IBAction)backButtonTouchUpInside:(id)sender;
- (IBAction)savePhotoButtonTouchUpInside:(id)sender;
- (IBAction)discardPhotoResultButtonTouchUpInside:(id)sender;
- (IBAction)albumButtonTouchUpInside:(id)sender;

- (void)showAlertForAuthorization;
- (void)showAlertForAuthorizationWithText: (NSString*)text;

//  do not call this method in non-init method
- (void)setup;

- (void)prepareCamera;

- (void)startCaptureSession;
- (void)stopCaptureSession;

- (void)turnTorchOff;

//  拍照界面
- (void)showPreviewView: (BOOL)show;

- (void)takeStillPhoto;

- (BOOL)startRecording;
- (void)stopRecording;

- (BOOL)startVideoDataOutputing;
- (void)stopVideoDataOutputing;


- (void)updateVideoRecodStatus;
- (void)clearSingleData;

@end

NS_ASSUME_NONNULL_END
