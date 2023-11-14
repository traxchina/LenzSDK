//
//  PCSBaseViewController.m
//  PanoramicCameraSDK
//
//  Created by 王昭威 on 2023/1/14.
//

#import "PCSBaseViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import "CameraManager.h"
#import "PCSRoundButton.h"
#import "PCSModeList.h"
#import "UIImage+ext.h"
#import "PCSTools.h"
#import "OperationNodeProtocol.h"
#import "OperationNodeSingle.h"
#import "OperationNodeMultiple.h"
#import "OperationNodePanorama.h"
#import "QuitMultipleModeAlertViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "OperationNodeMovie.h"
#import "SDKParameters.h"
#import "PhotoListViewController.h"
#import "CustomModalViewTransition.h"
#import "MovieListViewController.h"
#import "TimerLabel.h"
#import "MoviePlayerViewController.h"
#import "PanoramaOrientationView.h"
#import "PanoramaGuideView.h"
#import "Renderer.h"
#import "CameraTextureRenderPass.h"
#import "LenzSDKConstant.h"
#import "DBManager.h"
#import <Photos/Photos.h>
#import "BaseViewTapGestureDelegate.h"
#import "MovieListCellModel.h"
#import "PreviewSingleViewController.h"
#import "OperationNodeAIPanorama.h"
#import "PhotoAlbumListViewController.h"
#import "PhotoAlbumModel.h"

//#import "LenStitcher.h"
//#import <LenzStitchSDK/LenzStitchSDK.h>

#import "LenzDataManager.h"
#import "LenzHeader.h"
#import "LenzCachedResourceModel.h"
#import "LenzDataManager.h"
#import "PCSPreviewViewController.h"
#import "SVProgressHUD.h"
#import "PCSAutherView.h"
#import "PCSDeviceOrientationManager.h"
#import "UIImage+ImageRotate.h"

#import <LenzTensorFlowSDK/LenzTensorFlow.h>

#define MODE_LIST_INDEX_2_MODE_ENUM(x) ((x))

//  PCS means panoramic camera sdk
@interface PCSBaseViewController ()<AVCapturePhotoCaptureDelegate,
                                    AVCaptureFileOutputRecordingDelegate,
                                    AVCaptureAudioDataOutputSampleBufferDelegate,
                                    UIViewControllerTransitioningDelegate,
                                    AVCaptureVideoDataOutputSampleBufferDelegate,
                                    PhotoListViewControllerDelegate,
                                    PanoramaOrientationViewDelegate,
                                    PCSDeviceOrientationDelegate>

@property (nonatomic, assign) CGFloat accX;

@property (nonatomic, nullable, readonly) AVCaptureDevice* currentCamera;
@property (nonatomic, nullable, readonly) AVCaptureDeviceInput* currentCameraInput;

@property (nonatomic, strong) AVCaptureSession* captureSession;
@property (nonatomic, strong) AVCaptureVideoDataOutput* videoDataOutput;
@property (nonatomic, strong) AVCaptureMovieFileOutput* movieFileOutput;
@property (nonatomic, strong) AVCapturePhotoOutput* photoOutput;
@property (nonatomic, strong) AVCapturePhotoSettings* outputSettings;

@property (nonatomic, copy) dispatch_queue_t videoDataQueue;

@property (nonatomic, strong) AVAssetWriter* videoWriter;
@property (nonatomic, strong) AVAssetWriterInput* videoWriterInput;

@property (nonatomic, assign) BOOL cameraPrepared;

@property (nonatomic, assign) BOOL flag;

@property (nonatomic, assign) BOOL hasCache;

@property (nonatomic, strong) UIView* focusView;

@property (nonatomic, strong, nullable) NSTimer* recordTimer;
@property (nonatomic) dispatch_source_t touchSourceTimer;
@property (nonatomic) CGFloat touchTime;


@property (nonatomic, strong, nullable) NSTimer* motionTimer;

@property (nonatomic, strong) BaseViewTapGestureDelegate* tapDelegate;
/**
 key: PhotographModeEnum
 value: subclass of OperationNodeProtocol
 */
@property (nonatomic, strong) NSDictionary<NSNumber*, id<OperationNodeProtocol>>* operationNodes;
@property (nonatomic, strong) NSArray<id<OperationNodeProtocol>>* operationNodesArray;


@property (nonatomic) dispatch_semaphore_t videoStitchSemaphore;

@property (nonatomic) LenzCachedResourceModel *resourceModel;

@property (nonatomic) UIView *stitchView;
@property (nonatomic) UIImageView *stitchImageView;
@property (nonatomic) UILabel *stitchLabel;
@property (nonatomic) CABasicAnimation *loadingAnimation;


@property (nonatomic) BOOL isStitchBigImage;
@property (nonatomic) CGFloat brightnessValue;
@property (nonatomic) CMMotionManager *motionManager;
@property (nonatomic) BOOL isTakePhoto;

@property (nonatomic) NSLock *stitchkLock;
@property (nonatomic) LenVideoStitchResult stitchResult;


@property (nonatomic) NSNumber *startPitchX;
@property (nonatomic) NSNumber *startRollY;
@property (nonatomic) LenzTensorFlow *tensorFlow;
@property (nonatomic) BOOL isContainSingleInReatinMode;
@property (nonatomic) UILabel *aiPanPromtLabel;
@property (nonatomic) UILabel *aiRecordPromtLabel;

@property (nonatomic) PCSAutherView *authView;

@property (nonatomic) dispatch_queue_t videoQueue;
@property (nonatomic) BOOL isDuringTakePhoto;
@property (nonatomic) PCSDeviceOrientationManager *orientationManager;
@property (nonatomic) TgDirection currentTgDirection;
@property (nonatomic) UIView *svContentView;

@end

@implementation PCSBaseViewController

#pragma mark - Life Circle
- (void)dealloc{
    [self stopAllSensors];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[LenzDBManager shared] close];
}


- (void)awakeFromNib{
    [super awakeFromNib];
    [self setup];
}
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.view bringSubviewToFront:self.svContentView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD setMinimumDismissTimeInterval:1.5];
    [SVProgressHUD setMaximumDismissTimeInterval:3];
    [SVProgressHUD dismissWithDelay:.5];
    [SVProgressHUD setFont:[UIFont systemFontOfSize:14]];
    self.stitchResult = -999;
    self.tensorFlow = [[LenzTensorFlow alloc]initWithFileName:@"moire_mobilenetv2_79"];
    if(@available(iOS 14, *)){
        self.videoQueue = dispatch_queue_create("com.lenzSDK.videoQueue", NULL);
    } else {
        self.videoQueue = dispatch_get_main_queue();
    }
    self.stitchkLock = [[NSLock alloc]init];
    
    self.totalArray = [[NSMutableArray alloc]init];
    self.cachesArray = [[NSMutableArray alloc]init];
    self.typeArray = [[NSMutableArray alloc]init];
    self.isContainSingleInReatinMode = NO;

    self.resourceModel = [[LenzCachedResourceModel alloc]init];
    self.motionManager = [[CMMotionManager alloc]init];
    self.motionManager.deviceMotionUpdateInterval = 1/5;
    
    
    self.orientationManager = [[PCSDeviceOrientationManager alloc] initWithDelegate:self];
    [self.orientationManager startMonitor];
    
    
    [self.view addSubview:self.panoramaGuideView];
//    [self panoramaOrientationViewslt:(PanoramaOrientationViewLeft)];
    self.panoramaGuideView.hidden = YES;
    
    [self.view addSubview:self.aiPanPromtLabel];
    [self.aiPanPromtLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.modeLabel.mas_bottom).mas_offset(20);
        make.width.mas_offset(240);
        make.height.mas_offset(20);
    }];
    
    [self.view addSubview:self.authView];
    __weak typeof(self) weakSelf = self;
    self.authView.closeBlock = ^{
        weakSelf.panGesture.enabled = YES;
    };
    [self.authView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(0);
    }];
    if (!JK_IS_IPHONE_X) {
        self.safeBottom.constant = 25;
        self.safeTop.constant = 15;
    }else{
        self.safeBottom.constant = 0;
    }
    
    [self.timerLabel updateWith:0];
    
    self.albumButton.layer.cornerRadius = 6;
    self.albumButton.clipsToBounds = YES;
    [self updateFlashButton];
    
    [PCSMotionManager shared];
    
    __weak typeof(self) weakself = self;
    [self.modeList reloadWith:self.operationNodesArray];
    self.modeList.indexChangedHandler = ^BOOL(NSUInteger newMode, NSUInteger oldMode, NSUInteger newIndex) {
        __strong typeof(weakself) strongSelf = weakself;
        if (newMode == SDK_CAPTURE_MODE_MOVIE) {
            if ([self showAuthBoth]) {
                return NO;
            }
            if ([self showAudioCamerIfNeed]) {
                return NO;
            }
        } else {
            if ([self showAuthorCamerIfNeed]) {
                return NO;
            }
        }
        
        if ([SDKParameters shared].retainedMode == SDK_DATA_RETAINED_CLEAR) {
            BOOL needAlert = NO;
            switch (self.mode) {
                case SDK_CAPTURE_MODE_CONTINUOUS:
                    needAlert = self.resourceModel.continousArray.count;
                    break;
                case SDK_CAPTURE_MODE_SINGLE:
                    needAlert = self.resourceModel.singleArray.count;
                    break;
                case SDK_CAPTURE_MODE_MOVIE:
                    needAlert = self.resourceModel.movieArray.count;

                    break;
                case SDK_CAPTURE_MODE_PANORAMA:
                    needAlert = self.resourceModel.panoramArray.count;

                    break;
                case SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA:
                    needAlert = self.resourceModel.aiPanoramArray.count;

                    break;
                    
                default:
                    break;
            }
            if (needAlert) {
//                [QuitMultipleModeAlertViewController show:self title:@"确认提醒" text:@"切换模式会清除已拍摄数据，请确认" leftBtnTitle:@"取消" rightBtnTitle:@"确定" withLeftButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
//                    [alertController dismissViewControllerAnimated:NO completion:^{}];
//                } rightButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
                    switch (self.mode) {
                        case SDK_CAPTURE_MODE_CONTINUOUS: {
                            
                            [self.resourceModel.continousArray removeAllObjects];
                            [self updateViewStatus];
                        }
                            break;
                        case SDK_CAPTURE_MODE_SINGLE: {
                            [self.resourceModel.singleArray removeAllObjects];
                            [self updateViewStatus];
                        }
                            break;
                        case SDK_CAPTURE_MODE_MOVIE:
                        {
                            [self.resourceModel.movieArray removeAllObjects];
                            [self updateViewStatus];
                        }

                            break;
                        case SDK_CAPTURE_MODE_PANORAMA:
                        {
                            [self.resourceModel.panoramArray removeAllObjects];
                            [self updateViewStatus];
                        }

                            break;
                        case SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA:
                        {
                            [self.resourceModel.aiPanoramArray removeAllObjects];
                            [self updateViewStatus];
                        }

                            break;
                            
                        default:
                            break;
                    }
                    self.modeList.index = newIndex;
                    [self.modeList updateItemsConstraints];
                    [strongSelf modeWillChange:newMode oldIndex:oldMode];
                    
                    id<OperationNodeProtocol> oldModelNode = strongSelf.currentOperationNode;
                    PhotographModeEnum mode = (PhotographModeEnum)MODE_LIST_INDEX_2_MODE_ENUM(newMode);
                    strongSelf.mode = mode;

                    self.ai_fullView.hidden = YES;
                    [strongSelf modeDidChange:newMode oldIndex:oldMode];
                    [strongSelf updateCaptureSessionWith:oldMode];
                    if([oldModelNode respondsToSelector:@selector(didQuit)]){
                        [oldModelNode didQuit];
                    }
//                }];

                return NO;
            }
        }
        
        [strongSelf modeWillChange:newMode oldIndex:oldMode];
        
        id<OperationNodeProtocol> oldModelNode = strongSelf.currentOperationNode;
        PhotographModeEnum mode = (PhotographModeEnum)MODE_LIST_INDEX_2_MODE_ENUM(newMode);
        strongSelf.mode = mode;
        self.ai_fullView.hidden = YES;
        [strongSelf modeDidChange:newMode oldIndex:oldMode];
        [strongSelf updateCaptureSessionWith:oldMode];
        if([oldModelNode respondsToSelector:@selector(didQuit)]){
            [oldModelNode didQuit];
        }
        return YES;
    };

    
    [self modeWillChange:[SDKParameters shared].modeIndex oldIndex:0lu];
    self.modeList.mode = [SDKParameters shared].modeIndex;
    self.mode = [SDKParameters shared].modeIndex;
    [self modeDidChange:[SDKParameters shared].modeIndex oldIndex:0lu];

    
    if(!self.cameraPrepared){
        [self prepareCamera];
    }
    
    [self modeDidChange:[SDKParameters shared].modeIndex oldIndex:0lu];
    [self updateCaptureSessionWith:0];
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
    [self.view addGestureRecognizer:self.panGesture];
    
    
    UIImageView* loadingImageView = [[UIImageView alloc] initWithImage:[UIImage sdkImageNamed:@"loading"]];
    self.loadingIndicator = loadingImageView;
    self.loadingIndicator.hidden = YES;
    [self.view addSubview:self.loadingIndicator];
    [loadingImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    
    self.savePhotoButton.titleLabel.textColor = [UIColor whiteColor];
    self.discardPhotoButton.titleLabel.textColor = [UIColor whiteColor];
    [self updateUIByMode];
    self.panoramOrientationGuideView.delegate = self;

    
    self.ablumImageView = [[UIImageView alloc]init];
    [self.view addSubview:self.ablumImageView];
    self.ablumImageView.layer.cornerRadius = 6;
    self.ablumImageView.layer.masksToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showPreview:)];
    [self.ablumImageView addGestureRecognizer:tap];
    self.ablumImageView.userInteractionEnabled = YES;
    self.ablumImageView.hidden = YES;
    self.ablumImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.ablumImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.takePhotoButton);
        make.left.mas_equalTo(20);
        make.width.height.mas_equalTo(60);
    }];
    
    UILongPressGestureRecognizer *ges = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGes:)];
    ges.minimumPressDuration = 1;
    [self.takePhotoButton addGestureRecognizer:ges];
    
    self.timerLabel.layer.cornerRadius = 6;
    self.timerLabel.layer.masksToBounds = YES;
    
    [self.ai_fullView addTarget:self action:@selector(alFullViewAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.stitchView];
    [self.stitchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.view);
        make.centerX.mas_equalTo(self.view);
        make.width.mas_offset(200);
        make.height.mas_offset(200);
    }];
    
    self.svContentView = [[UIView alloc]init];
    self.svContentView.backgroundColor = [UIColor clearColor];
    self.svContentView.userInteractionEnabled = NO;
    [self.view addSubview:self.svContentView];

    [self.svContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self.view addSubview:self.aiRecordPromtLabel];
    [self.aiRecordPromtLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.numberOfImagesLabel);
        make.width.mas_offset(280);
        make.height.mas_offset(20);
    }];
    
    [SVProgressHUD setContainerView:self.svContentView];
    
    self.currentTgDirection = TgDirectionPortrait;
    self.panoramaGuideView.dir = self.currentTgDirection;
    self.panoramaGuideView.orginDir = self.panoramOrientationGuideView.selectedItemIndex;
    [self directionChange:self.currentTgDirection];

}
- (PCSAutherView *)authView {
    if (!_authView) {
        _authView = [[PCSAutherView alloc]init];
        _authView.hidden = YES;
    }
    return _authView;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.panGesture.enabled = YES;

    if([self.currentOperationNode respondsToSelector:@selector(updateUI)])
        [self.currentOperationNode updateUI];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(self.cameraPrepared){
        __block  BOOL isAuthVideo = NO;
        
        switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
            case AVAuthorizationStatusAuthorized:
                isAuthVideo = YES;
                [self startCaptureSession];
                [[PCSMotionManager shared] startAccelerometerUpdates];
                break;
            case AVAuthorizationStatusNotDetermined:{
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if(granted){
                        isAuthVideo = YES;
                        [self startCaptureSession];
                        [[PCSMotionManager shared] startAccelerometerUpdates];
                    }
                    else{
                        [[NSNotificationCenter defaultCenter] postNotificationName:CameraNotificationNotPermission object:self];
                    }
                }];
                break;
            }
            case AVAuthorizationStatusDenied:{
                [[NSNotificationCenter defaultCenter] postNotificationName:CameraNotificationNotPermission object:self];
                break;
            }
            case AVAuthorizationStatusRestricted:
                break;
            default:
                break;
        }
        
        switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio]) {
            case AVAuthorizationStatusAuthorized:
                [self setupMicrophone];
                break;
            case AVAuthorizationStatusNotDetermined:{
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                    if(granted){
                        [self setupMicrophone];
                        if (self.mode != SDK_CAPTURE_MODE_MOVIE) {
                            if (!isAuthVideo) {
                                [self showAuthorCamerIfNeed];
                            }
                        }
                    }
                    else{
                        if (self.mode == SDK_CAPTURE_MODE_MOVIE) {
                            if (!isAuthVideo) {
                                [self showAuthBoth];
                            } else {
                                [self showAudioCamerIfNeed];
                            }
                        } else {
                            [self showAuthorCamerIfNeed];
                        }
                        [[NSNotificationCenter defaultCenter] postNotificationName:MicrophoneNotificationNotPermission object:self];
                    }
                }];
                break;
            }
            case AVAuthorizationStatusDenied:{
                [[NSNotificationCenter defaultCenter] postNotificationName:MicrophoneNotificationNotPermission object:self];
                break;
            }
            case AVAuthorizationStatusRestricted:
                break;
            default:
                break;
        }
    }
    
    if (self.mode == SDK_CAPTURE_MODE_MOVIE) {
        if (![self showAuthBoth]) {
            [self showAudioCamerIfNeed];
        }
    } else {
        if (![self showAuthBoth]) {
            [self showAuthorCamerIfNeed];
        }
    }
    
    
}


