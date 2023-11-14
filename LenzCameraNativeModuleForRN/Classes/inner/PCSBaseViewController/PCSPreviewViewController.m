//
//  PCSPreviewViewController.m
//  LenzCameraNativeModuleForRN
//
//  Created by lr on 2023/3/11.
//

#import "PCSPreviewViewController.h"
#import <Masonry/Masonry.h>
#import "QuitMultipleModeAlertViewController.h"
#import "UIImage+name.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "YBImageBrowser.h"

@interface PCSPreCollectionCell : UICollectionViewCell

@property (nonatomic) LenzResourceItemModel *model;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIImageView *videoImageView;
@property (nonatomic) AVPlayerViewController *player;
@property (nonatomic) BOOL isPlayer;



@end

@implementation PCSPreCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(0);
        }];
        [self.contentView addSubview:self.player.view];

        [self.contentView addSubview:self.videoImageView];
        [self.videoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.contentView);
            make.width.height.mas_offset(48);
        }];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name:AVPlayerItemDidPlayToEndTimeNotification  object:nil];

    }
    return self;
}
- (void)setModel:(LenzResourceItemModel *)model {
    _model = model;
    self.imageView.image = model.previewImage;
    if (model.mode == SDK_CAPTURE_MODE_MOVIE) {
        self.videoImageView.hidden = NO;
        self.imageView.userInteractionEnabled = NO;
    } else {
        self.videoImageView.hidden = YES;
        self.imageView.userInteractionEnabled = YES;

    }
}

- (void)tapAction {
    if (_model.mode != SDK_CAPTURE_MODE_MOVIE) {
        YBIBImageData *data = [YBIBImageData new];
//        data.imagePath = _model.path;
        __weak typeof(self) weakSelf = self;
        data.image = ^UIImage * _Nullable{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            return strongSelf.model.previewImage;
        };
//        data.allowSaveToPhotoAlbum = NO;
        YBImageBrowser *browser = [YBImageBrowser new];
        browser.dataSourceArray = @[data];
        browser.defaultToolViewHandler.topView.hidden = YES;
        [browser show];
    }
}

- (void)setIsPlayer:(BOOL)isPlayer {

    if (isPlayer) {
        AVPlayer *player = [AVPlayer playerWithURL:[NSURL URLWithString:_model.path]];
        self.player.player = player;
        [self.player.player play];
        self.player.view.hidden = NO;
        self.videoImageView.hidden = YES;
    } else {
        [self.player.player pause];
        self.player.view.hidden = YES;
        self.videoImageView.hidden = NO;
    }
}

- (void)playerAction {
    if (self.player.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
        [self.player.player pause];
        self.videoImageView.hidden = NO;
    } else {
        [self.player.player play];
        self.videoImageView.hidden = YES;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.player.view.frame = self.contentView.bounds;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.layer.cornerRadius = 8;
        _imageView.layer.masksToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
        [_imageView addGestureRecognizer:tap];
    }
    return _imageView;
}

- (UIImageView *)videoImageView {
    if (!_videoImageView) {
        _videoImageView = [[UIImageView alloc]init];
        _videoImageView.image =  [UIImage loadNamed:@"icon_video"];
        _videoImageView.hidden = YES;
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playerAction)];
//        [_videoImageView addGestureRecognizer:tap];
    }
    return _videoImageView;
}

- (AVPlayerViewController *)player {
    if (!_player) {
        _player = [[AVPlayerViewController alloc]init];
        _player.view.hidden = YES;
        _player.view.backgroundColor = [UIColor clearColor];
        _player.videoGravity = AVLayerVideoGravityResizeAspect;
        _player.showsPlaybackControls = NO;

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playerAction)];
        [_player.view addGestureRecognizer:tap];
    }
    
    return _player;
}

- (void)playbackFinished {
    if (_model.mode == SDK_CAPTURE_MODE_MOVIE) {
        self.videoImageView.hidden = NO;
        self.player.view.hidden = YES;
    }
}


