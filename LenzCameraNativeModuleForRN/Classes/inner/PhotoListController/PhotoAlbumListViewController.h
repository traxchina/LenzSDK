//
//  PhotoAlbumListViewController.h
//  LenzCameraNativeModuleForRN
//
//  Created by 伯爵 on 2023/2/6.
//

#import <UIKit/UIKit.h>
#import "PhotoListViewController.h"
#import "OperationNodeMultiple.h"
#import "MovieListViewController.h"

NS_ASSUME_NONNULL_BEGIN



@interface PhotoAlbumListViewController : UIViewController


@property (nonatomic , strong)PhotoListViewController *photoListVC;
@property (nonatomic , strong)OperationNodeMultiple *node;

@property (nonatomic , strong)MovieListViewController *movieListVC;
//@property (nonatomic , strong)OperationNodeMultiple *node;

@property (nonatomic , strong)UIViewController *oldVC;

@property (nonatomic, readonly) NSInteger currentPageIndex;

//总类型数组
@property (nonatomic , strong)NSMutableArray *typeArray;

//连拍数据
@property (nonatomic , strong)NSMutableArray *continuousImgs;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (weak, nonatomic) IBOutlet UILabel *datasLab;

@property (weak, nonatomic) IBOutlet UIView *contentView;


@property (weak, nonatomic) IBOutlet UIButton *continuousBtn;
@property (weak, nonatomic) IBOutlet UIButton *movieBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *continuousLabWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *movieLabWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *panoramaLabWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *intelligenceLabWidth;


@end



NS_ASSUME_NONNULL_END
