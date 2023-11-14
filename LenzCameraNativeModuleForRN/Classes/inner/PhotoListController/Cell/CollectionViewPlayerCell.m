//
//  CollectionViewPlayerCell.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/24.
//

#import "CollectionViewPlayerCell.h"
#import "MoviePlayerViewController.h"
#import <Masonry/Masonry.h>
#import "MovieListCellModel.h"
#import "OperationNodeMovie.h"

@interface CollectionViewPlayerCell()

@property (nonatomic, readonly, nullable) NSURL* fileURL;

@end

@implementation CollectionViewPlayerCell

- (UIView *)coverView{
    return self.playerController.view;
}

- (NSURL *)fileURL{
    return ((MovieListCellModel*)self.cellModel).movieModel.fileUrl;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    
    return CGRectContainsPoint(self.imageView.frame, point);
}

- (AVPlayer*)play{
    if(self.fileURL == nil){
        return nil;
    }
    if(self.playerController.player.timeControlStatus == AVPlayerTimeControlStatusPlaying){
        return self.playerController.player;
    }
    AVPlayer* player = self.playerController.player;
    
    if(player.currentItem != nil &&
       player.currentItem.status == AVPlayerItemStatusReadyToPlay &&
       player.currentItem.currentTime.value / player.currentItem.currentTime.timescale >= player.currentItem.duration.value / player.currentItem.duration.timescale){
        
        [self.playerController replaceWith:self.fileURL];
    }
    
    [self.playerController.player play];
    self.playIconView.hidden = YES;
    return self.playerController.player;
}

- (void)stop{
    self.playIconView.hidden = NO;
    [self.playerController.player pause];
}

- (void)setCellModel:(PhotoListCellModel *)cellModel{
    [super setCellModel:cellModel];
    if([cellModel isKindOfClass:[MovieListCellModel class]]){
        self.playerController.movieFileURL = ((MovieListCellModel*)self.cellModel).movieModel.fileUrl;
        [self.playerController replaceWith:self.playerController.movieFileURL];
    }
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.imageView.hidden = YES;
    
    UIStoryboard* sb = [UIStoryboard storyboardWithName:[PCSTools shared].mainStoryboardName bundle:[PCSTools sdkBundle]];
    MoviePlayerViewController* playerController = [sb instantiateViewControllerWithIdentifier:@"play-movie-on-cell"];
    [playerController loadViewIfNeeded];
    _playerController = playerController;
    playerController.movieFileURL = ((MovieListCellModel*)self.cellModel).movieModel.fileUrl;
    [self.contentView insertSubview:self.playerController.view belowSubview:self.imageView];
    [self.playerController viewDidLoad];
    self.playerController.view.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)updateConstraints{
    [super updateConstraints];
    
    [self.playerController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(CGRectGetWidth(self.contentView.frame)));
        make.height.equalTo(@(CGRectGetHeight(self.contentView.frame)));
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    
    CGFloat x = CGRectGetWidth([UIScreen mainScreen].bounds) * 0.5;
    CGFloat y = CGRectGetHeight([UIScreen mainScreen].bounds) * 0.5 - 40;
    self.playIconView.center = CGPointMake(x, y);
    [self.contentView bringSubviewToFront:self.playIconView];
}

- (void)dealloc{
    
}

@end