@end



@interface PCSPreviewViewController ()<UIScrollViewDelegate, AVPlayerViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) UILabel *countLabel;
@property (nonatomic) UIView *modeView;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UILabel *curentLabel;
@property (nonatomic) UIView *bottomView;
@property (nonatomic) UIButton *backButton;
@property (nonatomic) UILabel *backLabel;
@property (nonatomic) UIButton *deleteButton;
@property (nonatomic) UILabel *deleteLabel;

@property (nonatomic) UIImageView *lineImageView;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic) UIImageView *videoImageView;
@property (nonatomic) AVPlayerViewController *lastPlayer;

//@property (nonatomic) NSInteger currentModeDataIndex;

@property (nonatomic) NSMutableArray <AVPlayerViewController *> *allPlayer;

@property (nonatomic) UICollectionView* collectionView;
@property (nonatomic) NSIndexPath *playerIndexPath;
@property (nonatomic) NSIndexPath *currentIndexPath;

@end

@implementation PCSPreviewViewController
- (void)dealloc {
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.allPlayer  = [NSMutableArray array];

    self.view.backgroundColor = [UIColor colorWithRed:60/255.0 green:58/255.0 blue:61/255.0 alpha:1];
    
    [self.view addSubview:self.countLabel];
    CGFloat top = UIApplication.sharedApplication.delegate.window.safeAreaInsets.top;
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(top + 20);
        make.right.mas_offset(-20);
        make.height.mas_offset(44);
    }];
    [self.view addSubview:self.modeView];
    [self.modeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(0);
        make.top.mas_equalTo(self.countLabel);
        make.height.mas_equalTo(self.countLabel);
        make.right.mas_equalTo(self.countLabel.mas_left).mas_offset(-10);
    }];
    [self setupModeView];
    
   
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_offset(0);
        make.height.mas_offset(150);
    }];
    [self.bottomView addSubview:self.backLabel];
    [self.backLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_offset(-30);
        make.centerX.mas_equalTo(self.bottomView).mas_offset(-60);
    }];
    [self.bottomView addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.backLabel.mas_top).mas_offset(-20);
        make.centerX.mas_equalTo(self.backLabel);
        make.width.height.mas_offset(60);
    }];
    [self.bottomView addSubview:self.deleteLabel];
    [self.deleteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_offset(-30);
        make.centerX.mas_equalTo(self.bottomView).mas_offset(60);
    }];
    [self.bottomView addSubview:self.deleteButton];
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.deleteLabel.mas_top).mas_offset(-20);
        make.centerX.mas_equalTo(self.deleteLabel);
        make.width.height.mas_offset(60);
    }];
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 40, [UIScreen mainScreen].bounds.size.height - top - 224);
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.hidden = YES;
    // 注册item类型
    [self.collectionView registerClass:[PCSPreCollectionCell class] forCellWithReuseIdentifier:@"PCSPreCollectionCell"];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(20);
        make.right.mas_offset(-20);
        make.top.mas_equalTo(self.countLabel.mas_bottom).mas_offset(10);
        make.bottom.mas_equalTo(self.bottomView.mas_top);
    }];


    self.currentIndexPath = nil;
    
    if (self.model.continousArray.count > 0 && self.selectIndex == SDK_CAPTURE_MODE_CONTINUOUS) {
        self.currentIndex = 1;
        self.currentIndexPath = [NSIndexPath indexPathForItem:self.model.continousArray.count - 1 inSection:0];
    }
    if (self.model.movieArray.count > 0 && self.selectIndex == SDK_CAPTURE_MODE_MOVIE) {
        self.currentIndex = 2;
        self.currentIndexPath = [NSIndexPath indexPathForItem:self.model.movieArray.count - 1 inSection:1];
    }
    if (self.model.panoramArray.count > 0 && self.selectIndex == SDK_CAPTURE_MODE_PANORAMA) {
        self.currentIndex = 3;
        self.currentIndexPath = [NSIndexPath indexPathForItem:self.model.panoramArray.count - 1 inSection:2];
    }
    
    if (self.model.aiPanoramArray.count > 0 && self.selectIndex == SDK_CAPTURE_MODE_INTELLEGENCE_PANORAMA) {
        self.currentIndex = 4;
        self.currentIndexPath = [NSIndexPath indexPathForItem:self.model.aiPanoramArray.count - 1 inSection:3];
    }
    if(!self.currentIndexPath) {
        if (self.model.aiPanoramArray.count > 0) {
            self.currentIndex = 4;
            self.currentIndexPath = [NSIndexPath indexPathForItem:self.model.aiPanoramArray.count - 1 inSection:3];
        } else if (self.model.panoramArray.count > 0) {
            self.currentIndex = 3;
            self.currentIndexPath = [NSIndexPath indexPathForItem:self.model.panoramArray.count - 1 inSection:2];
        } else if (self.model.movieArray.count > 0) {
            self.currentIndex = 2;
            self.currentIndexPath = [NSIndexPath indexPathForItem:self.model.movieArray.count - 1 inSection:1];
        } else {
            self.currentIndex = 1;
            self.currentIndexPath = [NSIndexPath indexPathForItem:self.model.continousArray.count - 1 inSection:0];
        }
    }
    [self changeLabelStatusWith:self.currentIndex];
    [self updateCountLabelWith:self.currentIndexPath];

    
    [self.view addSubview:self.curentLabel];
    [self.curentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.width.mas_offset(100);
        make.height.mas_offset(32);
        make.bottom.mas_equalTo(self.collectionView).mas_offset(16);
    }];

}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.collectionView.hidden = NO;
        UICollectionViewLayoutAttributes*attributes = [self.collectionView layoutAttributesForItemAtIndexPath:self.currentIndexPath];
        CGRect rect = attributes.frame;
        [self.collectionView setContentOffset:CGPointMake(rect.origin.x, rect.origin.y ) animated:NO];
    });
}


