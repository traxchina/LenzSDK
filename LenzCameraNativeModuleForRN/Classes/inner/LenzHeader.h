//
//  LenzHeader.h
//  LenzCameraNativeModuleForRN-LenzCameraNativeModuleForRN
//
//  Created by lr on 2023/3/8.
//

#ifndef LenzHeader_h
#define LenzHeader_h


#import "PCSTools.h"
#import "UIImage+name.h"
#import "NSString+Localization.h"
#import <Masonry/Masonry.h>
#import "UIImage+ext.h"
#import "PCSMotionManager.h"
#import "PCSThemeColorManager.h"
#import "UIView+JKAdd.h"
#import "UIColor+JKAdd.h"

#define LOCALIZATION_STRING_KEY_DELETE_ALERT_BTN_TITLE_CONFIRM [@"btn-title-confirm" localization]
#define LOCALIZATION_STRING_KEY_DELETE_ALERT_BTN_TITLE_CANCEL [@"btn-title-cancel" localization]
#define LOCALIZATION_STRING_KEY_DELETE_IMAGE_ALERT_TEXT [@"delete-image-alert-text" localization]
#define LOCALIZATION_STRING_KEY_NUM_OF_MOVIES [@"number-of-movies" localization]
#define LOCALIZATION_STRING_KEY_NUM_OF_PHOTOS [@"number-of-photos" localization]
#define LOCALIZATION_STRING_KEY_TIP_FOR_AI_PANORAMA [@"tip-for-ai-panorama" localization]

#define LOCALIZATION_STRING_KEY_MODE_TITLE_MULTIPLE [@"mode-title-multiple" localization]
#define LOCALIZATION_STRING_KEY_MODE_TITLE_SINGLE [@"mode-title-single" localization]
#define LOCALIZATION_STRING_KEY_MODE_TITLE_MOVIE [@"mode-title-movie" localization]
#define LOCALIZATION_STRING_KEY_MODE_TITLE_PANORAMIC [@"mode-title-panoramic" localization]
#define LOCALIZATION_STRING_KEY_MODE_TITLE_AI_PANORAMIC [@"mode-title-ai-panoramic" localization]

// iPhone带有安全区的或者刘海屏幕
#define JK_IS_IPHONE_X   ({ \
        BOOL iPhoneXSeries = NO; \
        if (@available(iOS 11.0, *)) { \
            UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window]; \
            if (mainWindow.safeAreaInsets.bottom > 0.0) { \
                iPhoneXSeries = YES; \
            } \
        } \
        iPhoneXSeries; \
    })

#endif /* LenzHeader_h */