- (void)updateFlashButton {
    __block SDKFlashModeIndex flashModel = SDK_FLASH_MODE_AUTO;
    [[SDKParameters shared].items enumerateObjectsUsingBlock:^(SDKParametersItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.model == self.mode) {
            flashModel = obj.flashMode;
        }
    }];
    switch (flashModel) {
        case SDK_FLASH_MODE_AUTO:{
            self.outputSettings.flashMode = AVCaptureFlashModeAuto;
            [self.flashButton setImage:[UIImage sdkImageNamed:@"flash-auto-btn"] forState:UIControlStateNormal];
            break;
        }
        case SDK_FLASH_MODE_ON:{
            self.outputSettings.flashMode = AVCaptureFlashModeOn;
            [self.flashButton setImage:[UIImage sdkImageNamed:@"flash-btn"] forState:UIControlStateNormal];
            break;
        }
        case SDK_FLASH_MODE_OFF:{
            self.outputSettings.flashMode = AVCaptureFlashModeOff;
            [self.flashButton setImage:[UIImage sdkImageNamed:@"flash-disable-btn"] forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}


- (UIView *)stitchView {
    if (!_stitchView) {
        _stitchView = [[UIView alloc]init];
        [_stitchView addSubview:self.stitchImageView];
        [self.stitchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_stitchView);
            make.top.mas_equalTo(0);
            make.width.height.mas_equalTo(68);
        }];
        [_stitchView addSubview:self.stitchLabel];
        [self.stitchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.stitchImageView.mas_bottom).mas_offset(20);
            make.centerX.mas_equalTo(self.stitchImageView);
        }];
        _stitchView.hidden = YES;
    }
    return _stitchView;
}
- (UIImageView *)stitchImageView {
    if (!_stitchImageView) {
        _stitchImageView = [[UIImageView alloc]init];
        _stitchImageView.image = [UIImage loadNamed:@"loading"];
    }
    return _stitchImageView;
}
- (CABasicAnimation *)loadingAnimation {
    if (!_loadingAnimation) {
        _loadingAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        _loadingAnimation.fromValue = [NSNumber numberWithFloat:0.f];
        _loadingAnimation.toValue = [NSNumber numberWithFloat: M_PI *2];
        _loadingAnimation.duration = 3;
        _loadingAnimation.autoreverses = NO;
        _loadingAnimation.fillMode = kCAFillModeForwards;
        _loadingAnimation.repeatCount = MAXFLOAT;
    }
    return _loadingAnimation;
}
- (UILabel *)aiPanPromtLabel {
    if (!_aiPanPromtLabel) {
        _aiPanPromtLabel = [[UILabel alloc]init];
        _aiPanPromtLabel.backgroundColor = [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:.2];
        _aiPanPromtLabel.layer.cornerRadius = 6;
        _aiPanPromtLabel.layer.masksToBounds = YES;
        _aiPanPromtLabel.textColor = [UIColor whiteColor];
        _aiPanPromtLabel.font = [UIFont systemFontOfSize:14];
        _aiPanPromtLabel.text = @"请保持手机与拍摄物平行，匀速拍摄";
        _aiPanPromtLabel.hidden = YES;
        _aiPanPromtLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _aiPanPromtLabel;
}

- (UILabel *)aiRecordPromtLabel {
    if (!_aiRecordPromtLabel) {
        _aiRecordPromtLabel = [[UILabel alloc]init];
        _aiRecordPromtLabel.backgroundColor = [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:.2];
        _aiRecordPromtLabel.layer.cornerRadius = 6;
        _aiRecordPromtLabel.layer.masksToBounds = YES;
        _aiRecordPromtLabel.textColor = [UIColor whiteColor];
        _aiRecordPromtLabel.font = [UIFont systemFontOfSize:14];
        _aiRecordPromtLabel.text = @"已启动全景模式，再次点击快门将完成录制";
        _aiRecordPromtLabel.hidden = YES;
        _aiRecordPromtLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _aiRecordPromtLabel;
}
- (UILabel *)stitchLabel {
    if (!_stitchLabel) {
        _stitchLabel = [[UILabel alloc]init];
        _stitchLabel.text = @"正在拼接中，请稍等";
        _stitchLabel.font = [UIFont systemFontOfSize:12];
        _stitchLabel.textColor = [UIColor whiteColor];
    }
    return _stitchLabel;
}
#pragma mark - Private Method
- (void)alFullViewAction:(UIButton *)button {

    if (self.mode == SDK_CAPTURE_MODE_PANORAMA) {
        OperationNodePanorama *pan = nil;
        if ([self.currentOperationNode isKindOfClass:[OperationNodePanorama class]]) {
            pan = self.currentOperationNode;
            pan.needHiddenDir = !pan.needHiddenDir;
        }
        self.panoramOrientationGuideView.hidden = pan.needHiddenDir;
    } else if (self.mode == SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA) {
        OperationNodeAIPanorama *aiPan = nil;
        if ([self.currentOperationNode isKindOfClass:[OperationNodeAIPanorama class]]) {
            aiPan = self.currentOperationNode;
            aiPan.needHiddenDir = !aiPan.needHiddenDir;
        }
        self.panoramOrientationGuideView.hidden = aiPan.needHiddenDir;
    }
}

- (void)showPreview:(UITapGestureRecognizer *)tap {
    if (self.ablumImageView.hidden) {
        return;
    }
    OperationNodeVideoBase *base = nil;
    if ([self.currentOperationNode isKindOfClass:[OperationNodeVideoBase class]]) {
        base = (OperationNodeVideoBase *)self.currentOperationNode;
    }
    if (base.isRecording) {
        return;
    }
    if(self.mode != SDK_CAPTURE_MODE_SINGLE) {
        PCSPreviewViewController *vc = [[PCSPreviewViewController alloc]init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        vc.model = self.resourceModel;
        vc.selectIndex = self.mode;
        __weak typeof(self) weakSelf = self;
        vc.dataChangeBlock = ^{
            [weakSelf updateViewStatus];
        };
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        PreviewSingleViewController* dst = [[PreviewSingleViewController alloc]init];
        dst.modalPresentationStyle = UIModalPresentationFullScreen;
        dst.singleModeNode = self.currentOperationNode;
        if (self.resourceModel.singleArray.count > 0) {
            LenzResourceItemModel *model = self.resourceModel.singleArray.firstObject;
            dst.image = model.image;
        }
        [self presentViewController:dst animated:YES completion:nil];
    }
}


+ (instancetype)initWithParams:(NSDictionary *)params complete:(PCSBaseVCCompleteBLock)complete {
    [self parser:params];
    
    UIStoryboard* sb = [UIStoryboard storyboardWithName:[PCSTools shared].mainStoryboardName bundle:[PCSTools sdkBundle]];
    PCSBaseViewController *vc = (PCSBaseViewController *)[sb instantiateViewControllerWithIdentifier:@"sample"];
    vc.completeBlock = complete;
    return vc;
}

#pragma mark - Config param
+ (void)parser: (NSDictionary*)params{
    SDKParameters* sdkParams = [SDKParameters shared];
    NSString* retainedMode = params[@"dataRetainedMode"];
    if(retainedMode != nil){
      if([retainedMode isEqual:@"retain"]){
        sdkParams.retainedMode = SDK_DATA_RETAINED_RETAIN;
      }
      else if([retainedMode isEqual:@"clear"]){
        sdkParams.retainedMode = SDK_DATA_RETAINED_CLEAR;
      }
    }
  NSArray* arr = params[@"cameraMode"];
    NSDictionary<NSString*, NSNumber*>* table = @{
      @"continuous": @(SDK_CAPTURE_MODE_CONTINUOUS),
      @"single" : @(SDK_CAPTURE_MODE_SINGLE),
      @"video" : @(SDK_CAPTURE_MODE_MOVIE),
      @"panorama" : @(SDK_CAPTURE_MODE_PANORAMA),
      @"panoramaPlus" : @(SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA)
    };
    NSMutableArray<NSNumber*>* modeIndiciesTable = [NSMutableArray array];
    

    NSMutableArray *mutabArray = [NSMutableArray array];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)obj;
            NSString *mode = dict[@"mode"];
            if (!table[mode]) {
                return;
            }
            if (idx == 0) {
                sdkParams.modeIndex = (SDKCaptureModeIndex)table[mode].integerValue;
            }
            [modeIndiciesTable addObject:table[mode]];
            SDKParametersItem *item = [[SDKParametersItem alloc]init];
            NSString* cameraPosition = dict[@"type"];
            item.model = (SDKCaptureModeIndex)table[mode].integerValue;

            if(cameraPosition != nil){
              if([cameraPosition isEqual:@"back"]){
                  item.cameraPosition = SDK_CAMERA_PISITION_BACK;
                  item.cameraPositionString = cameraPosition;
              }
              else if([cameraPosition isEqual:@"front"]){
                  item.cameraPosition = SDK_CAMERA_PISITION_FRONT;
                  item.cameraPositionString = cameraPosition;
              }
            }
            

            
            NSNumber* recTime = dict[@"recTime"];
            if(recTime != nil){
                item.limitRecordTime = [recTime integerValue];
            }
            
            item.keyFrame = dict[@"keyframe"];
            item.isRemake = [dict[@"isRemake"] boolValue];
            NSNumber *quantity = dict[@"quantity"];
            if (quantity) {
                item.quantity = [quantity integerValue];
            }
            NSNumber *quality = dict[@"quality"];
            if (quality) {
                item.quality = [quality floatValue];
            }
              
            NSString* flashMode = dict[@"flashMode"];
            if(flashMode != nil){
                item.flashModeString = flashMode;
              if([flashMode isEqualToString:@"auto"]){
                  item.flashMode = SDK_FLASH_MODE_AUTO;
              }
              else if([flashMode isEqualToString:@"on"]){
                  item.flashMode = SDK_FLASH_MODE_ON;
              }
              else if([flashMode isEqualToString:@"off"]){
                  item.flashMode = SDK_FLASH_MODE_OFF;
              }
            }
            
            NSNumber* videoQualityNum = dict[@"videoQuality"];
            if(videoQualityNum != nil){
              NSInteger videoQuality = [videoQualityNum integerValue];
              if(videoQuality == 480){
                  item.videoQuality = SDK_VIDEO_QUALITY_480;
              }
              else if(videoQuality == 720){
                  item.videoQuality = SDK_VIDEO_QUALITY_720;
              }
              else if(videoQuality == 1080){
                  item.videoQuality = SDK_VIDEO_QUALITY_1080;
              }
              else if(videoQuality == 2160){
                  item.videoQuality = SDK_VIDEO_QUALITY_2160;
              }
            }
            
            NSNumber* showPreviewForPanorama = dict[@"showPreview"];
            if(showPreviewForPanorama != nil){
                item.showPreviewForPanorama = [showPreviewForPanorama boolValue];
            }
            [mutabArray addObject:item];
        }
    }];

   sdkParams.modeIndices = [modeIndiciesTable copy];

    [SDKParameters shared].items = mutabArray;
    
    

}

//  拍照界面
- (void)showPreviewView: (BOOL)show{
    self.previewLayer.hidden = !show;
    self.takePhotoButton.enabled = show;
    self.resultImageView.hidden = show;
    self.backButton.hidden = !show;
    self.flashButton.hidden = !show;
    self.switchButton.hidden = !show;
    
    self.discardPhotoButton.hidden = show;
    self.savePhotoButton.hidden = show;
    
}

