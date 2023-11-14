//
//  PhotoAlbumListViewController.m
//  LenzCameraNativeModuleForRN
//
//  Created by 伯爵 on 2023/2/6.
//

#import "PhotoAlbumListViewController.h"
#import "PhotoCollectionViewCell.h"
#import "PhotoListCellModel.h"
#import "PhotoCell.h"

@interface PhotoAlbumListViewController ()

@property (nonatomic ,strong)UIButton *selectBtn;

@end

@implementation PhotoAlbumListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.panoramaLabWidth.constant = 0;
    self.intelligenceLabWidth.constant = 0;

    [self setTypeLab:self.typeArray];
    
    self.datasLab.text = [NSString stringWithFormat:@"共%lu笔数据",(unsigned long)self.typeArray.count];
    
    [self showPhotoAndMovie];
    
    
}

- (void)showPhotoAndMovie{
//    [self.photoListVC.view removeFromSuperview];
//    [self.movieListVC.view removeFromSuperview];

    NSString *typeStr = self.typeArray.lastObject;
    if ([typeStr isEqualToString:@"photo"]) {
        self.selectBtn = self.continuousBtn;
        self.oldVC = self.photoListVC;

        [self.continuousBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        self.photoListVC.view.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
        [self addChildViewController:self.photoListVC];
        [self.contentView addSubview:self.photoListVC.view];
        
        [self.photoListVC didMoveToParentViewController:self];

    }else if ([typeStr isEqualToString:@"movie"]) {
        self.selectBtn = self.movieBtn;

        self.oldVC = self.movieListVC;

        [self.movieBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        self.movieListVC.view.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
        [self addChildViewController:self.movieListVC];
        [self.contentView addSubview:self.movieListVC.view];
        [self.movieListVC didMoveToParentViewController:self];

    }
}

- (PhotoListViewController *)photoListVC{
    if (!_photoListVC) {
        _photoListVC = [PhotoListViewController makeViewController];
    }
    return _photoListVC;
}

- (MovieListViewController *)movieListVC{
    if (!_movieListVC) {
        _movieListVC = [MovieListViewController movieMakeViewController];
    }
    return _movieListVC;
}

- (void)setTypeLab:(NSMutableArray *)types{
    if([types indexOfObject:@"photo"] != NSNotFound) {
            self.continuousLabWidth.constant = 50;
    }else{
            self.continuousLabWidth.constant = 0;
        NSLog(@"不存在");
    }
    if([types indexOfObject:@"movie"] != NSNotFound) {

            self.movieLabWidth.constant = 50;
    }else{
          
          self.movieLabWidth.constant = 0;

    }
   
}

- (UIViewController *)newVC{
    if (self.oldVC == self.photoListVC) {
        [self addChildViewController:self.movieListVC];
        return self.movieListVC;
    }else if (self.oldVC == self.movieListVC) {
        [self addChildViewController:self.photoListVC];
        return self.photoListVC;
    }
    return nil;
}

- (IBAction)buttonsBtnClick:(UIButton *)sender {
    
    if (self.selectBtn == sender) {
        return;
    }
    self.selectBtn = sender;
    if (self.oldVC == self.photoListVC) {
        [self addChildViewController:self.movieListVC];
        self.movieListVC.view.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
    }else if (self.oldVC == self.movieListVC) {
        [self addChildViewController:self.photoListVC];
        self.photoListVC.view.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
    }

    
    [self addChildViewController:self.photoListVC];

    UIViewController *newVC = [self newVC];
    [self transitionFromViewController:self.oldVC toViewController:newVC duration:0 options:UIViewAnimationTransitionNone animations:nil completion:^(BOOL finished) {
        if (finished) {
            [newVC didMoveToParentViewController:self];
            [self.oldVC willMoveToParentViewController:nil];
            [self.oldVC removeFromParentViewController];
            self.oldVC = newVC;
        }
    }];
    
    
    
    for (UIButton *btn in self.buttons) {
        if (btn == sender) {
            [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        }else{
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}





@end
