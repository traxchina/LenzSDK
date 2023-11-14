//
//  LenzSDKConstant.h
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/28.
//

#ifndef LenzSDKConstant_h
#define LenzSDKConstant_h

typedef enum SDKFlashModeIndex {
    SDK_FLASH_MODE_AUTO,
    SDK_FLASH_MODE_ON,
    SDK_FLASH_MODE_OFF,
} SDKFlashModeIndex;

typedef enum SDKCaptureModeIndex {
    /// 连拍
    SDK_CAPTURE_MODE_CONTINUOUS,
    /// 单拍
    SDK_CAPTURE_MODE_SINGLE,
    /// 视频
    SDK_CAPTURE_MODE_MOVIE,
    /// 全景
    SDK_CAPTURE_MODE_PANORAMA,
    /// 智能全景
    SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA,
    ///
    SDK_CAPTURE_MODE_UNKNOW,

} SDKCaptureModeIndex;

typedef enum SDKDataRetainedModeIndex{
    SDK_DATA_RETAINED_RETAIN,
    SDK_DATA_RETAINED_CLEAR,
    SDK_DATA_RETAINED_USER_CONFIRM,
}SDKDataRetainedModeIndex;

typedef enum SDKCameraPosition {
    SDK_CAMERA_PISITION_FRONT,
    SDK_CAMERA_PISITION_BACK,
} SDKCameraPosition;

typedef enum SDKCameraCapturedResourceIndex{
    SDKCameraCapturedResourceIndexPhoto = 1,
    SDKCameraCapturedResourceIndexMovie = 2,
    SDKCameraCapturedResourceIndexOthers = 3,
}SDKCameraCapturedResourceIndex;

typedef enum SDKVideoQuality{
    SDK_VIDEO_QUALITY_480,
    SDK_VIDEO_QUALITY_720,
    SDK_VIDEO_QUALITY_1080,
    SDK_VIDEO_QUALITY_2160,
}SDKVideoQuality;

extern const NSNotificationName LenzSDKNotificationDiskIsFull;
extern const NSNotificationName CameraNotificationNotPermission;
extern const NSNotificationName MicrophoneNotificationNotPermission;

#endif /* LenzSDKConstant_h */