- (void)setup{
    
    //  打开数据库
    [[LenzDBManager shared] openSqlDataBase];
    [LenzDataManager creatDirectory];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[PCSTools shared] cleanDiskCache];
    });
    
    _mode = SDK_CAPTURE_MODE_CONTINUOUS;
    
    _captureSession = [[AVCaptureSession alloc] init];
    _captureSession.sessionPreset = AVCaptureSessionPresetInputPriority;
    
    _movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    _videoDataQueue = dispatch_queue_create("video data", DISPATCH_QUEUE_SERIAL);
    _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    _videoDataOutput.alwaysDiscardsLateVideoFrames = YES;

    _videoDataOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                                     forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    _photoOutput = [[AVCapturePhotoOutput alloc] init];
    NSDictionary *setDic = @{AVVideoCodecKey:AVVideoCodecTypeJPEG};
    _outputSettings = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
    [_photoOutput setPhotoSettingsForSceneMonitoring:_outputSettings];
    
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    NSMutableArray* nodesArr = [NSMutableArray array];
    NSMutableDictionary* nodesDic = [NSMutableDictionary dictionary];
    __block SDKCaptureModeIndex defaultModeIndex = SDK_CAPTURE_MODE_UNKNOW;
    NSDictionary<NSNumber*, Class>* nodeClsTable = @{
        @(SDK_CAPTURE_MODE_CONTINUOUS): [OperationNodeMultiple class],
        @(SDK_CAPTURE_MODE_SINGLE): [OperationNodeSingle class],
        @(SDK_CAPTURE_MODE_MOVIE): [OperationNodeMovie class],
        @(SDK_CAPTURE_MODE_PANORAMA): [OperationNodePanorama class],
        @(SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA): [OperationNodeAIPanorama class],
    };
    
    [[SDKParameters shared].modeIndices enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([SDKParameters shared].retainedMode == SDK_DATA_RETAINED_RETAIN) {
            if (idx == 0 && obj.intValue != SDK_CAPTURE_MODE_SINGLE) {
                defaultModeIndex = (SDKCaptureModeIndex)obj.integerValue;
            } else if (idx == 1 && defaultModeIndex == SDK_CAPTURE_MODE_UNKNOW) {
                defaultModeIndex = (SDKCaptureModeIndex)obj.integerValue;
            }
        } else {
            if (idx == 0) {
                defaultModeIndex = (SDKCaptureModeIndex)obj.integerValue;
            }
        }
        if(nodeClsTable[obj] != nil){
            if ([SDKParameters shared].retainedMode == SDK_DATA_RETAINED_RETAIN && obj.intValue == SDK_CAPTURE_MODE_SINGLE) {
                self.isContainSingleInReatinMode = YES;
                return;
            } else {
                id node = [[nodeClsTable[obj] alloc] initWithController: self];
                if ([node isKindOfClass:[OperationNodeVideoBase class]]) {
                    OperationNodeVideoBase *base = (OperationNodeVideoBase *)node;
                    [[SDKParameters shared].items enumerateObjectsUsingBlock:^(SDKParametersItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.model == self.mode) {
                            base.recTime = obj.limitRecordTime;
                        }
                    }];
                    
                }
                [nodesArr addObject: node];
                nodesDic[obj] = node;
            }
        }
    }];
    if ([SDKParameters shared].retainedMode == SDK_DATA_RETAINED_RETAIN && nodesArr.count == 0 && self.isContainSingleInReatinMode) {
        // reatin模式下只有single
        id node = [[OperationNodeSingle alloc] initWithController: self];
        [nodesArr addObject: node];
        nodesDic[@(SDK_CAPTURE_MODE_SINGLE)] = node;
        defaultModeIndex = SDK_CAPTURE_MODE_SINGLE;


    }
    
    [SDKParameters shared].modeIndex = defaultModeIndex;
    _operationNodesArray = [nodesArr copy];
    _operationNodes = [nodesDic copy];


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationWillChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)startMotion {
    
    
    if (self.motionManager.deviceMotionAvailable) {
        __weak typeof(self)wearSelf = self;
        
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            if (!self.startPitchX && !self.startRollY) {
                self.startPitchX = @(motion.attitude.pitch * 100);
                self.startRollY = @(motion.attitude.roll *100);
            }
                        
            double x = self.startPitchX.doubleValue - motion.attitude.pitch * 100;
            double y = self.startRollY.doubleValue - motion.attitude.roll * 100;

            
//            NSLog(@"&&&&&&& x:%f  y:%f", x, y);
            
            
            PanoramaOrientationViewDirectionEnum dir = (PanoramaOrientationViewDirectionEnum)wearSelf.panoramOrientationGuideView.selectedItemIndex;
            if (self.currentTgDirection == TgDirectionPortrait) {
                if (dir == PanoramaOrientationViewLeft || dir == PanoramaOrientationViewRight) {
                    if (fabs(x) < 3) {
//                        NSLog(@"~~~~~~~~~~~~~~~  中");
                        [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirCenter dir:dir];
                    } else {
                        if (x > 0) {
//                            NSLog(@"~~~~~~~~~~~~~~~  下");
                            [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirDown dir:dir];
                        } else {
//                            NSLog(@"~~~~~~~~~~~~~~~  上");
                            [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirUp dir:dir];
                        }
                    }
                } else if (dir == PanoramaOrientationViewUp || dir == PanoramaOrientationViewDown) {
                    
                    if (fabs(y) < 3) {
//                        NSLog(@"~~~~~~~~~~~~~~~  中");
                        [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirCenter dir:dir];
                    } else {
                        if (y > 0) {
//                            NSLog(@"~~~~~~~~~~~~~~~  左");
                            [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirLeft dir:dir];
                        } else {
//                            NSLog(@"~~~~~~~~~~~s~~~~  右");
                            [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirRight dir:dir];
                        }
                    }
                }
            } else if (self.currentTgDirection == TgDirectionLeft) {
                if (dir == PanoramaOrientationViewLeft || dir == PanoramaOrientationViewRight) {
                    
                    if (fabs(y) < 3) {
//                        NSLog(@"~~~~~~~/~~~~~~~~  中");
                        [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirCenter dir:dir];
                    } else {
                        if (y > 0) {
//                            NSLog(@"~~~~~~~~~~~~~~~  上");
                            [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirRight dir:dir];
                        } else {
                            [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirLeft dir:dir];

//                            NSLog(@"~~~~~~~~~~~~~~~  下");
                        }
                    }
                    
                } else if (dir == PanoramaOrientationViewUp || dir == PanoramaOrientationViewDown) {
                    
                    if (fabs(x) < 3) {
//                        NSLog(@"~~~~~~~~~~~~~~~  中");
                        [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirCenter dir:dir];
                    } else {
                        if (x > 0) {
//                            NSLog(@"~~~~~~~~~~~~~~~  下");
                            [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirDown dir:dir];
                        } else {
//                            NSLog(@"~~~~~~~~~~~~~~~  上");
                            [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirUp dir:dir];
                        }
                    }
                }
            } else if (self.currentTgDirection == TgDirectionRight) {
                if (dir == PanoramaOrientationViewLeft || dir == PanoramaOrientationViewRight) {
                    
                    if (fabs(y) < 3) {
//                        NSLog(@"~~~~~~~~~~~~~~~  中");
                        [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirCenter dir:dir];
                    } else {
                        if (y > 0) {
//                            NSLog(@"~~~~~~~~~~~~~~~  上");
                            [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirRight dir:dir];
                        } else {
                            [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirLeft dir:dir];

//                            NSLog(@"~~~~~~~~~~~~~~~  下");
                        }
                    }
                    
                } else if (dir == PanoramaOrientationViewUp || dir == PanoramaOrientationViewDown) {
                    
                    if (fabs(x) < 3) {
//                        NSLog(@"~~~~~~~~~~~~~~~  中");
                        [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirCenter dir:dir];
                    } else {
                        if (x > 0) {
//                            NSLog(@"~~~~~~~~~~~~~~~  下");
                            [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirDown dir:dir];
                        } else {
//                            NSLog(@"~~~~~~~~~~~~~~~  上");
                            [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirUp dir:dir];
                        }
                    }
                }
            } else if (self.currentTgDirection == TgDirectionDown) {
                if (dir == PanoramaOrientationViewLeft || dir == PanoramaOrientationViewRight) {
                    if (fabs(x) < 3) {
//                        NSLog(@"~~~~~~~~~~~~~~~  中");
                        [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirCenter dir:dir];
                    } else {
                        if (x > 0) {
//                            NSLog(@"~~~~~~~~~~~~~~~  下");
                            [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirDown dir:dir];
                        } else {
//                            NSLog(@"~~~~~~~~~~~~~~~  上");
                            [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirUp dir:dir];
                        }
                    }
                } else if (dir == PanoramaOrientationViewUp || dir == PanoramaOrientationViewDown) {
                    
                    if (fabs(y) < 3) {
//                        NSLog(@"~~~~~~~~~~~~~~~  中");
                        [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirCenter dir:dir];
                    } else {
                        if (y > 0) {
//                            NSLog(@"~~~~~~~~~~~~~~~  左");
                            [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirLeft dir:dir];
                        } else {
//                            NSLog(@"~~~~~~~~~~~~~~~  右");
                            [wearSelf.panoramaGuideView updateArrowWith:PanoramaArrowDirRight dir:dir];
                        }
                    }
                }
            }
    
            
        }];
    }
}
- (void)stopMotion {
    [self.motionManager stopDeviceMotionUpdates];
    self.startPitchX = nil;
    self.startRollY = nil;
    [self.panoramaGuideView showImageWith:nil];
//    LenVideoStitchDirction dir = (LenVideoStitchDirction)self.panoramOrientationGuideView.selectedItemIndex;
//    [self.panoramaGuideView updateArrowWith:PanoramaArrowDirCenter dir:dir];
}
#pragma mark - Lazy Load
- (BaseViewTapGestureDelegate *)tapDelegate{
    if(_tapDelegate == nil){
        _tapDelegate = [[BaseViewTapGestureDelegate alloc] init];
        _tapDelegate.controller = self;
    }
    
    return _tapDelegate;
}

- (AVCaptureDevice *)currentCamera{
    __block AVCaptureDevice* camera = nil;
    [self.captureSession.inputs enumerateObjectsUsingBlock:^(__kindof AVCaptureInput * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AVCaptureDeviceInput* inputDevice = obj;
        if([inputDevice.device hasMediaType:AVMediaTypeVideo]){
            camera = inputDevice.device;
            *stop = YES;
        }
    }];
    return self.currentCameraInput.device;
}

- (AVCaptureDeviceInput*)currentCameraInput{
    __block AVCaptureDeviceInput* cameraInput = nil;
    [self.captureSession.inputs enumerateObjectsUsingBlock:^(__kindof AVCaptureInput * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AVCaptureDeviceInput* inputDevice = obj;
        if([inputDevice.device hasMediaType:AVMediaTypeVideo]){
            cameraInput = inputDevice;
            *stop = YES;
        }
    }];
    return cameraInput;
}

- (SDKParameters *)parameters{
    return [SDKParameters shared];
}

#pragma mark - Action
- (void)focusOn: (CGPoint)point{

    CGPoint pt = [self.previewLayer captureDevicePointOfInterestForPoint:point];
    AVCaptureDevice* curr = self.currentCamera;
    [[CameraManager shared] focusOn:pt device:curr];
    [self showFocusViewAt:point];
}

- (void)showFocusViewAt: (CGPoint)point{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideFocusView) object:nil];
    if(self.focusView == nil){
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 42, 42)];
        imgView.image = [UIImage sdkImageNamed:@"focus"];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        self.focusView = imgView;
        [self.view addSubview:self.focusView];
    }
    self.focusView.hidden = NO;
    CABasicAnimation* flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    flash.duration = 0.2;
    flash.fromValue = @(1);
    flash.toValue = @(0.1);
    flash.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    flash.autoreverses = YES;
    flash.repeatCount = 3;
    [self.focusView.layer removeAnimationForKey:@"flash"];
    
    [self.focusView.layer addAnimation:flash forKey:@"flash"];
    self.focusView.frame = CGRectMake(point.x - 21, point.y - 21, 42, 42);
    [self performSelector:@selector(hideFocusView) withObject:nil afterDelay:3];
}

- (void)hideFocusView{
    [self.focusView.layer removeAnimationForKey:@"flash"];
    self.focusView.hidden = YES;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{

    if(error != nil){
        return;
    }
    if(self.mode == SDK_CAPTURE_MODE_SINGLE){
        [self stopCaptureSession];
        [[PCSMotionManager shared] stopAccelerometerUpdates];
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
    else{
        [self startCaptureSession];
        [self showPreviewView:YES];
    }
}



- (AVCaptureVideoOrientation)videoOrientation{
    UIDeviceOrientation curr = UIDeviceOrientationUnknown;
    return [self videoOrientation:&curr];
}

- (AVCaptureVideoOrientation)videoOrientation:(UIDeviceOrientation*)currentDeviceOrientation{

    return [[PCSMotionManager shared] videoOrientation:currentDeviceOrientation];;
}

- (void)takeStillPhoto:(AVCaptureVideoPreviewLayer*)previewLayer {

    if ([self showAuthorCamerIfNeed]) {
        self.panGesture.enabled = YES;
        self.isDuringTakePhoto = NO;
        return;
    }

    AVCaptureConnection *connection = [self.photoOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([connection isVideoStabilizationSupported]) {
//        connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
    if(connection == nil){
        self.panGesture.enabled = YES;
        self.isDuringTakePhoto = NO;
        return;
    }
    if (connection.supportsVideoOrientation) {
        // 根据motion设置照片方向
        AVCaptureVideoOrientation videoOrientation = [self videoOrientation];
        connection.videoMirrored = self.currentCamera == [CameraManager shared].front;
        connection.videoOrientation = videoOrientation;
    }
    // 创建 AVCapturePhotoSettings
    AVCapturePhotoSettings *photoSettings = [AVCapturePhotoSettings photoSettings];
    if ([self.photoOutput.availablePhotoCodecTypes containsObject:AVVideoCodecTypeJPEG]) {
        NSDictionary *format = @{AVVideoCodecKey: AVVideoCodecTypeJPEG};
        photoSettings = [AVCapturePhotoSettings photoSettingsWithFormat:format];
        if (self.currentCameraInput.device.position == SDK_CAMERA_PISITION_BACK) {
            photoSettings.flashMode = self.outputSettings.flashMode;
        
        }
        photoSettings.previewPhotoFormat = @{
            (NSString*)kCVPixelBufferPixelFormatTypeKey : photoSettings.availablePreviewPhotoPixelFormatTypes.firstObject,
            (NSString*)kCVPixelBufferWidthKey: @(160),
            (NSString*)kCVPixelBufferHeightKey: @(160),
        };
    }
    photoSettings.autoStillImageStabilizationEnabled = YES;
    // 拍照
    
    [self.photoOutput capturePhotoWithSettings:photoSettings delegate:self];
}


#pragma mark - Notification
- (void)orientationWillChange: (NSNotification*)noti{
}
- (void)willEnterForeground: (NSNotification*)noti{
}

//UIBackgroundTaskIdentifier _bgTaskToken;
- (void)willEnterBackground: (NSNotification*)noti{
    
    if([self.currentOperationNode conformsToProtocol:@protocol(OperationNodeBackgroundProtocol)]){
        id<OperationNodeBackgroundProtocol> obj = self.currentOperationNode;
        if ([obj respondsToSelector:@selector(willEnterBackground:)]) {
            [obj willEnterBackground:noti];
        }
    }
}

- (void)orientationDidChange: (NSNotification*)noti{
    if([self.currentOperationNode respondsToSelector:@selector(stop)])
        [self.currentOperationNode stop];
}

#pragma mark - alert
- (void)showAlertForAuthorizationWithText: (NSString*)text{
    [QuitMultipleModeAlertViewController show:self title:@"" text:text leftBtnTitle:@"取消" rightBtnTitle:@"确认" withLeftButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
        
        [alertController dismissViewControllerAnimated:YES completion:^{
        }];
    } rightButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
        [alertController dismissViewControllerAnimated:YES completion:^{
            NSURL* url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if(url != nil){
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                }];
            }
            
        }];
    }];
}

