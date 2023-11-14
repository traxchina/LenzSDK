//
//  QuitMultipleModeAlertViewController.h
//  sampleSDK
//
//  Created by 王昭威 on 2023/1/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PCSButton;
@interface QuitMultipleModeAlertViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIView* contentView;

@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* textLabel;
@property (nonatomic, weak) IBOutlet PCSButton* leftButton;
@property (nonatomic, weak) IBOutlet PCSButton* rightButton;

+ (void)show:(UIViewController *)controller withSaveButtonCallBack: (void(^)(QuitMultipleModeAlertViewController* alertController))saveCallBack discardButtonCallBack: (void(^)(QuitMultipleModeAlertViewController* alertController))discardCallBack;

+ (void)show:(UIViewController *)controller title: (nullable NSString*)title text: (nullable NSString*)text leftBtnTitle: (nullable NSString*)leftBtnTitle rightBtnTitle: (nullable NSString*)rightBtnTitle withLeftButtonCallBack: (void(^)(QuitMultipleModeAlertViewController* alertController))leftBtnCallBack rightButtonCallBack: (void(^)(QuitMultipleModeAlertViewController* alertController))rightBtnCallBack;

- (IBAction)saveButtonTouchUpInside:(id)sender;
- (IBAction)discardButtonTouchUpInside: (id)sender;

@end

NS_ASSUME_NONNULL_END