- (UIImageView *)lineImageView {
    if (!_lineImageView) {
        _lineImageView = [[UIImageView alloc]init];
        _lineImageView.image = [UIImage loadNamed:@"icon_preview_line"];
    }
    return _lineImageView;
}

- (void)updateCountLabelWith:(NSIndexPath *)indexPath {
    if (!indexPath) {
        return;
    }
    if (indexPath.section == 0) {
        self.curentLabel.text = [NSString stringWithFormat:@"第%ld/%ld张", self.currentIndexPath.row + 1, self.model.continousArray.count];
    } else if (indexPath.section == 1) {
        self.curentLabel.text = [NSString stringWithFormat:@"第%ld/%ld条", self.currentIndexPath.row + 1, self.model.movieArray.count];

    } else if (indexPath.section == 2) {
        self.curentLabel.text = [NSString stringWithFormat:@"第%ld/%ld张", self.currentIndexPath.row + 1, self.model.panoramArray.count];

    } else {
        self.curentLabel.text = [NSString stringWithFormat:@"第%ld/%ld张", self.currentIndexPath.row + 1, self.model.aiPanoramArray.count];

    }
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 4;
}
//返回每个分区的item个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        return self.model.continousArray.count;
    } else if (section == 1) {
        return self.model.movieArray.count;
    } else if (section == 2) {
        return self.model.panoramArray.count;
    } else {
        return self.model.aiPanoramArray.count;
    }
}
//返回每个item
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PCSPreCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PCSPreCollectionCell" forIndexPath:indexPath];
    cell.isPlayer = NO;
    if (indexPath.section == 0) {
        if (self.model.continousArray.count > indexPath.row) {
            LenzResourceItemModel *model = self.model.continousArray[indexPath.row];
            cell.model = model;
        }
    } else if (indexPath.section == 1) {
        if (self.model.movieArray.count > indexPath.row) {
            LenzResourceItemModel *model = self.model.movieArray[indexPath.row];
            cell.model = model;
            cell.isPlayer = indexPath == self.playerIndexPath;
        }
    } else if (indexPath.section == 2) {
        if (self.model.panoramArray.count > indexPath.row) {
            LenzResourceItemModel *model = self.model.panoramArray[indexPath.row];
            cell.model = model;
        }
    } else if (indexPath.section == 3) {
        if (self.model.aiPanoramArray.count > indexPath.row) {
            LenzResourceItemModel *model = self.model.aiPanoramArray[indexPath.row];
            cell.model = model;
        }
    }

    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        self.playerIndexPath = indexPath;
        [self.collectionView reloadData];
    }
}

