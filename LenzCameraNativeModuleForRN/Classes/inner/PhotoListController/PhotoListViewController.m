//
//  PhotoListViewController.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/22.
//

#import "PhotoListViewController.h"
#import "UIButton+Layout.h"
#import "PCSButton.h"
#import "PhotoCollectionViewCell.h"
#import "PhotoListCellModel.h"
#import "ImageCacheLRU.h"
#import "AlbumCounterLabel.h"
#import "QuitMultipleModeAlertViewController.h"
#import "LenzHeader.h"

@interface PhotoListViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) ImageCacheLRU* lru;

@end

@implementation PhotoListViewController

#pragma mark - others
- (void)setImagesInMemory:(NSArray<UIImage *> *)imagesInMemory andImageNamesOnDisk:(NSArray<NSString *> *)imageNamesOnDisk{
    
    NSMutableArray<__kindof PhotoListCellModel*>* models = [NSMutableArray array];
    [imageNamesOnDisk enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [models addObject: [[PhotoListCellModel alloc] initWithName:obj andImage:nil]];
    }];
    
    [imagesInMemory enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [models addObject: [[PhotoListCellModel alloc] initWithName:nil andImage:obj]];
    }];
    
    self.cellModels = [[NSMutableArray alloc] initWithArray:models];


}

#pragma mark - Button
- (void)backButtonTouchUpInside:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)deletedCachedResourceSuccessfulAtIndex:(NSInteger)deletedPageIndex{
    [self deletedImageSuccessfulAtIndex:deletedPageIndex];
}

- (void)deletedImageSuccessfulAtIndex: (NSInteger)deletedPageIndex{
    
    if(deletedPageIndex >= 0 && deletedPageIndex < self.cellModels.count){
        NSInteger currIdx = [self currentPageIndex];
        [self.cellModels removeObjectAtIndex:deletedPageIndex];
        [self.photoCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:deletedPageIndex inSection:0]]];
        currIdx = MIN(MAX(0, currIdx), MAX(self.cellModels.count, 1) - 1);
        [self updatePageIndexLabelWithCurrentIndex:currIdx];
    }
    
    [self.presentedViewController dismissViewControllerAnimated:NO completion:^{
        if(self.cellModels.count == 0){
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
    }];
}

- (void)deleteButtonTouchUpInside:(id)sender{
    NSInteger currPageIdx = MAX(self.currentPageIndex, 0);
    [QuitMultipleModeAlertViewController show:self title:nil text:LOCALIZATION_STRING_KEY_DELETE_IMAGE_ALERT_TEXT leftBtnTitle:LOCALIZATION_STRING_KEY_DELETE_ALERT_BTN_TITLE_CANCEL rightBtnTitle:LOCALIZATION_STRING_KEY_DELETE_ALERT_BTN_TITLE_CONFIRM withLeftButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
        
        [alertController dismissViewControllerAnimated:NO completion:^{}];
        
    } rightButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
        if(self.cellModels.count > currPageIdx){
            PhotoListCellModel* cellModel = self.cellModels[currPageIdx];
            if(cellModel.name != nil){
                [self.delegate deleteImageWithName:cellModel.name completion:^(BOOL successful) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(successful){
                            [self deletedImageSuccessfulAtIndex:currPageIdx];
                        }
                    });
                }];
            }
            else{
                [self.delegate deleteImage:cellModel.image completion:^(BOOL successful) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(successful){
                            [self deletedImageSuccessfulAtIndex:currPageIdx];
                        }
                    });
                }];
            }
        }
    }];
}

- (void)updatePageIndexLabelWithCurrentIndex: (NSInteger)currIdx{
    self.counterLabel.text = [NSString stringWithFormat:@"第%@/%@张", @(currIdx + 1), @(self.cellModels.count)];
}

+ (instancetype)makeViewController{
    UIStoryboard* sb = [UIStoryboard storyboardWithName:[PCSTools shared].mainStoryboardName bundle:[PCSTools sdkBundle]];
    return [sb instantiateViewControllerWithIdentifier:@"PhotoListVC"];
}

#pragma mark - Life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeNum:) name:@"changeNum" object:nil];

    self.lru = [[ImageCacheLRU alloc] init];
    [self.view layoutIfNeeded];
    
    [self updatePageIndexLabelWithCurrentIndex:0];
}

- (void)changeNum:(NSNotification *)notification{
    NSString *str = notification.object;
    NSInteger currentPage = [str integerValue];
    NSLog(@"====:%ld",(long)currentPage);
    [self updatePageIndexLabelWithCurrentIndex:currentPage];
}

- (NSInteger)currentPageIndex{
    CGFloat pageWidth = self.photoCollectionView.frame.size.width;
    NSInteger currentPage = round(self.photoCollectionView.contentOffset.x / pageWidth);
    return currentPage;
}

- (UIImage* _Nullable)loadImageForKey: (NSString*)key{
    UIImage* img = nil;
    NSString* imgName = key;
    NSData* imgData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[[PCSTools shared].tmpPath stringByAppendingPathComponent:imgName]]];
    img = [UIImage imageWithData:imgData];
    return img;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(CGRectGetWidth(self.photoCollectionView.bounds), CGRectGetHeight(self.photoCollectionView.bounds));
}

#pragma mark - UICollectionViewDelegate and DataSource
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger currentPage = self.currentPageIndex;
    [self updatePageIndexLabelWithCurrentIndex:currentPage];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.cellModels.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PhotoCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if(self.cellModels.count > indexPath.item){
        PhotoListCellModel* cellModel = self.cellModels[indexPath.item];
        if(cellModel.image == nil && cellModel.name != nil){
            UIImage* img = [self.lru queryByKey: cellModel.name];
            if(img == nil){
                img = [self loadImageForKey:cellModel.name];
                cellModel.image = img;
                [self.lru insertByKey:cellModel.name image:img];
            }
        }
        cell.cellModel = cellModel;
    }

    return cell;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [self.backButton centerVertically];
    [self.deleteButton centerVertically];
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
