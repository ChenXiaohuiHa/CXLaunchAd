//
//  CXLauchMovieViewController.m
//  CXLaunchAd
//
//  Created by 陈晓辉 on 2018/10/9.
//  Copyright © 2018年 陈晓辉. All rights reserved.
//

#import "CXLauchMovieViewController.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

#define kIsFirstLauchApp @"kIsFirstLauchApp"

@interface CXLauchMovieViewController ()

/** 播放开始之前的图片 */
@property (nonatomic, strong) UIImageView *startPlayerImageView;
/** 播放中断时的图片 */
@property (nonatomic, strong) UIImageView *pausePlayerImageView;
/** 定时器 */
@property (nonatomic, strong) NSTimer *timer;
/** 结束按钮 */
@property (nonatomic , strong)UIButton *enterMainButton;

@end

@implementation CXLauchMovieViewController


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.timer invalidate];
    self.timer = nil;
    self.player = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置界面
    [self setupView];
    //添加监听
    [self addNotification];
    //初始化视频
    [self prepareMovie];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //隐藏状态栏
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

#pragma mark -- 初始化视图逻辑
- (void)setupView {
    
    //视频开始前的占位图
    self.startPlayerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lauch"]];
    _startPlayerImageView.frame = self.view.bounds;
    [self.contentOverlayView addSubview:_startPlayerImageView];
    
    //是否是第一次打开APP
    if (![self isFirstLaunchApp]) {
        
        //设置进入主界面的按钮
        [self setupEnterMainButton];
    }
}
#pragma mark - 创建'进入主页按钮'
- (void)setupEnterMainButton {
    
    self.enterMainButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _enterMainButton.frame = CGRectMake(24, kScreenHeight - 32 - 48, kScreenWidth - 48, 48);
    _enterMainButton.layer.borderWidth =1;
    _enterMainButton.layer.cornerRadius = 24;
    _enterMainButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [_enterMainButton setTitle:@"进入应用" forState:UIControlStateNormal];
    _enterMainButton.hidden = YES;
    [_enterMainButton addTarget:self action:@selector(enterMainAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentOverlayView addSubview:_enterMainButton];
    
    //设置定时器当视频播放到第三秒时 展示进入应用
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showEnterMainButton) userInfo:nil repeats:YES];
}
- (void)enterMainAction:(UIButton *)sender {
    
    //视频暂停
    [self.player pause];
    
    //视频中断, 展示中断时的界面图片
    self.pausePlayerImageView = [[UIImageView alloc] init];
    _pausePlayerImageView.frame = self.view.bounds;
    _pausePlayerImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentOverlayView addSubview:_pausePlayerImageView];
    
    //获取当前暂停时界面的截图
    [self getOverPlayerImage];
}
//获取当前暂停时界面的截图
- (void)getOverPlayerImage {
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:self.player.currentItem.asset];
    gen.appliesPreferredTrackTransform = YES;
    NSError *error = nil;
    CMTime actualTime;
    CMTime now = self.player.currentTime;
    gen.requestedTimeToleranceBefore = kCMTimeZero;
    gen.requestedTimeToleranceAfter = kCMTimeZero;
    CGImageRef image = [gen copyCGImageAtTime:now actualTime:&actualTime error:&error];
    if (!error) {
        
        UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
        self.pausePlayerImageView.image = thumb;
    }
    NSLog(@"%f , %f",CMTimeGetSeconds(now),CMTimeGetSeconds(actualTime));
    NSLog(@"error: %@",error);
    
    //视频播放结束
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self moviePlaybackComplete];
    });
}
//NSTimer Action 显示进入按钮
- (void)showEnterMainButton {
    
    //播放 N秒后显示 '进入按钮'
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:self.player.currentItem.asset];
    gen.appliesPreferredTrackTransform = YES;
    NSError *error = nil;
    CMTime actualTime;
    CMTime now = self.player.currentTime;
    gen.requestedTimeToleranceBefore = kCMTimeZero;
    gen.requestedTimeToleranceAfter = kCMTimeZero;
    [gen copyCGImageAtTime:now actualTime:&actualTime error:&error];
    NSInteger currentPlayBackTime = CMTimeGetSeconds(actualTime);
    if (currentPlayBackTime >= 3) {
        
        self.enterMainButton.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{
            
            self.enterMainButton.alpha = 1;
        }];
    }
    if (currentPlayBackTime > 5) {
        
        //防止没有显示出来
        self.enterMainButton.alpha = 1;
        self.enterMainButton.hidden = NO;
        [self.timer invalidate];
        self.timer = nil;
    }
}
#pragma mark -- 初始化视频
- (void)prepareMovie {
    
    //判断是否是第一次运行APP, 来播放不同的视频
    NSString *filePath = nil;
    if (![self isFirstLaunchApp]) {
        
        filePath = [[NSBundle mainBundle] pathForResource:@"opening_long_1080*1920.mp4" ofType:nil];
        [self setIsFirstLauchApp:YES];//第一次打开, 存储打开记录
    }else{
        
        filePath = [[NSBundle mainBundle] pathForResource:@"opening_short_1080*1920.mp4" ofType:nil];
    }
    //初始化 player
    self.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:filePath]];
    self.showsPlaybackControls = NO;//播放控制,控制播放进度,开始,暂停等 是否显示, 默认 YES
    //播放视频
    [self.player play];
}

#pragma mark -- 监听以及实现方法
- (void)addNotification {
    
    //移除 APP 进入后台的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    //添加 APP 进入前台的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillEnterForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackComplete) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];//视频播放结束
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackStart) name:AVPlayerItemTimeJumpedNotification object:nil];//播放开始
}
//APP 进入前台
- (void)viewWillEnterForeground {
    
    if (!self.player) {
        
        [self prepareMovie];
    }
    //播放视频
    [self.player play];
}
//视频播放完成
- (void)moviePlaybackComplete {
    
    if ([self isFirstLaunchApp]) { //第二次进入app视频需要直接结束
        
        //发送推送之后就删除, 否则界面显示有问题
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
        [self.startPlayerImageView removeFromSuperview];
        self.startPlayerImageView = nil;
        
        [self.pausePlayerImageView removeFromSuperview];
        self.pausePlayerImageView = nil;
        
        if (self.timer) {
            
            [self.timer invalidate];
            self.timer = nil;
        }
        //进入主界面
        [self enterMain];
    }else{ //第一次进入APP, 循环播放视频
        
        self.startPlayerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lauchAgain"]];
        _startPlayerImageView.frame = self.view.bounds;
        [self.contentOverlayView addSubview:_startPlayerImageView];
        [self.pausePlayerImageView removeFromSuperview];
        self.pausePlayerImageView = nil;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"opening_long_1080*1920.mp4" ofType:nil];
        //初始化 player
        self.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:filePath]];
        self.showsPlaybackControls = NO;
        //播放视频
        [self.player play];
    }
}

//开始播放
- (void)moviePlaybackStart {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.startPlayerImageView removeFromSuperview];
        self.startPlayerImageView = nil;
    });
}

//是否是第一次打开APP
- (BOOL)isFirstLaunchApp {
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kIsFirstLauchApp];
}
//第一次打开, 存储打开记录
- (void)setIsFirstLauchApp:(BOOL)isFirstLauchApp {
    
    [[NSUserDefaults standardUserDefaults] setBool:isFirstLauchApp forKey:kIsFirstLauchApp];
}
//进入主界面
- (void)enterMain {
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *main = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    delegate.window.rootViewController = main;
    [delegate.window makeKeyWindow];
}



@end