// 监听UIScrollView的滑动停止
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.playerIndexPath = nil;
     NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
     NSIndexPath *currentIndexPath = indexPaths.firstObject;
     self.currentIndexPath = currentIndexPath;
    [self changeLabelStatusWith:currentIndexPath.section + 1];
    [self updateCountLabelWith:currentIndexPath];
}

- (void)updateCurrentIndexPath {
    NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
    NSIndexPath *currentIndexPath = indexPaths.firstObject;
    self.currentIndexPath = currentIndexPath;
   [self changeLabelStatusWith:currentIndexPath.section + 1];
   [self updateCountLabelWith:currentIndexPath];
}

- (void)updateViewWhenDelete {
    self.playerIndexPath = nil;
    NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
    NSIndexPath *currentIndexPath = indexPaths.firstObject;
    self.currentIndexPath = currentIndexPath;
   [self changeLabelStatusWith:currentIndexPath.section + 1];
   [self updateCountLabelWith:currentIndexPath];
}

- (void)setupModeView {
    [self.modeView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat margin = [UIScreen mainScreen].bounds.size.width == 375 ? 20 : 30;
    UIView *lastView = nil;
    NSInteger count = 0;
    self.currentIndex = 0;
    if (self.model.continousArray.count) {
        count += self.model.continousArray.count;
        self.currentIndex = 1;
        UILabel *label = [[UILabel alloc]init];
        label.text = @"连拍";
        label.tag = 1;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeAction:)];
        [label addGestureRecognizer:tap];
        label.userInteractionEnabled = YES;
        label.textColor = [UIColor whiteColor];
        [self.modeView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(20);
            make.centerY.mas_equalTo(self.countLabel);
        }];
        lastView = label;
    }
    
    if (self.model.movieArray.count) {
        count += self.model.movieArray.count;
        if (self.currentIndex == 0) {
            self.currentIndex = 2;
        }
        UILabel *label = [[UILabel alloc]init];
        label.text = @"视频";
        label.tag = 2;
        label.textColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeAction:)];
        [label addGestureRecognizer:tap];
        label.userInteractionEnabled = YES;
        [self.modeView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastView) {
                make.left.mas_equalTo(lastView.mas_right).mas_offset(margin);
            } else {
                make.left.mas_equalTo(20);
            }
            make.centerY.mas_equalTo(self.countLabel);
        }];
        lastView = label;
    }
    if (self.model.panoramArray.count) {
        count += self.model.panoramArray.count;
        if (self.currentIndex == 0) {
            self.currentIndex = 3;
        }
        UILabel *label = [[UILabel alloc]init];
        label.text = @"全景";
        label.tag = 3;
        label.textColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeAction:)];
        [label addGestureRecognizer:tap];
        label.userInteractionEnabled = YES;
        [self.modeView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastView) {
                make.left.mas_equalTo(lastView.mas_right).mas_offset(margin);
            } else {
                make.left.mas_equalTo(20);
            }
            make.centerY.mas_equalTo(self.countLabel);
        }];
        lastView = label;
    }
    if (self.model.aiPanoramArray.count) {
        count += self.model.aiPanoramArray.count;
        if (self.currentIndex == 0) {
            self.currentIndex = 4;
        }
        UILabel *label = [[UILabel alloc]init];
        label.text = @"智能全景";
        label.tag = 4;
        label.textColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeAction:)];
        [label addGestureRecognizer:tap];
        label.userInteractionEnabled = YES;
        [self.modeView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastView) {
                make.left.mas_equalTo(lastView.mas_right).mas_offset(margin);
            } else {
                make.left.mas_equalTo(20);
            }
            make.centerY.mas_equalTo(self.countLabel);
        }];
        lastView = label;
    }
    self.countLabel.text = [NSString stringWithFormat:@"共%ld笔数据", count];
    
    [self.modeView addSubview:self.lineImageView];
}