- (void)showAlertForAuthorization{
    [self showAlertForAuthorizationWithText:@"请在系统设置里打开摄像机访问权限后重试"];
}

- (BOOL)showAuthBoth {
    __block BOOL showVideoAlert = NO;
    AVAuthorizationStatus staus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (staus) {
        case AVAuthorizationStatusDenied:{
            showVideoAlert =  YES;
            break;
        }
        default:
            showVideoAlert = NO;
            break;
    }
    
    __block BOOL showAlert = NO;
    
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio]) {

        case AVAuthorizationStatusDenied:{
            showAlert =  YES;
            break;
        }

        default:
            showAlert = NO;
            break;
    }
    if (showVideoAlert && showAlert) {
        self.panGesture.enabled = NO;
        [self.authView showAutherWith:PCSAuthPhoneAndMir];
        return  YES;
    }
    return NO;
    
}
    
- (BOOL)showAuthorCamerIfNeed {
    __block BOOL showAlert = NO;
    AVAuthorizationStatus staus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (staus) {
        case AVAuthorizationStatusDenied:{
            [self.authView showAutherWith:PCSAuthPhone];
            self.panGesture.enabled = NO;
            showAlert =  YES;
            break;
        }
        default:
            showAlert = NO;
            break;
    }
    return showAlert;
}
    
- (BOOL)showAudioCamerIfNeed {
    __block BOOL showAlert = NO;
    
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio]) {

        case AVAuthorizationStatusDenied:{
            [self.authView showAutherWith:PCSAuthMir];
            self.panGesture.enabled = NO;
            showAlert =  YES;
            break;
        }

        default:
            showAlert = NO;
            break;
    }
    
    return showAlert;
}

#pragma mark - Capture
- (void)takeStillPhoto{
    if (self.isDuringTakePhoto) {
        return;
    }
    self.panGesture.enabled = NO;
    self.isDuringTakePhoto = YES;
    [self takeStillPhoto:self.previewLayer];
}

- (BOOL)startRecording{

    if (![self showAuthBoth]) {
        if ([self showAuthorCamerIfNeed] || [self showAudioCamerIfNeed]) {
            return NO;
        }
    } else {
        return NO;
    }
    
    if(self.movieFileOutput.isRecording){
        return NO;
    }
    
    
    [[SDKParameters shared].items enumerateObjectsUsingBlock:^(SDKParametersItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.model == self.mode) {
            self.movieFileOutput.maxRecordedDuration = CMTimeMake(obj.limitRecordTime, 1);
        }
    }];
    
    [self.recordTimer invalidate];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.recordTimer = [NSTimer timerWithTimeInterval:0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            if (self.movieFileOutput.recordedDuration.timescale > 600) {
                [self.timerLabel updateWith:self.movieFileOutput.recordedDuration.value / self.movieFileOutput.recordedDuration.timescale];
            }
        }];
        [[NSRunLoop currentRunLoop] addTimer:self.recordTimer forMode:NSDefaultRunLoopMode];
    });
    
    NSURL* tmpMovieFileUrl = [NSURL fileURLWithPath:[LenzDataManager moviePath]];
    AVCaptureConnection* connection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([connection isVideoStabilizationSupported]) {
//        connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
    if(connection == nil){
        return NO;
    }
    
    UIDeviceOrientation currOrientation = UIDeviceOrientationUnknown;
    connection.videoOrientation = [self videoOrientation:&currOrientation];
    AVCaptureDevice* camera = self.currentCamera;
    [camera lockForConfiguration:nil];
    if ([camera hasFlash] && self.currentCameraInput.device.position == SDK_CAMERA_PISITION_BACK) {
        if (self.outputSettings.flashMode == AVCaptureFlashModeOff) {
            [camera setTorchMode:AVCaptureTorchModeOff];
        } else if (self.outputSettings.flashMode == AVCaptureFlashModeOn) {
            [camera setTorchMode:AVCaptureTorchModeOn];
        } else {
            [camera setTorchMode:AVCaptureTorchModeAuto];
        }
    }
    [camera unlockForConfiguration];
    self.thumbnailOritaionByCurrentVideoOrientation = [UIImage imageOrientationByDeviceOrientation:currOrientation isFrontCamera:camera == [CameraManager shared].front];
    if (connection.supportsVideoOrientation) {
        if (self.currentTgDirection == TgDirectionLeft) {
            connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        } else if (self.currentTgDirection == TgDirectionRight) {
            connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        } else if (self.currentTgDirection == TgDirectionPortrait) {
            connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        } else {
            connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
        }
    }
    [self.movieFileOutput startRecordingToOutputFileURL: tmpMovieFileUrl recordingDelegate:self];

    return YES;
}

- (void)stopRecording{
    [self.movieFileOutput stopRecording];
    AVCaptureDevice* camera = self.currentCamera;
    [camera lockForConfiguration:nil];
    if ([camera hasFlash] && self.currentCameraInput.device.position == SDK_CAMERA_PISITION_BACK) {
        [camera setTorchMode:AVCaptureTorchModeOff];
    }
    [camera unlockForConfiguration];
    [self.recordTimer invalidate];
    self.recordTimer = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.timerLabel updateWith:0];
    });
}

- (BOOL)startVideoDataOutputing{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PCS_NotificationNameOrientationDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:PCS_NotificationNameOrientationDidChange object:nil];
    UIDeviceOrientation deviceOrientation = UIDeviceOrientationPortrait;
    AVCaptureVideoOrientation orientation = [self videoOrientation:&deviceOrientation];
    CGFloat degree = 0;
    AVCaptureDevice* camera = self.currentCamera;

    
    CameraManager* cameraMgr = [CameraManager shared];
    BOOL isFront = camera == cameraMgr.front;
    BOOL isLandscape = NO;
    //  前摄像头需要镜像一下
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            degree = 0;
            break;
        case UIDeviceOrientationLandscapeRight:
            degree = isFront ? 90 : -90;
            isLandscape = YES;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            degree = 180;
            break;
        case UIDeviceOrientationLandscapeLeft:
            degree = isFront ? -90 : 90;
            isLandscape = YES;
            break;
        default:
            break;
    }
    
    __block BOOL ret = NO;
    dispatch_sync(self.videoDataQueue, ^{
        if(self.videoDataOutput.sampleBufferDelegate != nil){
            return;
        }
        if([self configureVideoWritter]){
            AVCaptureConnection *connection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([connection isVideoStabilizationSupported]) {
//                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
            if(connection == nil){
                return;
            }
            [connection setVideoOrientation:orientation];
            CGFloat aspect = isFront ? cameraMgr.frontAspect : cameraMgr.backAspect;
            aspect = isLandscape ? 1.0 / aspect : aspect;
            [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataQueue];
//            [self.captureSession startRunning];
            ret = YES;
        }
    });
    
    return ret;
}

- (PanoramaGuideView *)panoramaGuideView{
    if (_panoramaGuideView == nil) {
        _panoramaGuideView = [[PanoramaGuideView alloc]init];
        _panoramaGuideView.hidden = YES;
    }
    return _panoramaGuideView;;
}

- (void)stopVideoDataOutputing{
    [self.motionTimer invalidate];
    self.motionTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PCS_NotificationNameOrientationDidChange object:nil];
    dispatch_async(self.videoDataQueue, ^{

        
        [self.videoDataOutput setSampleBufferDelegate:nil queue:nil];
//        [self.captureSession stopRunning];
        [Renderer shared].cameraPass.texture = nil;
        
    });
    [self stopMotion];
    [self.panoramaGuideView showImageWith:nil];
    
    self.aiRecordPromtLabel.hidden = YES;
//    [self updateViewStatus];

}
- (void)updateViewStatusWhenStitchSave:(BOOL)isSaveIng {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.stitchView.hidden = !isSaveIng;
        if (self.stitchView.hidden) {
            [self.stitchImageView.layer removeAnimationForKey:@"loadingAnimation"];
        } else {
            [self.stitchImageView.layer addAnimation:self.loadingAnimation forKey:@"loadingAnimation"];
        }
        self.flashButton.hidden = isSaveIng;
        if (self.mode == SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA) {
            self.panoramOrientationGuideView.hidden = isSaveIng;
            self.ai_fullView.hidden = YES;
            self.panoramaGuideView.hidden = YES;
        } else {
            self.panoramOrientationGuideView.hidden = isSaveIng;
            self.ai_fullView.hidden = YES;
            self.panoramaGuideView.hidden = isSaveIng;
        }
        self.modeList.hidden = isSaveIng;
        self.savePhotoButton.hidden = isSaveIng;
        self.takePhotoButton.hidden = isSaveIng;
        self.discardPhotoButton.hidden = isSaveIng;
        self.backButton.hidden = !isSaveIng;
        self.ablumImageView.hidden = isSaveIng;
    });

}

- (void)updateViewStatusWhenStitchFail {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.stitchView.hidden = YES;
        self.flashButton.hidden = NO;
        self.modeList.hidden = NO;
        self.savePhotoButton.hidden = NO;
        self.takePhotoButton.hidden = NO;
        if (self.mode == SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA) {
            self.ai_fullView.hidden = YES;
            self.panoramOrientationGuideView.hidden = NO;
            self.panoramaGuideView.hidden = YES;
        } else {
            self.ai_fullView.hidden = YES;
            self.panoramOrientationGuideView.hidden = NO;
            self.panoramaGuideView.hidden = NO;
        }
        self.discardPhotoButton.hidden = NO;
        self.backButton.hidden = YES;
        self.ablumImageView.hidden = NO;
        [self.takePhotoButton setImage:[UIImage loadNamed:@"take-photo-btn"] forState:UIControlStateNormal];
    });
}

- (BOOL)getStitchBigImageIfNeed {
    BOOL isSuccess = NO;
    NSString *s = [LenStitcher getCurrentPanoramaShow];
    if (s.length) {
        isSuccess = YES;
    }
    return isSuccess;
}

- (BOOL)configureVideoWritter{
    //  setup asset writter for the video data output
    NSURL* tmpMovieFileUrl = [NSURL fileURLWithPath:[[PCSTools shared].tmpPath stringByAppendingPathComponent:@"video-data-tmp-file.mov"] isDirectory:NO];
    NSError* err = nil;
    [[NSFileManager defaultManager] removeItemAtURL:tmpMovieFileUrl error:nil];
    self.videoWriter = [[AVAssetWriter alloc] initWithURL:tmpMovieFileUrl fileType:AVFileTypeQuickTimeMovie error:&err];
    if(err != nil){
        self.videoWriter = nil;
        return NO;
    }
    
    [[SDKParameters shared].items enumerateObjectsUsingBlock:^(SDKParametersItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.model == self.mode) {
            NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                      AVVideoCodecTypeH264, AVVideoCodecKey,
                                      [NSNumber numberWithInteger: obj.resolution.width], AVVideoWidthKey,
                                      [NSNumber numberWithInteger: obj.resolution.height], AVVideoHeightKey,
                                      nil];
            self.videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
        }
    }];
    
    self.videoWriterInput.expectsMediaDataInRealTime = YES;
    
    [self.videoWriter addInput:self.videoWriterInput];
    
    return YES;
}

- (void)prepareCamera{
    if (self.cameraPrepared) {
        return;
    }
    __block AVCaptureDevice* device = nil;
    [[SDKParameters shared].items enumerateObjectsUsingBlock:^(SDKParametersItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.model == self.mode) {
            device = obj.cameraPosition == SDK_CAMERA_PISITION_BACK ? [CameraManager shared].back : [CameraManager shared].front;
        }
    }];
    
    if (device == nil) {
        self.cameraPrepared = false;
        return;
    }
    
    NSError* error;
    AVCaptureDeviceInput* input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if(error != nil){
        self.cameraPrepared = false;
        return;
    }
    [self.captureSession beginConfiguration];
    if([self.captureSession canAddInput:input]){
        [self.captureSession addInput:input];
    }
    else{
        return;
    }
    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.previewLayer.frame = self.view.layer.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer insertSublayer:self.previewLayer atIndex:0u];
    
    if([self.captureSession canAddOutput:self.photoOutput]){
        [self.captureSession addOutput:self.photoOutput];
    }
    
    if([self.captureSession canAddOutput:self.movieFileOutput]){
        [self.captureSession addOutput:self.movieFileOutput];
    }
    
    [self.captureSession commitConfiguration];
    self.cameraPrepared = YES;
    [[SDKParameters shared].items enumerateObjectsUsingBlock:^(SDKParametersItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.model == self.mode) {
            [[CameraManager shared] setResolutionFor:AVCaptureDevicePositionBack with:obj.resolution.height model:self.mode];
//            [[CameraManager shared] setResolutionFor:AVCaptureDevicePositionFront with:obj.resolution.height model:self.mode];
        }
    }];
    

    [self updatePreViewLayer];
}

#pragma mark - Gesture
- (void)tapGestureHandler: (UITapGestureRecognizer*)gesture{
    switch(gesture.state){
        case UIGestureRecognizerStateBegan:{
            break;
        }
        case UIGestureRecognizerStateChanged:{
            break;
        }
        case UIGestureRecognizerStateEnded:{
            CGPoint pt = [gesture locationInView:self.view];
            [self focusOn:pt];
            break;
        }
        case UIGestureRecognizerStateCancelled:{
            break;
        }
        default:
            break;
    }
}

- (void)panGestureHandler: (UIPanGestureRecognizer*)gesture{
    switch(gesture.state){
        case UIGestureRecognizerStateBegan:{
            break;
        }
        case UIGestureRecognizerStateChanged:{
            if(self.flag){
                return;
            }
            self.flag = YES;
            CGPoint translation = [gesture translationInView:self.view];
            [self.modeList updateIndexByTanslation:translation];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            self.flag = NO;
            break;
        }
        case UIGestureRecognizerStateCancelled:{
            self.flag = NO;
            break;
        }
        default:
            self.flag = NO;
            break;
    }
}

#pragma mark - orientation
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskPortrait;
//}


- (void)updateUIByMode{
    self.albumButton.hidden = YES;
    self.numberOfImagesLabel.hidden = YES;
    self.modeLabel.text = self.currentOperationNode.modeTitleString;
    self.ai_fullView.hidden = YES;
    self.panGesture.enabled = YES;
    if([self.currentOperationNode respondsToSelector:@selector(updateUI)]){
        [self.currentOperationNode updateUI];
    }
    [self updatePreViewLayer];
    [self updateUIByDir];
    if ((self.mode == SDK_CAPTURE_MODE_PANORAMA || self.mode == SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA) && self.panoramOrientationGuideView.selectedItemIndex == PanoramaOrientationViewAny) {
        self.aiPanPromtLabel.hidden = NO;
    } else {
        self.aiPanPromtLabel.hidden = YES;
    }
}

