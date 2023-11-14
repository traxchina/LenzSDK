//
//  PreviewSingleViewController.h
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/31.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PCSButton;
@protocol OperationNodeProtocol;
@interface PreviewSingleViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet PCSButton* backButton;
@property (nonatomic, strong) IBOutlet PCSButton* saveButton;

@property (nonatomic, strong) UIImage* image;

@property (nonatomic, strong) id<OperationNodeProtocol> singleModeNode;

- (IBAction)backButtonTouchUpInside:(id)sender;
- (IBAction)saveButtonTouchUpInside:(id)sender;

@end

NS_ASSUME_NONNULL_END
