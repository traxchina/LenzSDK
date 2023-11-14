//
//  QuitMultipleModeAlertViewController.m
//  sampleSDK
//
//  Created by 王昭威 on 2023/1/18.
//

#import "QuitMultipleModeAlertViewController.h"
#import "PCSTools.h"
#import "PCSButton.h"
#import "UIColor+JKAdd.h"
#import <Masonry/Masonry.h>

@interface QuitMultipleModeAlertViewController ()

@property (nonatomic, strong) UIViewPropertyAnimator* animator;

@property (nonatomic, copy) void(^saveBlock)(QuitMultipleModeAlertViewController*);
@property (nonatomic, copy) void(^discardBlock)(QuitMultipleModeAlertViewController*);

@end

@implementation QuitMultipleModeAlertViewController

+ (void)show:(UIViewController *)controller withSaveButtonCallBack: (void(^)(QuitMultipleModeAlertViewController* alertController))saveCallBack discardButtonCallBack: (void(^)(QuitMultipleModeAlertViewController* alertController))discardCallBack{
    
    [self show:controller title:nil text:nil leftBtnTitle:nil rightBtnTitle:nil withLeftButtonCallBack:discardCallBack rightButtonCallBack:saveCallBack];
}

+ (void)show:(UIViewController *)controller title:(NSString *)title text:(NSString *)text leftBtnTitle:(NSString *)leftBtnTitle rightBtnTitle:(NSString *)rightBtnTitle withLeftButtonCallBack:(void (^)(QuitMultipleModeAlertViewController * _Nonnull))leftBtnCallBack rightButtonCallBack:(void (^)(QuitMultipleModeAlertViewController * _Nonnull))rightBtnCallBack{
    
    QuitMultipleModeAlertViewController* instance = [[QuitMultipleModeAlertViewController alloc] initWithNibName:@"QuitMultipleModeAlertViewController" bundle:[PCSTools sdkBundle]];
    if(instance != nil){
        __weak typeof(instance) weakIns = instance;
        [instance loadView];
        instance.saveBlock = rightBtnCallBack;
        instance.discardBlock = leftBtnCallBack;
        if(title != nil){
            instance.title = title;
        }
        if(text != nil){
            instance.textLabel.text = text;
        }
        if(leftBtnTitle != nil){
            [instance.leftButton setTitle:leftBtnTitle forState:UIControlStateNormal];
        }
        if(rightBtnTitle != nil){
            [instance.rightButton setTitle:rightBtnTitle forState:UIControlStateNormal];
        }
        [instance addline];
        instance.contentView.layer.transform = CATransform3DScale(instance.contentView.layer.transform, 0.1, 0.1, 1);
        instance.animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.5 dampingRatio:0.3 animations:^{
            weakIns.contentView.layer.transform = CATransform3DIdentity;
        }];
        
        instance.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [controller presentViewController:instance animated:NO completion:^{
            [instance.animator startAnimation];
        }];
    }
}

- (instancetype)init{
    self = [super init];
    if(self){
    }
    return self;
}

-(void)addline{
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = [UIColor jk_colorWithHexString:@"#e5e5e5"];
    [self.leftButton addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.offset(0);
        make.width.offset(0.5);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)saveButtonTouchUpInside:(id)sender{
    self.saveBlock(self);
}

- (IBAction)discardButtonTouchUpInside: (id)sender{
    self.discardBlock(self);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