- (void)updateUIByDir {
    if (self.mode == SDK_CAPTURE_MODE_PANORAMA) {
        [self updatePanormaViewWith:self.currentTgDirection];
    } else {
        [self.modeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view);
            make.centerY.mas_equalTo(self.flashButton);
        }];
        self.modeLabel.transform = CGAffineTransformMakeRotation(0);
        [self.timerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.modeLabel);
        }];
        self.timerLabel.transform = CGAffineTransformMakeRotation(0);
    }
}

- (void)updatePreViewLayer {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    self.previewLayer.frame = CGRectMake(0, 0, width, height);

    switch (self.mode) {
        case SDK_CAPTURE_MODE_CONTINUOUS: {
            self.switchButton.hidden = NO;
            self.panoramaGuideView.hidden = YES;
            self.panoramOrientationGuideView.hidden = YES;
//            self.previewLayer.frame = CGRectMake(0, (height - width*4/3)/2, width, width*4/3);
        }
            
            break;
        case SDK_CAPTURE_MODE_SINGLE: {
            self.switchButton.hidden = NO;
            self.panoramaGuideView.hidden = YES;
            self.panoramOrientationGuideView.hidden = YES;
//            self.previewLayer.frame = CGRectMake(0, (height - width*4/3)/2, width, width*4/3);
        }
            
            break;
        case SDK_CAPTURE_MODE_MOVIE: {
            self.switchButton.hidden = NO;
            self.panoramaGuideView.hidden = YES;
            self.panoramOrientationGuideView.hidden = YES;
//            self.previewLayer.frame = CGRectMake(0, 0, width, height);

        }
            
            break;
        case SDK_CAPTURE_MODE_PANORAMA: {
            self.switchButton.hidden = YES;
            self.panoramaGuideView.hidden = NO;
            self.panoramOrientationGuideView.hidden = NO;
//            self.previewLayer.frame = CGRectMake(0, (height - width*16/9)/2, width, width*16/9);

        }
            
            break;
        case SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA: {
            self.switchButton.hidden = YES;
            self.panoramaGuideView.hidden = YES;
            self.panoramOrientationGuideView.hidden = NO;
//            self.previewLayer.frame = CGRectMake(0, (height - width*16/9)/2, width, width*16/9);
        }
            
            break;
            
        default:
            break;
    }
    [self.view setNeedsDisplay];
    [self.view layoutIfNeeded];
}


- (void)modeWillChange: (NSUInteger)newIndex oldIndex: (NSUInteger)oldIndex{
    if(newIndex >= INT_MAX){
        return;
    }
    
    [self.currentOperationNode willQuitOnCompletion:^() {}];
}



- (void)modeDidChange: (NSUInteger)newIndex oldIndex: (NSUInteger)oldIndex{
    
    if(newIndex >= INT_MAX){
        return;
    }
    
    if(newIndex != SDK_CAPTURE_MODE_MOVIE){
        [[SDKParameters shared].items enumerateObjectsUsingBlock:^(SDKParametersItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.model == self.mode) {
                
                [[CameraManager shared] setResolutionFor:AVCaptureDevicePositionBack with:obj.resolution.height model:self.mode];
//                [[CameraManager shared] setResolutionFor:AVCaptureDevicePositionFront with:obj.resolution.height model:self.mode];
            }
        }];
        
    }
    else{
        [[SDKParameters shared].items enumerateObjectsUsingBlock:^(SDKParametersItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.model == self.mode) {
                [[CameraManager shared] setResolutionFor:AVCaptureDevicePositionBack with:obj.videoResolution.height model:self.mode];
//                [[CameraManager shared] setResolutionFor:AVCaptureDevicePositionFront with:obj.videoResolution.height model:self.mode];
            }
        }];

    }
        
    [self updateUIByMode];
    [self switchDevicePositionBack];
    [self updateNumberLabel];

}

- (void)updateCaptureSessionWith:(NSInteger)oldIndex {
    PhotographModeEnum oldModeEnum = (PhotographModeEnum)(oldIndex);
    if((self.mode == SDK_CAPTURE_MODE_PANORAMA || self.mode == SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA)
       && oldModeEnum != SDK_CAPTURE_MODE_PANORAMA
       && oldModeEnum != SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA){
        [self.captureSession beginConfiguration];
        if([self.captureSession canAddOutput:self.videoDataOutput]){
            [self.captureSession removeOutput:self.movieFileOutput];
            [self.captureSession addOutput:self.videoDataOutput];
        }
        [self.captureSession commitConfiguration];

    }
    else if((self.mode == SDK_CAPTURE_MODE_MOVIE)
            && oldModeEnum != SDK_CAPTURE_MODE_MOVIE){
        [self.captureSession beginConfiguration];

        if([self.captureSession canAddOutput:self.movieFileOutput]){
            [self.captureSession removeOutput:self.videoDataOutput];
            [self.captureSession addOutput:self.movieFileOutput];
        }
        [self.captureSession commitConfiguration];

    }
    
}



- (void)setupMicrophone{
    NSError* audioError = nil;
    AVCaptureDevice* audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput* audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&audioError];

    if(audioError == nil){
        AVCaptureAudioDataOutput* audioOutput = [[AVCaptureAudioDataOutput alloc] init];
        [audioOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(0, 0)];
        
        if([self.captureSession canAddInput:audioInput]){
            [self.captureSession addInput:audioInput];
        }
        if([self.captureSession canAddOutput:audioOutput]){
            [self.captureSession addOutput:audioOutput];
        }
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


#pragma mark - DeviceOrigatrion Delegate

- (void)directionChange:(TgDirection)direction {
    self.currentTgDirection = direction;

    if (self.mode != SDK_CAPTURE_MODE_PANORAMA && self.mode != SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA) {
        return;
    }
    OperationNodeVideoBase *base = nil;
    if ([self.currentOperationNode isKindOfClass:[OperationNodeVideoBase class]]) {
        base = (OperationNodeVideoBase *)self.currentOperationNode;
    }
    if (base.isRecording && self.panoramOrientationGuideView.selectedItemIndex != PanoramaOrientationViewAny) {
        return;
    }
    self.panoramaGuideView.dir = self.currentTgDirection;
    self.panoramaGuideView.orginDir = self.panoramOrientationGuideView.selectedItemIndex;
    [self updatePanormaViewWith:direction];
}

- (void)updatePanormaViewWith:(TgDirection)direction {
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;

    switch (direction) {
        case TgDirectionPortrait:{
            
            [self panoramaOrientationViewslt:self.panoramOrientationGuideView.selectedItemIndex];
            [self.modeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.view);
                make.centerY.mas_equalTo(self.flashButton);
            }];
            [self.aiPanPromtLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.view);
                make.top.mas_equalTo(self.modeLabel.mas_bottom).mas_offset(20);
                make.width.mas_offset(240);
                make.height.mas_offset(20);
            }];
            self.modeLabel.transform = CGAffineTransformMakeRotation(0);
            [self.timerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(self.modeLabel);
            }];
            self.timerLabel.transform = CGAffineTransformMakeRotation(0);
            self.svContentView.transform = CGAffineTransformMakeRotation(0);
            self.aiPanPromtLabel.transform = CGAffineTransformMakeRotation(0);

        }
            break;
        case TgDirectionDown:{

            if (self.panoramOrientationGuideView.selectedItemIndex == PanoramaOrientationViewLeft) {
                [self panoramaOrientationViewslt:PanoramaOrientationViewRight];
            } else if (self.panoramOrientationGuideView.selectedItemIndex == PanoramaOrientationViewRight) {
                [self panoramaOrientationViewslt:PanoramaOrientationViewLeft];
            } else if (self.panoramOrientationGuideView.selectedItemIndex == PanoramaOrientationViewUp) {
                [self panoramaOrientationViewslt:PanoramaOrientationViewDown];
            } else if (self.panoramOrientationGuideView.selectedItemIndex == PanoramaOrientationViewDown) {
                [self panoramaOrientationViewslt:PanoramaOrientationViewUp];
            } else {
                [self panoramaOrientationViewslt:PanoramaOrientationViewAny];
            }
            
            [self.modeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.view);
                make.centerY.mas_equalTo(self.flashButton);
            }];
            [self.aiPanPromtLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.view);
                make.top.mas_equalTo(self.modeLabel.mas_bottom).mas_offset(20);
                make.width.mas_offset(240);
                make.height.mas_offset(20);
            }];
            self.modeLabel.transform = CGAffineTransformMakeRotation(0);
            [self.timerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(self.modeLabel);
            }];
            self.timerLabel.transform = CGAffineTransformMakeRotation(0);
            self.svContentView.transform = CGAffineTransformMakeRotation(M_PI);
            self.aiPanPromtLabel.transform = CGAffineTransformMakeRotation(0);

        }

            break;
        case TgDirectionRight:{

            if (self.panoramOrientationGuideView.selectedItemIndex == PanoramaOrientationViewLeft) {
                [self panoramaOrientationViewslt:PanoramaOrientationViewDown];
                [self.modeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo((height - 40)/2);
                    make.height.mas_offset(22);
                    make.right.mas_offset(-(width-80));
                }];
                [self.aiPanPromtLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(self.view);
                    make.right.mas_offset(-(width-200));
                    make.width.mas_offset(240);
                    make.height.mas_offset(20);
                }];
                self.modeLabel.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.aiPanPromtLabel.transform = CGAffineTransformMakeRotation(-M_PI/2);
                [self.timerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(self.modeLabel);
                }];
                self.timerLabel.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.svContentView.transform = CGAffineTransformMakeRotation(-M_PI/2);

            } else if (self.panoramOrientationGuideView.selectedItemIndex == PanoramaOrientationViewRight) {
                [self panoramaOrientationViewslt:PanoramaOrientationViewUp];
                [self.modeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo((height - 40)/2);
                    make.height.mas_offset(22);
                    make.right.mas_offset(-(width-80));
                }];
                [self.aiPanPromtLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(self.view);
                    make.right.mas_offset(-(width-200));
                    make.width.mas_offset(240);
                    make.height.mas_offset(20);
                }];
                self.modeLabel.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.aiPanPromtLabel.transform = CGAffineTransformMakeRotation(-M_PI/2);
                [self.timerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(self.modeLabel);
                }];
                self.timerLabel.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.svContentView.transform = CGAffineTransformMakeRotation(-M_PI/2);

            } else if (self.panoramOrientationGuideView.selectedItemIndex == PanoramaOrientationViewUp) {
                [self panoramaOrientationViewslt:PanoramaOrientationViewLeft];
                [self.modeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.view);
                    make.centerY.mas_equalTo(self.flashButton);
                }];
                [self.aiPanPromtLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.view);
                    make.top.mas_equalTo(self.modeLabel.mas_bottom).mas_offset(20);
                    make.width.mas_offset(240);
                    make.height.mas_offset(20);
                }];
                self.modeLabel.transform = CGAffineTransformMakeRotation(0);
                [self.timerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(self.modeLabel);
                }];
                self.timerLabel.transform = CGAffineTransformMakeRotation(0);
                self.svContentView.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.aiPanPromtLabel.transform = CGAffineTransformMakeRotation(0);


            } else if (self.panoramOrientationGuideView.selectedItemIndex == PanoramaOrientationViewDown) {
                [self panoramaOrientationViewslt:PanoramaOrientationViewRight];
                [self.modeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.view);
                    make.centerY.mas_equalTo(self.flashButton);
                }];
                [self.aiPanPromtLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.view);
                    make.top.mas_equalTo(self.modeLabel.mas_bottom).mas_offset(20);
                    make.width.mas_offset(240);
                    make.height.mas_offset(20);
                }];
                self.modeLabel.transform = CGAffineTransformMakeRotation(0);
                [self.timerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(self.modeLabel);
                }];
                self.timerLabel.transform = CGAffineTransformMakeRotation(0);
                self.svContentView.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.aiPanPromtLabel.transform = CGAffineTransformMakeRotation(0);

            } else {
                self.svContentView.transform = CGAffineTransformMakeRotation(-M_PI/2);
                [self panoramaOrientationViewslt:PanoramaOrientationViewAny];
            }

        }
            break;
        case TgDirectionLeft:{

            if (self.panoramOrientationGuideView.selectedItemIndex == PanoramaOrientationViewLeft) {
                [self panoramaOrientationViewslt:PanoramaOrientationViewUp];
                [self.modeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo((height - 40)/2);
                    make.height.mas_offset(22);
                    make.left.mas_offset(width-80);
                }];
                [self.aiPanPromtLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(self.view);
                    make.left.mas_offset(width-200);
                    make.width.mas_offset(240);
                    make.height.mas_offset(20);
                }];
                self.modeLabel.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.aiPanPromtLabel.transform = CGAffineTransformMakeRotation(M_PI/2);
                [self.timerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(self.modeLabel);
                }];
                self.timerLabel.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.svContentView.transform = CGAffineTransformMakeRotation(M_PI/2);

            } else if (self.panoramOrientationGuideView.selectedItemIndex == PanoramaOrientationViewRight) {
                [self panoramaOrientationViewslt:PanoramaOrientationViewDown];
                [self.modeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo((height - 40)/2);
                    make.height.mas_offset(22);
                    make.left.mas_offset(width-80);
                }];
                [self.aiPanPromtLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(self.view);
                    make.left.mas_offset(width-200);
                    make.width.mas_offset(240);
                    make.height.mas_offset(20);
                }];
                self.modeLabel.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.aiPanPromtLabel.transform = CGAffineTransformMakeRotation(M_PI/2);
                [self.timerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(self.modeLabel);
                }];
                self.timerLabel.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.svContentView.transform = CGAffineTransformMakeRotation(M_PI/2);

            } else if (self.panoramOrientationGuideView.selectedItemIndex == PanoramaOrientationViewUp) {
                [self panoramaOrientationViewslt:PanoramaOrientationViewRight];
                [self.modeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.view);
                    make.centerY.mas_equalTo(self.flashButton);
                }];
                [self.aiPanPromtLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.view);
                    make.top.mas_equalTo(self.modeLabel.mas_bottom).mas_offset(20);
                    make.width.mas_offset(240);
                    make.height.mas_offset(20);
                }];
                self.modeLabel.transform = CGAffineTransformMakeRotation(0);
                [self.timerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(self.modeLabel);
                }];
                self.timerLabel.transform = CGAffineTransformMakeRotation(0);
                self.svContentView.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.aiPanPromtLabel.transform = CGAffineTransformMakeRotation(0);

            } else if (self.panoramOrientationGuideView.selectedItemIndex == PanoramaOrientationViewDown) {
                [self panoramaOrientationViewslt:PanoramaOrientationViewLeft];
                [self.modeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.view);
                    make.centerY.mas_equalTo(self.flashButton);
                }];
                [self.aiPanPromtLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.view);
                    make.top.mas_equalTo(self.modeLabel.mas_bottom).mas_offset(20);
                    make.width.mas_offset(240);
                    make.height.mas_offset(20);
                }];
                self.modeLabel.transform = CGAffineTransformMakeRotation(0);
                [self.timerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(self.modeLabel);
                }];
                self.timerLabel.transform = CGAffineTransformMakeRotation(0);
                self.svContentView.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.aiPanPromtLabel.transform = CGAffineTransformMakeRotation(0);
            } else {
                self.svContentView.transform = CGAffineTransformMakeRotation(M_PI/2);
                [self panoramaOrientationViewslt:PanoramaOrientationViewAny];
            }
        }
            break;
    
        default:
            break;
    }
    
}
    
