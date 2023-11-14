//
//  PCSAutherView.h
//  LenzSDK
//
//  Created by lr on 2023/4/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, PCSAuthType) {
    PCSAuthPhoneAndMir,
    PCSAuthPhone,
    PCSAuthMir
    
};

typedef void(^PCSAutherViewCloseBlock)(void);

@interface PCSAutherView : UIView

@property (nonatomic)PCSAutherViewCloseBlock closeBlock;
- (void)showAutherWith:(PCSAuthType)type;

@end

NS_ASSUME_NONNULL_END