- (void)updateTotal {
    NSInteger count = 0;
    if (self.model.continousArray.count) {
        count += self.model.continousArray.count;
    }
    
    if (self.model.movieArray.count) {
        count += self.model.movieArray.count;
    }
    if (self.model.panoramArray.count) {
        count += self.model.panoramArray.count;
    }
    if (self.model.aiPanoramArray.count) {
        count += self.model.aiPanoramArray.count;
    }
    self.countLabel.text = [NSString stringWithFormat:@"共%ld笔数据", count];
    
}


- (void)changeAction:(UITapGestureRecognizer *)tap {

    [self.view layoutIfNeeded];
    UILabel *label = (UILabel *)tap.view;
    self.currentIndexPath = [NSIndexPath indexPathForItem:0 inSection:label.tag - 1];
    UICollectionViewLayoutAttributes*attributes = [self.collectionView layoutAttributesForItemAtIndexPath:self.currentIndexPath];
    CGRect rect = attributes.frame;
    [self.collectionView setContentOffset:CGPointMake(rect.origin.x, rect.origin.y ) animated:NO];
    
    [self changeLabelStatusWith:label.tag];
    [self updateCountLabelWith:self.currentIndexPath];
}

- (void)changeLabelStatusWith:(NSInteger)index {
    if(index <=0) {
        return;
    }
    UILabel *label1 = [self.modeView viewWithTag:1];
    if (label1) {
        label1.textColor = [UIColor whiteColor];
    }
    UILabel *label2 = [self.modeView viewWithTag:2];
    if (label2) {
        label2.textColor = [UIColor whiteColor];
    }
    UILabel *label3 = [self.modeView viewWithTag:3];
    if (label3) {
        label3.textColor = [UIColor whiteColor];
    }
    
    UILabel *label4 = [self.modeView viewWithTag:4];
    if (label4) {
        label4.textColor = [UIColor whiteColor];
    }
    
    UILabel *label = (UILabel *)[self.modeView viewWithTag:index];
    if (label) {
        label.textColor = [UIColor colorWithRed:231/255.0 green:108/255.0 blue:30/255.0 alpha:1];
        [self.lineImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(label.mas_bottom);
            make.centerX.mas_equalTo(label);
            make.width.mas_offset(18);
            make.height.mas_offset(9);
        }];
    }
    self.currentIndex = index;
}


- (void)updateScrollWith:(NSInteger)tag {
    if (tag > 0) {
        NSArray <LenzResourceItemModel *> *source = nil;
        if (tag == 1) {
            source = self.model.continousArray;
        } else if (tag == 2) {
            source = self.model.movieArray;
        } else if (tag == 3) {
            source = self.model.panoramArray;
        } else if (tag == 4) {
            source = self.model.aiPanoramArray;
        }
        [self updateScrollViewWith:source];
    }
}