#pragma  mark 方向调用的代理
- (void)panoramDirDidChange {
    [self directionChange:self.currentTgDirection];
}

- (void)panoramaOrientationViewslt:(PanoramaOrientationViewDirectionEnum)direction{
    if (self.mode == SDK_CAPTURE_MODE_PANORAMA) {
        self.panoramaGuideView.hidden = NO;
    } else {
        OperationNodeVideoBase *base = nil;
        if ([self.currentOperationNode isKindOfClass:[OperationNodeVideoBase class]]) {
            base = (OperationNodeVideoBase *)self.currentOperationNode;
        }
        if (base.isRecording) {
            self.panoramaGuideView.hidden = NO;
        } else {
            self.panoramaGuideView.hidden = YES;
        }
    }
    self.aiPanPromtLabel.hidden = direction != PanoramaOrientationViewAny;
    
    self.panoramaGuideView.hidden = !(self.mode == SDK_CAPTURE_MODE_PANORAMA);
    [UIView animateWithDuration:0.25 animations:^{
        [self.panoramaGuideView mas_remakeConstraints:^(MASConstraintMaker *make) {
            switch (direction) {
                case PanoramaOrientationViewLeft:
                case PanoramaOrientationViewRight:
                {
                    make.left.right.offset(0);
                    make.centerY.mas_equalTo(self.view);
                    make.height.mas_equalTo(PanoramaGuideViewWOrH);
                }
                    break;
                case PanoramaOrientationViewUp:
                case PanoramaOrientationViewDown:
                {
                    make.centerX.mas_equalTo(self.view);
                    make.width.mas_equalTo(PanoramaGuideViewWOrH);
                    make.bottom.mas_equalTo(self.panoramOrientationGuideView.mas_top).offset(-25);
                    if (self.currentTgDirection == TgDirectionLeft || self.currentTgDirection == TgDirectionRight) {
                        make.top.offset(50);
                    } else {
                        make.top.mas_equalTo(self.timerLabel.mas_bottom).offset(15);
                    }
                }
                    break;
                case PanoramaOrientationViewAny: {
                    self.panoramaGuideView.hidden = YES;
                    
                }
                    break;
                default:
                    break;
            }
        }];
//        if (self.mode != SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA) {
//            [self.panoramaGuideView setNeedsLayout];
//            [self.panoramaGuideView layoutIfNeeded];
//        }
    } completion:^(BOOL finished) {
        self.panoramaGuideView.dir = self.currentTgDirection;
        self.panoramaGuideView.orginDir = self.panoramOrientationGuideView.selectedItemIndex;
        [self.panoramaGuideView direction:direction];
//        [self updatePanormaViewWith:direction];

    }];
}

- (void)stopAllSensors{
    dispatch_async(self.videoQueue, ^{
        [self.captureSession stopRunning];
    });
    [[PCSMotionManager shared] stopAccelerometerUpdates];
}

#pragma mark - session
- (void)turnTorchOff{
    AVCaptureDevice* currentDevice = self.currentCamera;
    if(currentDevice == nil || !currentDevice.hasTorch){
        return;
    }
    NSError* error;
    if(error == nil){
        [currentDevice lockForConfiguration:&error];
        currentDevice.torchMode = AVCaptureTorchModeOff;
        [currentDevice unlockForConfiguration];
    }
}
- (void)stopCaptureSession{
    [self turnTorchOff];
    
    if (self.captureSession.isRunning) {
        dispatch_async(self.videoQueue, ^{
            [self.captureSession stopRunning];
        });
    }
}

- (void)startCaptureSession{
    if (!self.cameraPrepared) {
        [self prepareCamera];
    }
    
    if (self.cameraPrepared && (!self.captureSession.isRunning)) {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(self.videoQueue, ^{
               [self.captureSession startRunning];
           });
//            [self.captureSession startRunning];
//        });
    }
}

#pragma mark - Btn call back
-(IBAction)switchCameraTapped:(id)sender
{
    if(self.captureSession == nil){
        return;
    }
    
    AVCaptureDeviceInput* currInput = self.currentCameraInput;
    if(currInput == nil){
        return;
    }
    AVCaptureDevice* currentDevice = currInput.device;
    AVCaptureDevice *newCamera = nil;
    if(currentDevice.position == AVCaptureDevicePositionBack){
        newCamera = [CameraManager shared].front;
    }
    else if(currentDevice.position == AVCaptureDevicePositionFront){
        newCamera = [CameraManager shared].back;
    }
    else{
        return;
    }
    
    [self.captureSession beginConfiguration];
    if(currentDevice.hasTorch){
        NSError* error;
        [currentDevice lockForConfiguration:&error];
        currentDevice.torchMode = AVCaptureTorchModeOff;
        [currentDevice unlockForConfiguration];
    }
    [self.captureSession removeInput:currInput];
    self.flashButton.hidden = !newCamera.hasFlash;

    NSError *err = nil;
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&err];
    if(newVideoInput == nil || err != nil){
    }
    else if([self.captureSession canAddInput:newVideoInput]){
        [self.captureSession addInput:newVideoInput];
    }

    [self.captureSession commitConfiguration];
}

- (void)switchDevicePositionBack {
    if(self.captureSession == nil ||
       (self.mode != SDK_CAPTURE_MODE_PANORAMA && self.mode != SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA)){
        return;
    }
    
    AVCaptureDeviceInput* currInput = self.currentCameraInput;
    if(currInput == nil){
        return;
    }
    AVCaptureDevice* currentDevice = currInput.device;
    AVCaptureDevice *newCamera = nil;
    if(currentDevice.position == AVCaptureDevicePositionBack){
        return;
    }
    if(currentDevice.position == AVCaptureDevicePositionFront){
        newCamera = [CameraManager shared].back;
    }
    
    [self.captureSession beginConfiguration];
    if(currentDevice.hasTorch){
        NSError* error;
        [currentDevice lockForConfiguration:&error];
        currentDevice.torchMode = AVCaptureTorchModeOff;
        [currentDevice unlockForConfiguration];
    }
    [self.captureSession removeInput:currInput];

    NSError *err = nil;
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&err];
    if(newVideoInput == nil || err != nil){
    } else if([self.captureSession canAddInput:newVideoInput]){
        [self.captureSession addInput:newVideoInput];
    }

    [self.captureSession commitConfiguration];
}


- (void)takePhotoButtonTouchUpInside:(id)sender{

    if(![self.currentOperationNode respondsToSelector:@selector(enable)] || self.currentOperationNode.enable){
        
        if (self.mode == SDK_CAPTURE_MODE_MOVIE) {
            __block SDKParametersItem *videoItems = nil;
            [[SDKParameters shared].items enumerateObjectsUsingBlock:^(SDKParametersItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.model == self.mode) {
                    videoItems = obj;
                }
            }];
            if (videoItems.quantity > 0 && self.resourceModel.movieArray.count >= videoItems.quantity) {
                [SVProgressHUD showImage:[UIImage imageNamed:@""] status:[NSString stringWithFormat:@"最多录制%ld条视频", videoItems.quantity]];
                return;
            }
        }
        
        if (self.mode == SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA) {
            self.aiRecordPromtLabel.hidden = YES;
            OperationNodeAIPanorama *aiPan = nil;
            if ([self.currentOperationNode isKindOfClass:[OperationNodeAIPanorama class]]) {
                aiPan = self.currentOperationNode;
                if (!aiPan.isRecording) {
                    aiPan.AIType = OperationAITypeTap;
                }
            }

        }

        
        [self.currentOperationNode takePhotoButtonTouched];

        if (self.mode == SDK_CAPTURE_MODE_PANORAMA && !self.isVideoStitchStopedWhenRecording) {
            [LenStitcher videoResetPath];
            LenzResourceItemModel *itemModel = [[LenzResourceItemModel alloc]init];
            [self.resourceModel.panoramArray addObject:itemModel];
            [self startMotion];
        }
    }

}
- (void)longPressGes:(UILongPressGestureRecognizer *)ges {
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (self.mode == SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA) {

                OperationNodeAIPanorama *aiPan = nil;
                if ([self.currentOperationNode isKindOfClass:[OperationNodeAIPanorama class]]) {
                    [LenStitcher videoResetPath];
                    LenzResourceItemModel *itemModel = [[LenzResourceItemModel alloc]init];
                    itemModel.isStitch = YES;
                    [self.resourceModel.aiPanoramArray addObject:itemModel];
                    [self startMotion];
                    aiPan = self.currentOperationNode;
                    aiPan.AIType = OperationAITypeLongPress;
                    [self.currentOperationNode takePhotoButtonTouched];
                    self.aiRecordPromtLabel.hidden = NO;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.aiRecordPromtLabel.hidden = YES;
                    });
                }

            }
        }
            
            break;
        case UIGestureRecognizerStateEnded:
            
            break;
        default:
            break;
    }
}
- (void)takePhotoButtonTouchDownInside:(id)sender{

}

- (void)flashButtonTouchUpInside:(id)sender{
    AVCaptureDevice* currentDevice = self.currentCamera;
    if(currentDevice == nil || !currentDevice.hasFlash){
        return;
    }
    NSError* error = nil;
    [currentDevice lockForConfiguration:&error];
    if(error != nil){
        return;
    }
    if(self.outputSettings.flashMode == AVCaptureFlashModeOn){
        self.outputSettings.flashMode = AVCaptureFlashModeAuto;
        [self.flashButton setImage:[UIImage sdkImageNamed:@"flash-auto-btn"] forState:UIControlStateNormal];
    }
    else if(self.outputSettings.flashMode == AVCaptureFlashModeAuto){
        self.outputSettings.flashMode = AVCaptureFlashModeOff;
        [self.flashButton setImage:[UIImage sdkImageNamed:@"flash-disable-btn"] forState:UIControlStateNormal];
    }
    else{
        self.outputSettings.flashMode = AVCaptureFlashModeOn;
        [self.flashButton setImage:[UIImage sdkImageNamed:@"flash-btn"] forState:UIControlStateNormal];
    }
    [currentDevice unlockForConfiguration];
}

- (void)backButtonTouchUpInside:(id)sender{
    
    if (!self.stitchView.hidden) {
        
        [QuitMultipleModeAlertViewController show:self title:@"确认提醒" text:@"图片拼接中，返回会清空正在拼接的数据" leftBtnTitle:@"取消" rightBtnTitle:@"确定" withLeftButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
            
            [alertController dismissViewControllerAnimated:NO completion:^{}];
        } rightButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
            [self updateViewStatusWhenStitchSave:NO];
            [self.panoramaGuideView clearImage];
            [self.panoramaGuideView showImageWith:nil];
            [alertController dismissViewControllerAnimated:NO completion:^{
            }];
        }];
    } else {
        [self stopCaptureSession];
        [[PCSMotionManager shared] stopAccelerometerUpdates];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
}


- (void)makeResData:(NSMutableArray <LenzResourceItemModel *> *)array {
    [array enumerateObjectsUsingBlock:^(LenzResourceItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
    }];
}

- (void)savePhotoButtonTouchUpInside:(id)sender{
    //待优化
    NSMutableArray *res = [NSMutableArray array];
    __block NSInteger idIndex = 1;
    [self.resourceModel.singleArray enumerateObjectsUsingBlock:^(LenzResourceItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        idIndex += idx;
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"id"] = [NSString stringWithFormat:@"%ld", idIndex];
        dict[@"path"] = obj.path;
        dict[@"cameraMode"] = obj.cameraMode;
        dict[@"cameraType"] = obj.cameraType;
        dict[@"isRemake"] = @(obj.isRemake);
        [res addObject:dict];
    }];
    
    [self.resourceModel.continousArray enumerateObjectsUsingBlock:^(LenzResourceItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        idIndex += idx;
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"id"] = [NSString stringWithFormat:@"%ld", idIndex];
        dict[@"path"] = obj.path;
        dict[@"cameraMode"] = obj.cameraMode;
        dict[@"cameraType"] = obj.cameraType;
        dict[@"isRemake"] = @(obj.isRemake);
        [res addObject:dict];
    }];
    
    [self.resourceModel.movieArray enumerateObjectsUsingBlock:^(LenzResourceItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        idIndex += idx;
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"id"] = [NSString stringWithFormat:@"%ld", idIndex];
        dict[@"path"] = obj.path;
        dict[@"cameraMode"] = obj.cameraMode;
        dict[@"cameraType"] = obj.cameraType;
        dict[@"isRemake"] = @(obj.isRemake);
        [res addObject:dict];
    }];
    [self.resourceModel.panoramArray enumerateObjectsUsingBlock:^(LenzResourceItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.path.length) {
            idIndex += idx;
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[@"id"] = [NSString stringWithFormat:@"%ld", idIndex];
            dict[@"mosaicPictureUrl"] = obj.path;
            dict[@"cameraMode"] = obj.cameraMode;
            dict[@"cameraType"] = obj.cameraType;
            dict[@"isRemake"] = @(obj.isRemake);
            NSMutableArray *keyFrame = [NSMutableArray array];
            [obj.keyFrame enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [keyFrame addObject:obj];
            }];
            dict[@"keyframe"] = keyFrame;
            [res addObject:dict];
        }
    }];
    [self.resourceModel.aiPanoramArray enumerateObjectsUsingBlock:^(LenzResourceItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.path.length) {
            idIndex += idx;
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[@"id"] = [NSString stringWithFormat:@"%ld", idIndex];
            dict[@"cameraMode"] = obj.cameraMode;
            dict[@"cameraType"] = obj.cameraType;
            dict[@"isRemake"] = @(obj.isRemake);
            if (obj.isStitch) {
                NSMutableArray *keyFrame = [NSMutableArray array];
                [obj.keyFrame enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [keyFrame addObject:obj];
                }];
                dict[@"keyframe"] = keyFrame;
                dict[@"mosaicPictureUrl"] = obj.path;
            } else {
                dict[@"path"] = obj.path;
            }
            [res addObject:dict];
        }
    }];
    if (self.completeBlock) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"code"] = @(200);
        dict[@"message"] = @"成功";
        dict[@"data"] = res;
        [self stopCaptureSession];
        [[PCSMotionManager shared] stopAccelerometerUpdates];
        self.completeBlock(dict);
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (void)discardPhotoResultButtonTouchUpInside:(id)sender{
    self.panGesture.enabled = YES;
    
    NSMutableString *showCountString = [NSMutableString stringWithString:@"已拍摄："];
    if (self.resourceModel.continousArray.count > 0) {
        [showCountString appendString:[NSString stringWithFormat:@" 连拍：%ld张", self.resourceModel.continousArray.count]];
    }
    if (self.resourceModel.movieArray.count > 0) {
        [showCountString appendString:[NSString stringWithFormat:@" 视频：%ld条", self.resourceModel.movieArray.count]];
    }
    
    if (self.resourceModel.panoramArray.count > 0) {
        [showCountString appendString:[NSString stringWithFormat:@" 全景：%ld张", self.resourceModel.panoramArray.count]];
    }
    if (self.resourceModel.aiPanoramArray.count > 0) {
        [showCountString appendString:[NSString stringWithFormat:@" 智能全景：%ld张", self.resourceModel.aiPanoramArray.count]];
    }
    
    NSString *title = [NSString stringWithFormat:@"返回会清空已拍摄数据，请确认！\n%@", showCountString];
    [QuitMultipleModeAlertViewController show:self title:@"确认提醒" text:title leftBtnTitle:@"取消" rightBtnTitle:@"确定" withLeftButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
        [alertController dismissViewControllerAnimated:NO completion:^{}];
    } rightButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
        [self.resourceModel.continousArray removeAllObjects];
        [self.resourceModel.movieArray removeAllObjects];
        [self.resourceModel.panoramArray removeAllObjects];
        [self.resourceModel.aiPanoramArray removeAllObjects];
        [alertController dismissViewControllerAnimated:NO completion:^{
            [self stopCaptureSession];
            [[PCSMotionManager shared] stopAccelerometerUpdates];
            [self dismissViewControllerAnimated:YES completion:^{}];
        }];
    }];
}

