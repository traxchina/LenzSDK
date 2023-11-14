//
//  MoviePlayerViewController.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/24.
//

#import "MoviePlayerViewController.h"

@interface MoviePlayerViewController ()

@property (nonatomic, strong) AVPlayerLayer* videoLayer;

@property (nonatomic, strong) AVPlayerItem* videoItem;

@property (nonatomic, assign) BOOL broken;

@end

@implementation MoviePlayerViewController

- (void)replaceWith:(NSURL *)fileURL{
    self.movieFileURL = fileURL;
    self.videoItem = [AVPlayerItem playerItemWithURL:self.movieFileURL];
    [self.player replaceCurrentItemWithPlayerItem:self.videoItem];
}

- (void)prepareVideoPlayer{
    
    self.videoItem = [AVPlayerItem playerItemWithURL:self.movieFileURL];
    self.player = [AVPlayer playerWithPlayerItem:self.videoItem];
    self.videoLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.videoView.layer addSublayer:self.videoLayer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.broken = NO;
    
    [self prepareVideoPlayer];
    
    NSError* err = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&err];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)willEnterForeground: (NSNotification*)noti{
    if(self.broken){
        [self.player play];
        self.broken = NO;
    }
}

- (void)willEnterBackground: (NSNotification*)noti{
    
    if(self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying){
        [self.player pause];
        self.broken = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
        
    if(self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying){
        [self.player pause];
        self.broken = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if(self.broken){
        self.broken = NO;
        [self.player play];
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    self.videoLayer.frame = self.videoView.layer.bounds;
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
