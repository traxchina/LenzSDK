//
//  MovieListViewController.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/23.
//

#import "MovieListViewController.h"
#import "OperationNodeMovie.h"
#import "PhotoListCellModel.h"
#import "CollectionViewPlayerCell.h"
#import "MoviePlayerViewController.h"
#import "MovieListCellModel.h"
#import "QuitMultipleModeAlertViewController.h"

@interface MovieListViewController ()

@property (nonatomic, weak) CollectionViewPlayerCell* currentCell;

@end

@implementation MovieListViewController

- (void)setMovieModels:(NSArray<__kindof RecordedMovieModel *> *)movieModels{
    _movieModels = movieModels;
    NSMutableArray<__kindof PhotoListCellModel*>* cellModels = [[NSMutableArray alloc] initWithCapacity:MAX(self.movieModels.count, 1)];
    [self.movieModels enumerateObjectsUsingBlock:^(__kindof RecordedMovieModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        MovieListCellModel* model = [[MovieListCellModel alloc] init];
        model.movieModel = obj;
        [cellModels addObject: model];
    }];
    
    self.cellModels = cellModels;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.currentCell stop];
}

+ (instancetype)movieMakeViewController{
    UIStoryboard* sb = [UIStoryboard storyboardWithName:[PCSTools shared].mainStoryboardName bundle:[PCSTools sdkBundle]];
    return [sb instantiateViewControllerWithIdentifier:@"MovieListVC"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.currentCell stop];
    self.currentCell = nil;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger currentPage = self.currentPageIndex;    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeNum" object:[NSString stringWithFormat:@"%ld",(long)currentPage]];
//    [self.photoListVC updatePageIndexLabelWithCurrentIndex:currentPage];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell* cell = [self.photoCollectionView cellForItemAtIndexPath:indexPath];
    if(cell != nil && [cell isKindOfClass:[CollectionViewPlayerCell class]]){
        CollectionViewPlayerCell* playerCell = (CollectionViewPlayerCell*)cell;
        if(self.currentCell == playerCell){
            [self.currentCell stop];
            self.currentCell = nil;
        }
        else{
            if(self.currentCell.playerController.player.currentItem != nil){
                [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentCell.playerController.player.currentItem];
            }
            
            [self.currentCell stop];
            self.currentCell = playerCell;
            AVPlayer* player = [playerCell play];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
        }
    }
}

- (void)playerDidEnd: (NSNotification*)noti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentCell.playerController.player.currentItem];
    self.currentCell.playIconView.hidden = NO;
    self.currentCell = nil;
}

- (void)backButtonTouchUpInside:(id)sender{
    [self.currentCell stop];
    dispatch_async(dispatch_get_main_queue(), ^{
        [super backButtonTouchUpInside:sender];
    });
}

- (void)deleteButtonTouchUpInside:(id)sender{
    NSInteger currPageIdx = MAX(self.currentPageIndex, 0);
    [QuitMultipleModeAlertViewController show:self title:nil text:LOCALIZATION_STRING_KEY_DELETE_IMAGE_ALERT_TEXT leftBtnTitle:LOCALIZATION_STRING_KEY_DELETE_ALERT_BTN_TITLE_CANCEL rightBtnTitle:LOCALIZATION_STRING_KEY_DELETE_ALERT_BTN_TITLE_CONFIRM withLeftButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
        
        [alertController dismissViewControllerAnimated:NO completion:^{}];
        
    } rightButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
        if(self.cellModels.count > currPageIdx){
            MovieListCellModel* cellModel = self.cellModels[currPageIdx];
            if(cellModel.movieModel != nil){
                [self.delegate deleteMovie:cellModel completion:^(BOOL successful) {
                    if(successful){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self deletedCachedResourceSuccessfulAtIndex:currPageIdx];
                        });
                    }
                }];
            }
        }
    }];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