- (void)albumButtonTouchUpInside:(id)sender{

    [self performSegueWithIdentifier:@"show-photoalbum" sender:nil];
}

- (__kindof id<OperationNodeProtocol>)currentOperationNode{
    return self.operationNodes[@(self.mode)];
}


- (void)updateNumberLabel {
    switch (self.mode) {
        case SDK_CAPTURE_MODE_CONTINUOUS: {
            if (self.resourceModel.continousArray.count > 0) {
                self.numberOfImagesLabel.hidden = NO;
                self.numberOfImagesLabel.text = [NSString stringWithFormat:@"已连拍%ld张", self.resourceModel.continousArray.count];
            } else {
                self.numberOfImagesLabel.hidden = YES;
            }
        }
            
            break;
        case SDK_CAPTURE_MODE_MOVIE:{
            if (self.resourceModel.movieArray.count > 0) {
                self.numberOfImagesLabel.hidden = NO;
                self.numberOfImagesLabel.text = [NSString stringWithFormat:@"已拍视频%ld条", self.resourceModel.movieArray.count];
            } else {
                self.numberOfImagesLabel.hidden = YES;
            }
        }
            
            break;
        case SDK_CAPTURE_MODE_PANORAMA:
        {
            if (self.resourceModel.panoramArray.count > 0) {
                self.numberOfImagesLabel.hidden = NO;
                self.numberOfImagesLabel.text = [NSString stringWithFormat:@"已拼接%ld张", self.resourceModel.panoramArray.count];
            } else {
                self.numberOfImagesLabel.hidden = YES;
            }
        }
            
            break;
        case SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA:
        {
            if (self.resourceModel.aiPanoramArray.count > 0) {
                self.numberOfImagesLabel.hidden = NO;
                self.numberOfImagesLabel.text = [NSString stringWithFormat:@"已拍摄%ld张", self.resourceModel.aiPanoramArray.count];
            } else {
                self.numberOfImagesLabel.text = @"单击拍照，长按全景";
                self.numberOfImagesLabel.hidden = NO;
            }
        }
            break;
            
        default:
            self.numberOfImagesLabel.hidden = YES;
            break;
    }
}
- (void)savePhotoWith:(NSData *)data isRemake:(BOOL)isRemake{
    UIImage *image = [[UIImage alloc] initWithData:data];

    UIImage *saveImage = [self rotateImageWith:image];
    
    data = UIImageJPEGRepresentation(saveImage, 1);
    NSString *path = [LenzDataManager saveImageWith:data mode:self.mode];
    LenzResourceItemModel *itemModel = [[LenzResourceItemModel alloc]init];
    itemModel.path = path;
    [[SDKParameters shared].items enumerateObjectsUsingBlock:^(SDKParametersItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.model == self.mode) {
            itemModel.cameraType = obj.cameraPositionString;
        }
    }];
    
    itemModel.mode = self.mode;
    
    
    itemModel.image = image;
    itemModel.previewImage = saveImage;
    itemModel.isRemake = isRemake;

    switch (self.mode) {
        case SDK_CAPTURE_MODE_CONTINUOUS:{
            
            [self.resourceModel.continousArray addObject:itemModel];
        }
            break;
        case SDK_CAPTURE_MODE_SINGLE: {
            [self.resourceModel.singleArray addObject:itemModel];
        }
            
            break;
        case SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA: {
            [self.resourceModel.aiPanoramArray addObject:itemModel];
        }
            
            break;
            
        default:
            break;
    }
    self.resourceModel.lastIndex = self.mode;
    [self updateViewStatus];
    
    
    [self.currentOperationNode triggered];
    if(self.mode == SDK_CAPTURE_MODE_SINGLE){
        [self stopCaptureSession];
        [self performSegueWithIdentifier:@"preview_single" sender:nil];
    }
    else if(self.mode == SDK_CAPTURE_MODE_CONTINUOUS){
        self.discardPhotoButton.hidden = NO;
        self.savePhotoButton.hidden = NO;
    }
    
    self.resultImageView.image = image;
}
#pragma mark 相机单拍,和连拍的代理
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error{
    self.panGesture.enabled = YES;
    self.isDuringTakePhoto = NO;

    NSData* imageData = [photo fileDataRepresentation];
    if (imageData == nil){
        return;
    }
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    
    BOOL isRemake = [self.tensorFlow remake:image];
    __block BOOL needCheckRemake = NO;
    [[SDKParameters shared].items enumerateObjectsUsingBlock:^(SDKParametersItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.model == self.mode) {
            needCheckRemake = obj.isRemake;
        }
    }];
    if (isRemake && needCheckRemake) {
        [QuitMultipleModeAlertViewController show:self title:@"确认提醒" text:@"检测到该图片为翻拍，是否继续使用？" leftBtnTitle:@"取消" rightBtnTitle:@"确定" withLeftButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        } rightButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
            [self savePhotoWith:imageData isRemake:isRemake];
            
        }];
    } else {
        [self savePhotoWith:imageData isRemake:isRemake];
    }
    
}


- (void)updateViewStatus {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image = nil;
        NSMutableArray *continousMutArray = [NSMutableArray array];
        [self.resourceModel.continousArray enumerateObjectsUsingBlock:^(LenzResourceItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.path && obj.previewImage) {
                [continousMutArray addObject:obj];
            }
        }];
        self.resourceModel.continousArray = continousMutArray;
        
        NSMutableArray *singleMutArray = [NSMutableArray array];
        [self.resourceModel.singleArray enumerateObjectsUsingBlock:^(LenzResourceItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.path && obj.previewImage) {
                [singleMutArray addObject:obj];
            }
        }];
        self.resourceModel.singleArray = singleMutArray;
        
        NSMutableArray *movieMutArray = [NSMutableArray array];
        [self.resourceModel.movieArray enumerateObjectsUsingBlock:^(LenzResourceItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.path && obj.previewImage) {
                [movieMutArray addObject:obj];
            }
        }];
        self.resourceModel.movieArray = movieMutArray;
        
        NSMutableArray *panoramMutArray = [NSMutableArray array];
        [self.resourceModel.panoramArray enumerateObjectsUsingBlock:^(LenzResourceItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.path && obj.previewImage) {
                [panoramMutArray addObject:obj];
            }
        }];
        self.resourceModel.panoramArray = panoramMutArray;
        
        NSMutableArray *aiPanoramMutArray = [NSMutableArray array];
        [self.resourceModel.aiPanoramArray enumerateObjectsUsingBlock:^(LenzResourceItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.path && obj.previewImage) {
                [aiPanoramMutArray addObject:obj];
            }
        }];
        self.resourceModel.aiPanoramArray = aiPanoramMutArray;
        
        switch (self.resourceModel.lastIndex) {
            case SDK_CAPTURE_MODE_CONTINUOUS: {
                if (self.resourceModel.continousArray.count > 0) {
                    LenzResourceItemModel *model = self.resourceModel.continousArray.lastObject;
                    image = model.previewImage;
                } else {
                    if (self.resourceModel.singleArray.count > 0) {
                        LenzResourceItemModel *model = self.resourceModel.singleArray.lastObject;
                        image = model.previewImage;
                    } else if (self.resourceModel.movieArray.count > 0) {
                        LenzResourceItemModel *model = self.resourceModel.movieArray.lastObject;
                        image = model.previewImage;
                    } else if (self.resourceModel.panoramArray.count > 0) {
                        LenzResourceItemModel *model = self.resourceModel.panoramArray.lastObject;
                        image = model.previewImage;
                    } else if (self.resourceModel.aiPanoramArray.count > 0) {
                        LenzResourceItemModel *model = self.resourceModel.aiPanoramArray.lastObject;
                        image = model.previewImage;
                    }
                }
            }
                
                break;
            case SDK_CAPTURE_MODE_SINGLE:{
                if (self.resourceModel.singleArray.count > 0) {
                    LenzResourceItemModel *model = self.resourceModel.singleArray.lastObject;
                    image = model.previewImage;
                } else {
                    if (self.resourceModel.continousArray.count > 0) {
                        LenzResourceItemModel *model = self.resourceModel.continousArray.lastObject;
                        image = model.previewImage;
                    } else if (self.resourceModel.movieArray.count > 0) {
                        LenzResourceItemModel *model = self.resourceModel.movieArray.lastObject;
                        image = model.previewImage;
                    } else if (self.resourceModel.panoramArray.count > 0) {
                        LenzResourceItemModel *model = self.resourceModel.panoramArray.lastObject;
                        image = model.previewImage;
                    } else if (self.resourceModel.aiPanoramArray.count > 0) {
                        LenzResourceItemModel *model = self.resourceModel.aiPanoramArray.lastObject;
                        image = model.previewImage;
                    }
                }
            }
                
                break;
            case SDK_CAPTURE_MODE_MOVIE:{
                if (self.resourceModel.movieArray.count > 0) {
                    LenzResourceItemModel *model = self.resourceModel.movieArray.lastObject;
                    image = model.previewImage;
                } else {
                    if (self.resourceModel.singleArray.count > 0) {
                        LenzResourceItemModel *model = self.resourceModel.singleArray.lastObject;
                        image = model.previewImage;
                    } else if (self.resourceModel.continousArray.count > 0) {
                        LenzResourceItemModel *model = self.resourceModel.continousArray.lastObject;
                        image = model.previewImage;
                    } else if (self.resourceModel.panoramArray.count > 0) {
                        LenzResourceItemModel *model = self.resourceModel.panoramArray.lastObject;
                        image = model.previewImage;
                    } else if (self.resourceModel.aiPanoramArray.count > 0) {
                        LenzResourceItemModel *model = self.resourceModel.aiPanoramArray.lastObject;
                        image = model.previewImage;
                    }
                }
            }
                
                break;
            case SDK_CAPTURE_MODE_PANORAMA:{
                if (self.resourceModel.panoramArray.count > 0) {
                    LenzResourceItemModel *model = self.resourceModel.panoramArray.lastObject;
                    image = model.previewImage;
                } else {
                    if (self.resourceModel.singleArray.count > 0) {
                        LenzResourceItemModel *model = self.resourceModel.singleArray.lastObject;
                        image = model.previewImage;
                    } else if (self.resourceModel.movieArray.count > 0) {
                        LenzResourceItemModel *model = self.resourceModel.movieArray.lastObject;
                        image = model.previewImage;
                    } else if (self.resourceModel.continousArray.count > 0) {
                        LenzResourceItemModel *model = self.resourceModel.continousArray.lastObject;
                        image = model.previewImage;
                    } else if (self.resourceModel.aiPanoramArray.count > 0) {
                        LenzResourceItemModel *model = self.resourceModel.aiPanoramArray.lastObject;
                        image = model.previewImage;
                    }
                }
            }
                
                break;
            case SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA:{
                if (self.resourceModel.aiPanoramArray.count > 0) {
                    LenzResourceItemModel *model = self.resourceModel.aiPanoramArray.lastObject;
                    image = model.previewImage;
                } else {
                    if (self.resourceModel.singleArray.count > 0) {
                        LenzResourceItemModel *model = self.resourceModel.singleArray.lastObject;
                        image = model.previewImage;
                    } else if (self.resourceModel.movieArray.count > 0) {
                        LenzResourceItemModel *model = self.resourceModel.movieArray.lastObject;
                        image = model.previewImage;
                    } else if (self.resourceModel.panoramArray.count > 0) {
                        LenzResourceItemModel *model = self.resourceModel.panoramArray.lastObject;
                        image = model.previewImage;
                    } else if (self.resourceModel.continousArray.count > 0) {
                        LenzResourceItemModel *model = self.resourceModel.continousArray.lastObject;
                        image = model.previewImage;
                    }
                }
            }
                
                break;
                
            default:
                break;
        }
        if (image) {
            self.ablumImageView.image = image;
            self.ablumImageView.hidden = NO;
            self.discardPhotoButton.hidden = NO;
            self.savePhotoButton.hidden = NO;
            self.backButton.hidden = YES;
        } else {
            self.ablumImageView.image = nil;
            self.ablumImageView.hidden = YES;
            self.discardPhotoButton.hidden = YES;
            self.savePhotoButton.hidden = YES;
            self.backButton.hidden = NO;
        }
        [self updateNumberLabel];
    });
    
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error{
    //视频录制
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.timerLabel updateWith:0];
    });
    BOOL recordedSuccessfully = YES;
    if(error.code == AVErrorMaximumDurationReached){
    } else if (error.code == AVErrorDiskFull){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:LenzSDKNotificationDiskIsFull object:error];
        });
    }else if (error.code == AVErrorSessionWasInterrupted){
    }
    id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
    if (value) {
        recordedSuccessfully = [value boolValue];
        
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }
    if(!recordedSuccessfully){
        return;
    }
    
    OperationNodeMovie *node = nil;
    if ([self.currentOperationNode isKindOfClass:[OperationNodeMovie class]]) {
        node = (OperationNodeMovie *)self.currentOperationNode;
        if (node.isRecording) {
            [self.currentOperationNode takePhotoButtonTouched];
        }
    }
    LenzResourceItemModel *itemModel = [[LenzResourceItemModel alloc]init];
    itemModel.path = outputFileURL.absoluteString;
    [[SDKParameters shared].items enumerateObjectsUsingBlock:^(SDKParametersItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.model == self.mode) {
            itemModel.cameraType = obj.cameraPositionString;
        }
    }];
    
    itemModel.mode = self.mode;
    
    itemModel.previewImage = [self rotateImageWith:[self videoFrameImageWith:outputFileURL]];
    [self.resourceModel.movieArray addObject:itemModel];
    self.resourceModel.lastIndex = self.mode;
    
    [self updateViewStatus];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.currentOperationNode triggered];
        self.thumbnailOritaionByCurrentVideoOrientation = UIImageOrientationUp;
    });
}

