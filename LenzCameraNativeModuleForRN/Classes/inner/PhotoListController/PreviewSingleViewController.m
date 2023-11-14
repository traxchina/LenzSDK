//
//  PreviewSingleViewController.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/31.
//

#import "PreviewSingleViewController.h"
#import "OperationNodeProtocol.h"

@interface PreviewSingleViewController ()

@end

@implementation PreviewSingleViewController

- (void)setImage:(UIImage *)image{
    _image = image;
    self.imageView.image = image;
}

- (void)backButtonTouchUpInside:(id)sender{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.singleModeNode clear];
    }];
}

- (void)saveButtonTouchUpInside:(id)sender{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.singleModeNode save];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imageView.image = self.image;
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