- (void)updateScrollViewWith:(NSArray <LenzResourceItemModel *> *)array {
    CGFloat width = CGRectGetWidth(self.scrollView.frame);
    CGFloat height = CGRectGetHeight(self.scrollView.frame);
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(width * array.count, height);
    __block UIImageView *lastImageView = nil;
    [array enumerateObjectsUsingBlock:^(LenzResourceItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.image = obj.image;
        imageView.tag = idx;
        [self.scrollView addSubview:imageView];

        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(0);
            make.height.mas_offset(height);
            make.width.mas_offset(width);
            if (lastImageView) {
                make.left.mas_equalTo(lastImageView.mas_right);
            } else {
                make.left.mas_offset(0);
            }
        }];
        UIImageView *videoImageView = [[UIImageView alloc]init];
        videoImageView.image =  [UIImage loadNamed:@"icon_video"];
        [imageView addSubview:videoImageView];
        [videoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(imageView);
            make.width.height.mas_offset(48);
        }];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        if (obj.mode == SDK_CAPTURE_MODE_MOVIE) {
            videoImageView.hidden = NO;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(videoAction:)];
            [imageView addGestureRecognizer:tap];
            imageView.userInteractionEnabled = YES;
            
            AVPlayerViewController *player = [[AVPlayerViewController alloc]init];

            player.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
            player.view.hidden = YES;
            [imageView addSubview:player.view];
            [self.allPlayer addObject:player];
            
            
        } else {
            videoImageView.hidden = YES;
        }
        lastImageView = imageView;
    }];
    self.curentLabel.text = [NSString stringWithFormat:@"第%d/%ld条", 1, array.count];
}
- (void)videoAction:(UITapGestureRecognizer *)tap {
    UIImageView *view = (UIImageView *)tap.view;
    if (self.model.movieArray.count > view.tag) {
        LenzResourceItemModel *model = self.model.movieArray[view.tag];
        AVPlayer *player = [AVPlayer playerWithURL:[NSURL URLWithString:model.path]];
        
        if (self.lastPlayer) {
            [self.lastPlayer.player pause];
            self.lastPlayer.player = nil;
            self.lastPlayer.view.hidden = YES;
        }
        
        AVPlayerViewController *playerVC = self.allPlayer[view.tag];
        playerVC.view.hidden = NO;
        playerVC.player = player;
        [playerVC.player play];
        
        self.lastPlayer = playerVC;

    }
}