- (BOOL)encodeFrame:(CMSampleBufferRef) sampleBuffer{
    
    if (CMSampleBufferDataIsReady(sampleBuffer)) {
        
        if (self.videoWriter.status == AVAssetWriterStatusUnknown) {
            
            CMTime startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            
            [self.videoWriter startWriting];
            [self.videoWriter startSessionAtSourceTime:startTime];
        }
        
        if (self.videoWriter.status == AVAssetWriterStatusFailed) {
            return NO;
        }
        
        if (self.videoWriterInput.readyForMoreMediaData) {
            [self.videoWriterInput appendSampleBuffer:sampleBuffer];
            return YES;
        }
    }
    return NO;
}

#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate


#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [[CustomModalViewTransitionPresent alloc] init];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return [[CustomModalViewTransitionDismiss alloc] init];
}

#pragma mark - PhotoListViewControllerDelegate

//删除视频
- (void)deleteMovie: (MovieListCellModel*)model completion: (DeleteImageCompletionCallBackType)completion{
    for (int i = 0; i < self.totalArray.count; i ++) {
        UIImage *image = self.totalArray[i];
        if (image == (UIImage *)model.movieModel.thumbnail) {
            [self.totalArray removeObjectAtIndex:i];
            [self.typeArray removeObjectAtIndex:i];

            break;;
        }
        
    }
    id<OperationNodeProtocol> curr = (__kindof id<OperationNodeProtocol>)self.operationNodes[@(2)];
    if([curr respondsToSelector:@selector(deleteCacheForKey:completion:)]){
        [curr deleteCacheForKey:model.movieModel.fileUrl.path completion:completion];
    }
}

//连拍删除
- (void)deleteImage:(UIImage *)image completion:(nonnull DeleteImageCompletionCallBackType)completion{
    
    for (int i = 0; i < self.totalArray.count; i ++) {
        UIImage *img = self.totalArray[i];
        if (img == image) {
            [self.totalArray removeObjectAtIndex:i];
            [self.typeArray removeObjectAtIndex:i];

            break;;
        }
        
    }
    
    id<OperationNodeProtocol> curr = (__kindof id<OperationNodeProtocol>)self.operationNodes[@(0)];
    if([curr respondsToSelector:@selector(deleteCacheForImage:completion:)]){
        [curr deleteCacheForImage:image completion:completion];
    }
}

- (void)deleteImageWithName:(NSString *)name completion:(nonnull DeleteImageCompletionCallBackType)completion{
    
    id<OperationNodeProtocol> curr = self.currentOperationNode;
    if([curr respondsToSelector:@selector(deleteCacheForKey:completion:)]){
        [curr deleteCacheForKey:name completion:completion];
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    @autoreleasepool {
        if (connection == [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo]) {

            [self.stitchkLock lock];
            OperationNodeVideoBase *base = nil;
            if ([self.currentOperationNode isKindOfClass:[OperationNodeVideoBase class]]) {
                base = (OperationNodeVideoBase *)self.currentOperationNode;
            }
            LenzResourceItemModel *model = nil;
            if (self.mode == SDK_CAPTURE_MODE_PANORAMA) {
                model = self.resourceModel.panoramArray.lastObject;
            } else if (self.mode == SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA) {
                model = self.resourceModel.aiPanoramArray.lastObject;
            }
            if (!model || (!base.isRecording && !self.isVideoStitchStopedWhenRecording)) {
                [self.stitchkLock unlock];
                return;
            }

            if (self.isVideoStitchStopedWhenRecording &&
                (self.stitchResult != LenVideoStitchResultFail && self.stitchResult != LenVideoStitchResultStitchFail)) {
                [self updateViewStatusWhenStitchSave:YES];
                self.isStitchBigImage = YES;
            }
            LenVideoStitchDirction dirction = LenVideoStitchDirctionLeft;
            if (self.panoramOrientationGuideView.selectedItemIndex == PanoramaOrientationViewUp) {
                if (self.currentTgDirection == TgDirectionDown) {
                    dirction = LenVideoStitchDirctionDown;
                } else {
                    dirction = LenVideoStitchDirctionUp;
                }
            } else if (self.panoramOrientationGuideView.selectedItemIndex == PanoramaOrientationViewDown) {
                if (self.currentTgDirection == TgDirectionDown) {
                    dirction = LenVideoStitchDirctionUp;
                } else {
                    dirction = LenVideoStitchDirctionDown;
                }
            } else if (self.panoramOrientationGuideView.selectedItemIndex == PanoramaOrientationViewLeft) {
                if (self.currentTgDirection == TgDirectionDown) {
                    dirction = LenVideoStitchDirctionRight;
                } else {
                    dirction = LenVideoStitchDirctionLeft;
                }
            } else if (self.panoramOrientationGuideView.selectedItemIndex == PanoramaOrientationViewRight) {
                if (self.currentTgDirection == TgDirectionDown) {
                    dirction = LenVideoStitchDirctionLeft;
                } else {
                    dirction = LenVideoStitchDirctionRight;
                }
            } else {
                dirction = LenVideoStitchDirctionAny;
            }

            [LenStitcher videoStitchWith:sampleBuffer
                                dirction:dirction
                                  isStop:self.isVideoStitchStopedWhenRecording
                                complete:^(LenVideoStitchResult result, LenVideoStitchNeedSave needSave) {
                self.stitchResult = result;
                
                UIImage *image = [LenStitcher getCurrentPanoramaShowImage];
                UIImage *saveImage = [self rotateImageWith:image];
                base.stitchResult = result;
                LenzResourceItemModel *model = nil;
                if (self.mode == SDK_CAPTURE_MODE_PANORAMA) {
                    model = self.resourceModel.panoramArray.lastObject;
                } else if (self.mode == SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA) {
                    model = self.resourceModel.aiPanoramArray.lastObject;
                }
                if (!image || !model) {
                    [self.stitchkLock unlock];
                    return;
                }

                
                if (result == LenVideoStitchResultSuccess) {
                    [self saveStitch:model image:image saveImage:saveImage base:base needSave:needSave];
                } else {
 
                    if (!base.isRecording && self.isVideoStitchStopedWhenRecording) {
                        //停止拼接，移除保存中 非success数据
                        if (self.mode == SDK_CAPTURE_MODE_PANORAMA) {
                            NSMutableArray *array = [NSMutableArray array];
                            [self.resourceModel.panoramArray enumerateObjectsUsingBlock:^(LenzResourceItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                if (obj.path.length) {
                                    [array addObject:obj];
                                }
                            }];
                            self.resourceModel.panoramArray = array;
                        } else if (self.mode == SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA) {
                            NSMutableArray *array = [NSMutableArray array];
                            [self.resourceModel.aiPanoramArray enumerateObjectsUsingBlock:^(LenzResourceItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                if (obj.path.length) {
                                    [array addObject:obj];
                                }
                            }];
                            self.resourceModel.aiPanoramArray = array;
                        }
                        [self updateViewStatusWhenStitchSave:NO];
                        [self updateViewStatus];
                        [self.stitchkLock unlock];
                        return;
                    }
                    if (result == LenVideoStitchResultFail || result == LenVideoStitchResultStitchFail) {
                        [SVProgressHUD showImage:[UIImage imageNamed:@""] status:@"拼接失败"];

                        dispatch_async(dispatch_get_main_queue(), ^{
                            [base takePhotoButtonTouched];
                            [self stopMotion];
                            [self removeLastStich];
                            [self updateViewStatusWhenStitchFail];
                            [self.panoramaGuideView clearImage];
                            [self updateViewStatus];
                            [self.panoramaGuideView showImageWith:nil];
                            self.aiRecordPromtLabel.hidden = YES;
                        });
                        
                        [SVProgressHUD dismissWithDelay:3 completion:^{
                        }];
                    } else if(result == LenVideoStitchResultSlowMore) {
                        
//                        [SVProgressHUD showImage:[UIImage imageNamed:@""] status:@"目标物较少，请对准目标物低速且匀速拍摄"];
                        [self saveStitch:model image:image saveImage:saveImage base:base needSave:needSave];
                    } else if (result == LenVideoStitchResultSlow) {
//                        [SVProgressHUD showImage:[UIImage imageNamed:@""] status:@"目标物较少，请对准目标物低速且匀速拍摄"];
                        [self saveStitch:model image:image saveImage:saveImage base:base needSave:needSave];
                    } else if (result == LenVideoStitchResultModerate) {
                        [SVProgressHUD showImage:[UIImage imageNamed:@""] status:@"请减速拍摄"];
                        [self saveStitch:model image:image saveImage:saveImage base:base needSave:needSave];
                    } else if (result == LenVideoStitchResultParallel) {
                        [SVProgressHUD showImage:[UIImage imageNamed:@""] status:@"请正对目标物拍摄"];
                        [self saveStitch:model image:image saveImage:saveImage base:base needSave:needSave];
                    } else if (result == LenVideoStitchResultDirectError){
//                        [SVProgressHUD showImage:[UIImage imageNamed:@""] status:@"请勿往反方向移动"];
                        [self saveStitch:model image:image saveImage:saveImage base:base needSave:needSave];
                    }
                }
                
                [self.stitchkLock unlock];
            }];
        }
    }
}

- (void)saveStitch:(LenzResourceItemModel *)model image:(UIImage *)image saveImage:(UIImage *)saveImage base:(OperationNodeVideoBase *)base needSave:(LenVideoStitchNeedSave)needSave {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.isStitchBigImage) {
            //保存大图拼接路径
            [[SDKParameters shared].items enumerateObjectsUsingBlock:^(SDKParametersItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.model == self.mode) {
                    model.cameraType = obj.cameraPositionString;
                }
            }];
            model.mode = self.mode;
            if ([LenStitcher getCurrentPanoramaShow]) {
                model.image = image;
                model.previewImage = saveImage;
                NSString *path = [LenzDataManager saveImageWith:UIImageJPEGRepresentation(saveImage, .8) mode:self.mode];
                model.path = path;
            }
            if (self.isStitchBigImage) {
                self.isVideoStitchStopedWhenRecording = NO;
                self.isStitchBigImage = NO;
            }
            [self updateViewStatusWhenStitchSave:NO];
            [self.panoramaGuideView clearImage];
            [self updateViewStatus];
            [self.panoramaGuideView showImageWith:nil];

        } else {
            if (base.isRecording) {
                __block BOOL keyFrame = NO;
                [[SDKParameters shared].items enumerateObjectsUsingBlock:^(SDKParametersItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.model == self.mode) {
                        keyFrame = [obj.keyFrame boolValue];
                    }
                }];
                
                if (needSave && keyFrame) {
                    NSString *path = [LenzDataManager saveImageWith:UIImageJPEGRepresentation(saveImage, .6) mode:self.mode];
                    if (path) {
                        [model.keyFrame addObject:path];
                    }
                }
                if (self.panoramOrientationGuideView.selectedItemIndex != PanoramaOrientationViewAny) {
                    [self.panoramaGuideView showImageWith:image];
                } else {
                    self.ablumImageView.hidden = NO;
                    self.ablumImageView.image = saveImage;
                }
            }

        }
        self.resourceModel.lastIndex = self.mode;
    });
}


- (void)removeLastStich {
    if (self.mode == SDK_CAPTURE_MODE_PANORAMA) {
        if (self.resourceModel.panoramArray.count > 0) {
            if (!self.resourceModel.panoramArray.lastObject.path.length) {
                [self.resourceModel.panoramArray removeLastObject];
            }
        }
    } else if (self.mode == SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA) {
        if (self.resourceModel.aiPanoramArray.count > 0) {
            if (!self.resourceModel.aiPanoramArray.lastObject.path.length) {
                [self.resourceModel.aiPanoramArray removeLastObject];
            }
        }
    }
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
   if([segue.identifier isEqualToString:@"preview_single"]){
        PreviewSingleViewController* dst = segue.destinationViewController;
        dst.singleModeNode = self.currentOperationNode;
        if (self.resourceModel.singleArray.count > 0) {
            LenzResourceItemModel *model = self.resourceModel.singleArray.firstObject;
            dst.image = model.image;
        }
    }
        
}

- (void)clearSingleData {
    [self.resourceModel.singleArray removeAllObjects];
    [self updateViewStatus];
}

- (BOOL)shouldAutorotate {
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


- (UIImage *)videoFrameImageWith:(NSURL *)url {
    AVURLAsset* asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 65);
    CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&err];

    UIImage *frameImage= [[UIImage alloc] initWithCGImage:refImg scale:1.0 orientation:self.thumbnailOritaionByCurrentVideoOrientation];
    return frameImage;
}




- (UIImage *)rotateImageWith:(UIImage *)image {
    if (self.currentTgDirection == TgDirectionPortrait) {
        return image;
    } else if (self.currentTgDirection == TgDirectionLeft) {
        
        OperationNodeAIPanorama *aiPan = nil;
        if ([self.currentOperationNode isKindOfClass:[OperationNodeAIPanorama class]]) {
            aiPan = self.currentOperationNode;
        }
        
        if (self.mode == SDK_CAPTURE_MODE_PANORAMA || (aiPan && aiPan.AIType == OperationAITypeLongPress)) {
            image = [[UIImage alloc]initWithCGImage:image.CGImage
                                                                 scale:1.0
                                                           orientation:UIImageOrientationLeft];
        } else {
            image = [[UIImage alloc]initWithCGImage:image.CGImage
                                                                 scale:1.0
                                                           orientation:UIImageOrientationUp];
        }

        return image;
    } else if (self.currentTgDirection == TgDirectionRight) {
        OperationNodeAIPanorama *aiPan = nil;
        if ([self.currentOperationNode isKindOfClass:[OperationNodeAIPanorama class]]) {
            aiPan = self.currentOperationNode;
        }
        if (self.mode == SDK_CAPTURE_MODE_PANORAMA || (aiPan && aiPan.AIType == OperationAITypeLongPress)) {
            image = [[UIImage alloc]initWithCGImage:image.CGImage
                                                                 scale:1.0
                                                           orientation:UIImageOrientationRight];
        } else {
            image = [[UIImage alloc]initWithCGImage:image.CGImage
                                                                 scale:1.0
                                                           orientation:UIImageOrientationDown];
        }
        return image;
    } else if (self.currentTgDirection == TgDirectionDown) {
        OperationNodeAIPanorama *aiPan = nil;
        if ([self.currentOperationNode isKindOfClass:[OperationNodeAIPanorama class]]) {
            aiPan = self.currentOperationNode;
        }
        if (self.mode == SDK_CAPTURE_MODE_PANORAMA || (aiPan && aiPan.AIType == OperationAITypeLongPress)) {
            image = [[UIImage alloc]initWithCGImage:image.CGImage
                                                                 scale:1.0
                                                           orientation:UIImageOrientationDown];
        } else {
            image = [[UIImage alloc]initWithCGImage:image.CGImage
                                                                 scale:1.0
                                                           orientation:UIImageOrientationLeft];
        }
        return image;

    }
    
    return image;
}


@end