- (BOOL)shouldAutorotate {
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)backAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)deleteAction {
    NSString *title = @"图片删除后无法恢复，请确认！";
    if (self.currentIndex == 2) {
        title = @"视频删除后无法恢复，请确认！";
    }
    [QuitMultipleModeAlertViewController show:self title:@"确认提醒" text:title leftBtnTitle:@"取消" rightBtnTitle:@"确定" withLeftButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
            
        [alertController dismissViewControllerAnimated:YES completion:nil];
        } rightButtonCallBack:^(QuitMultipleModeAlertViewController * _Nonnull alertController) {
            NSIndexPath *showIndexPath = nil;
            if (self.currentIndex == 1) {
                if (self.model.continousArray.count > self.currentIndexPath.item) {
                    [self.model.continousArray removeObjectAtIndex:self.currentIndexPath.item];
                }
                if (self.model.continousArray.count > 0 ) {
                    showIndexPath = [NSIndexPath indexPathForRow:self.currentIndexPath.item - 1 inSection:self.currentIndexPath.section];
                }
            } else if (self.currentIndex == 2) {
                if (self.model.movieArray.count > self.currentIndexPath.item) {
                    [self.model.movieArray removeObjectAtIndex:self.currentIndexPath.item];
                }
                if (self.model.movieArray.count > 0 ) {
                    showIndexPath = [NSIndexPath indexPathForRow:self.currentIndexPath.item - 1 inSection:self.currentIndexPath.section];
                }
            } else if (self.currentIndex == 3) {
                if (self.model.panoramArray.count > self.currentIndexPath.item) {
                    [self.model.panoramArray removeObjectAtIndex:self.currentIndexPath.item];
                }
                if (self.model.panoramArray.count > 0 ) {
                    showIndexPath = [NSIndexPath indexPathForRow:self.currentIndexPath.item - 1 inSection:self.currentIndexPath.section];
                }
            } else if (self.currentIndex == 4) {
                if (self.model.aiPanoramArray.count > self.currentIndexPath.item) {
                    [self.model.aiPanoramArray removeObjectAtIndex:self.currentIndexPath.item];
                }
                if (self.model.aiPanoramArray.count > 0 ) {
                    showIndexPath = [NSIndexPath indexPathForRow:self.currentIndexPath.item - 1 inSection:self.currentIndexPath.section];
                }
            }


            if(showIndexPath) {
                UICollectionViewLayoutAttributes*attributes = [self.collectionView layoutAttributesForItemAtIndexPath:showIndexPath];
                CGRect rect = attributes.frame;
                [self.collectionView reloadData];
                [self.collectionView setContentOffset:CGPointMake(rect.origin.x, rect.origin.y ) animated:NO];
            } else {
                [self setupModeView];
                [self scrollViewDidEndDecelerating:self.collectionView];
                [self.collectionView reloadData];
            }
            
            
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self updateCurrentIndexPath];
            });
            
            [self updateTotal];
            [self updateViewWhenDelete];
            if (self.dataChangeBlock) {
                self.dataChangeBlock();
            }
            if (self.model.continousArray.count == 0 &&
                self.model.movieArray.count == 0 &&
                self.model.panoramArray.count == 0 &&
                self.model.aiPanoramArray.count == 0) {
                
                self.curentLabel.hidden = YES;
                [alertController dismissViewControllerAnimated:YES completion:^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
            } else {
                self.curentLabel.hidden = NO;
                [alertController dismissViewControllerAnimated:YES completion:nil];
            }


        }];
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc]init];
        _countLabel.font = [UIFont systemFontOfSize:14];
        _countLabel.textColor = [UIColor colorWithRed:231/255.0 green:108/255.0 blue:30/255.0 alpha:1];
    }
    return _countLabel;
}
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
    }
    return _bottomView;
}
- (UIView *)modeView {
    if (!_modeView) {
        _modeView = [[UIView alloc]init];
        _modeView.userInteractionEnabled = YES;
    }
    return _modeView;
}
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.layer.cornerRadius = 8;
        _scrollView.layer.masksToBounds = YES;
        _scrollView.delegate = self;
//        _scrollView.backgroundColor = [UIColor blackColor];
    }
    return _scrollView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [[UIButton alloc]init];
        [_backButton setImage:[UIImage loadNamed:@"result-return-btn"] forState:UIControlStateNormal];

        [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}
- (UILabel *)backLabel {
    if (!_backLabel) {
        _backLabel = [[UILabel alloc]init];
        _backLabel.text = @"返回";
        _backLabel.textColor = [UIColor whiteColor];
    }
    return _backLabel;
}
- (UILabel *)deleteLabel {
    if (!_deleteLabel) {
        _deleteLabel = [[UILabel alloc]init];
        _deleteLabel.text = @"删除";
        _deleteLabel.textColor = [UIColor whiteColor];
    }
    return _deleteLabel;
}
- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc]init];
        [_deleteButton setImage:[UIImage loadNamed:@"result-delete-btn"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

- (UILabel *)curentLabel {
    if (!_curentLabel) {
        _curentLabel = [[UILabel alloc]init];
        _curentLabel.backgroundColor = [UIColor colorWithRed:231/255.0 green:108/255.0 blue:30/255.0 alpha:1];
        _curentLabel.layer.cornerRadius = 16;
        _curentLabel.layer.masksToBounds = YES;
        _curentLabel.textAlignment = NSTextAlignmentCenter;
        _curentLabel.textColor = [UIColor whiteColor];
    }
    return _curentLabel;
}
- (UIImageView *)videoImageView {
    if (!_videoImageView) {
        _videoImageView = [[UIImageView alloc]init];
        _videoImageView.image = [UIImage loadNamed:@"icon_video"];
    }
    return _videoImageView;
}

@end
