//
//  CXLaunchAdManager.m
//  CXLaunchAd
//
//  Created by 陈晓辉 on 2018/10/9.
//  Copyright © 2018年 陈晓辉. All rights reserved.
//

#import "CXLaunchAdManager.h"
#import <UIKit/UIKit.h>
#import "XHLaunchAd.h"//第三方
#import "CXLaunchAdModel.h"//数据模型类
#import "CXNetwork.h"//网络请求
#import "CXWebViewController.h"//广告详情

/** 以下连接供测试使用 */

/** 静态图 */
#define imageURL1 @"http://i4.bvimg.com/664573/a6521d8e4193f259.jpg"
/** 动态图 */
#define imageURL2 @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1539086516041&di=115f93a785ef819ba021fdfa031e598f&imgtype=0&src=http%3A%2F%2Fimg4.duitang.com%2Fuploads%2Fitem%2F201510%2F11%2F20151011054834_VMAj2.gif"
/** 视频链接 */
#define videoURL1 @"http://yun.it7090.com/video/XHLaunchAd/video_test01.mp4"

#define detailUrl @"https://github.com/ChenXiaohuiHa" //@"https:m.baidu.com"

@interface CXLaunchAdManager ()<XHLaunchAdDelegate>

@end

@implementation CXLaunchAdManager

+ (void)load {
    
    [self shareManager];
}

+ (CXLaunchAdManager *)shareManager {
    static CXLaunchAdManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CXLaunchAdManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        //在 UIApplicationDidFinishLaunching 时 初始化开屏广告, 做到对业务层无干扰, 也可在 AppDelegate didFinishLaunchingWithOptions 方法中初始化
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {

            //初始化开屏广告
            [self setUpLanuchAd];
        }];
    }
    return self;
}

- (void)setUpLanuchAd {
    
    /** 1.图片 - 默认配置快速初始化 */
    //[self example01];
    
    /** 2.图片 - 网络数据 */
    [self example02];
    
    /** 3.图片 - 本地数据 */
    //[self example03];
    
    /** 4.视频 - 默认配置快速初始化 */
    //[self example04];
    
    /** 5.视频 - 网络数据 */
    //[self example05];
    
    /** 6.视频 - 本地数据 */
    //[self example06];
    
    /** 7.自定义跳过按钮 */
    //[self example07];
    
    /** 8.如果你想提前批量缓存图片/视频请看下面两个示例 */
    //[self batchDownloadImageAndCache]; //批量下载并缓存图片
    //[self batchDownloadVideoAndCache]; //批量下载并缓存视频
}
#pragma mark ---------- 1.图片 - 默认配置快速初始化 ----------
- (void)example01 {
    
    //设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
    [XHLaunchAd setLaunchSourceType:SourceTypeLaunchImage];
    
    //使用默认配置
    XHLaunchImageAdConfiguration *imageAdconfiguration = [XHLaunchImageAdConfiguration defaultConfiguration];
    //广告图片URLString/或本地图片名(.jpg/.gif请带上后缀)
    imageAdconfiguration.imageNameOrURLString = imageURL2;
    //广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
    imageAdconfiguration.openModel = detailUrl;
    [XHLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:self];
}

#pragma mark ---------- 2.图片 - 网络数据 ----------
- (void)example02 {
    
    //1. 设置工程的启动页使用的是: LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
    [XHLaunchAd setLaunchSourceType:(SourceTypeLaunchImage)];
    
    //2.1.因为数据请求是异步的,请在数据请求前,调用下面方法配置数据等待时间.
    //2.2.设为3即表示:启动页将停留3s等待服务器返回广告数据,3s内等到广告数据,将正常显示广告,否则将不显示
    //2.3.数据获取成功,配置广告数据后,自动结束等待,显示广告
    //注意:请求广告数据前,必须设置此属性,否则会先进入window的的根控制器
    [XHLaunchAd setWaitDataDuration:3.0];
    
    //3. 进行数据请求
    [CXNetwork getLaunchAdImageDataSuccess:^(NSDictionary * _Nonnull response) {
        
        NSLog(@"广告数据 = %@",response);
        //广告数据转模型
        CXLaunchAdModel *model = [[CXLaunchAdModel alloc] initWithDict:response[@"data"]];
        //配置广告数据
        XHLaunchImageAdConfiguration *imageAdconfiguration = [XHLaunchImageAdConfiguration new];
        //广告停留时间
        imageAdconfiguration.duration = model.duration;
        //广告frame
        imageAdconfiguration.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 0.8);
        //广告图片URLString/或本地图片名(.jpg/.gif请带上后缀)
        imageAdconfiguration.imageNameOrURLString = model.content;
        //设置GIF动图是否只循环播放一次(仅对动图设置有效)
        imageAdconfiguration.GIFImageCycleOnce = NO;
        //缓存机制(仅对网络图片有效)
        //为告展示效果更好,可设置为XHLaunchAdImageCacheInBackground,先缓存,下次显示
        imageAdconfiguration.imageOption = XHLaunchAdImageDefault;
        //图片填充模式
        imageAdconfiguration.contentMode = UIViewContentModeScaleAspectFill;
        //广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
        imageAdconfiguration.openModel = model.openUrl;
        //广告显示完成动画
        imageAdconfiguration.showFinishAnimate = ShowFinishAnimateFadein;
        //广告显示完成动画时间
        imageAdconfiguration.showFinishAnimateTime = 0.8;
        //跳过按钮类型
        imageAdconfiguration.skipButtonType = SkipTypeTimeText;
        //后台返回时,是否显示广告
        imageAdconfiguration.showEnterForeground = YES;
        
        //图片已缓存 - 显示一个 "已预载" 视图 (可选)
        if([XHLaunchAd checkImageInCacheWithURL:[NSURL URLWithString:model.content]]){
            
            //设置要添加的自定义视图(可选)
            imageAdconfiguration.subViews = [self launchAdSubViews_alreadyView];
        }
        //显示开屏广告
        [XHLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:self];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark ---------- 3.图片 - 本地数据 ----------
- (void)example03 {
    //1. 设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
    //[XHLaunchAd setLaunchSourceType:(SourceTypeLaunchImage)];
    
    //2.配置广告数据
    XHLaunchImageAdConfiguration *imageAdConfiguration = [XHLaunchImageAdConfiguration new];
    
    //2.1 广告停留时间
    imageAdConfiguration.duration = 5;
    //2.2 广告 frame
    imageAdConfiguration.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height *0.8);
    //2.3 广告图片URLString/或本地图片名(.jpg/.gif请带上后缀)
    imageAdConfiguration.imageNameOrURLString = @"image12.gif";
    //2.4 设置GIF动图是否只循环播放一次(仅对动图设置有效)
    imageAdConfiguration.GIFImageCycleOnce = NO;
    //2.5 图片填充模式
    imageAdConfiguration.contentMode = UIViewContentModeScaleAspectFill;
    //2.6 广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
    imageAdConfiguration.openModel = detailUrl;
    
    //2.7 广告显示完成动画
    imageAdConfiguration.showFinishAnimate =ShowFinishAnimateFlipFromLeft;
    //2.8 广告显示完成动画时间
    imageAdConfiguration.showFinishAnimateTime = 0.8;
    //2.9 跳过按钮类型
    imageAdConfiguration.skipButtonType = SkipTypeRoundProgressText;
    //2.10 后台返回时,是否显示广告
    imageAdConfiguration.showEnterForeground = YES;
    //2.11 设置要添加的子视图(可选)
    //imageAdconfiguration.subViews = [self launchAdSubViews];
    //2.12 显示开屏广告
    [XHLaunchAd imageAdWithImageAdConfiguration:imageAdConfiguration delegate:self];
}

#pragma mark ---------- 4.视频 - 默认配置快速初始化 ----------
- (void)example04 {
    
    //设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
    [XHLaunchAd setLaunchSourceType:SourceTypeLaunchImage];
    
    //使用默认配置
    XHLaunchVideoAdConfiguration *videoAdconfiguration = [XHLaunchVideoAdConfiguration defaultConfiguration];
    //广告视频URLString/或本地视频名(请带上后缀)
    videoAdconfiguration.videoNameOrURLString = @"video0.mp4";
    //广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
    videoAdconfiguration.openModel = detailUrl;
    [XHLaunchAd videoAdWithVideoAdConfiguration:videoAdconfiguration delegate:self];
}

#pragma mark ---------- 5.视频 - 网络数据 ----------
- (void)example05 {
    
    //设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
    [XHLaunchAd setLaunchSourceType:SourceTypeLaunchImage];
    
    //1.因为数据请求是异步的,请在数据请求前,调用下面方法配置数据等待时间.
    //2.设为3即表示:启动页将停留3s等待服务器返回广告数据,3s内等到广告数据,将正常显示广告,否则将不显示
    //3.数据获取成功,配置广告数据后,自动结束等待,显示广告
    //注意:请求广告数据前,必须设置此属性,否则会先进入window的的根控制器
    [XHLaunchAd setWaitDataDuration:3];
    
    //广告数据请求
    [CXNetwork getLaunchAdVideoDataSuccess:^(NSDictionary * response) {
        
        NSLog(@"广告数据 = %@",response);
        
        //广告数据转模型
        CXLaunchAdModel *model = [[CXLaunchAdModel alloc] initWithDict:response[@"data"]];
        
        //配置广告数据
        XHLaunchVideoAdConfiguration *videoAdconfiguration = [XHLaunchVideoAdConfiguration new];
        //广告停留时间
        videoAdconfiguration.duration = model.duration;
        //广告frame
        videoAdconfiguration.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        //广告视频URLString/或本地视频名(请带上后缀)
        //注意:视频广告只支持先缓存,下次显示(看效果请二次运行)
        videoAdconfiguration.videoNameOrURLString = model.content;
        //是否关闭音频
        videoAdconfiguration.muted = NO;
        //视频缩放模式
        videoAdconfiguration.videoGravity = AVLayerVideoGravityResizeAspectFill;
        //是否只循环播放一次
        videoAdconfiguration.videoCycleOnce = NO;
        //广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
        videoAdconfiguration.openModel = model.openUrl;
        //广告显示完成动画
        videoAdconfiguration.showFinishAnimate =ShowFinishAnimateFadein;
        //广告显示完成动画时间
        videoAdconfiguration.showFinishAnimateTime = 0.8;
        //后台返回时,是否显示广告
        videoAdconfiguration.showEnterForeground = NO;
        //跳过按钮类型
        videoAdconfiguration.skipButtonType = SkipTypeTimeText;
        //视频已缓存 - 显示一个 "已预载" 视图 (可选)
        if([XHLaunchAd checkVideoInCacheWithURL:[NSURL URLWithString:model.content]]){
            //设置要添加的自定义视图(可选)
            videoAdconfiguration.subViews = [self launchAdSubViews_alreadyView];
            
        }
        
        [XHLaunchAd videoAdWithVideoAdConfiguration:videoAdconfiguration delegate:self];
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark ---------- 6.视频 - 本地数据 ----------
- (void)example06 {
    
    //设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
    [XHLaunchAd setLaunchSourceType:SourceTypeLaunchImage];
    
    //配置广告数据
    XHLaunchVideoAdConfiguration *videoAdconfiguration = [XHLaunchVideoAdConfiguration new];
    //广告停留时间
    videoAdconfiguration.duration = 5;
    //广告frame
    videoAdconfiguration.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    //广告视频URLString/或本地视频名(请带上后缀)
    videoAdconfiguration.videoNameOrURLString = @"video0.mp4";
    //是否关闭音频
    videoAdconfiguration.muted = NO;
    //视频填充模式
    videoAdconfiguration.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //是否只循环播放一次
    videoAdconfiguration.videoCycleOnce = NO;
    //广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
    videoAdconfiguration.openModel = detailUrl;
    //跳过按钮类型
    videoAdconfiguration.skipButtonType = SkipTypeRoundProgressTime;
    //广告显示完成动画
    videoAdconfiguration.showFinishAnimate = ShowFinishAnimateLite;
    //广告显示完成动画时间
    videoAdconfiguration.showFinishAnimateTime = 0.8;
    //后台返回时,是否显示广告
    videoAdconfiguration.showEnterForeground = NO;
    //设置要添加的子视图(可选)
    //videoAdconfiguration.subViews = [self launchAdSubViews];
    //显示开屏广告
    [XHLaunchAd videoAdWithVideoAdConfiguration:videoAdconfiguration delegate:self];
}

#pragma mark ---------- 7.自定义跳过按钮 ----------
- (void)example07 {
    
    //注意:
    //1.自定义跳过按钮很简单,configuration有一个customSkipView属性.
    //2.自定义一个跳过的view 赋值给configuration.customSkipView属性便可替换默认跳过按钮,如下:
    
    //设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
    [XHLaunchAd setLaunchSourceType:SourceTypeLaunchImage];
    
    //配置广告数据
    XHLaunchImageAdConfiguration *imageAdconfiguration = [XHLaunchImageAdConfiguration new];
    //广告停留时间
    imageAdconfiguration.duration = 5;
    //广告frame
    imageAdconfiguration.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width/1242*1786);
    //广告图片URLString/或本地图片名(.jpg/.gif请带上后缀)
    imageAdconfiguration.imageNameOrURLString = @"image11.gif";
    //缓存机制(仅对网络图片有效)
    imageAdconfiguration.imageOption = XHLaunchAdImageDefault;
    //图片填充模式
    imageAdconfiguration.contentMode = UIViewContentModeScaleToFill;
    //广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
    imageAdconfiguration.openModel = detailUrl;
    //广告显示完成动画
    imageAdconfiguration.showFinishAnimate = ShowFinishAnimateFlipFromLeft;
    //广告显示完成动画时间
    imageAdconfiguration.showFinishAnimateTime = 0.8;
    //后台返回时,是否显示广告
    imageAdconfiguration.showEnterForeground = NO;
    
    //设置要添加的子视图(可选)
    imageAdconfiguration.subViews = [self launchAdSubViews];
    
    //start********************自定义跳过按钮**************************
    imageAdconfiguration.customSkipView = [self customSkipView];
    //********************自定义跳过按钮*****************************end
    
    //显示开屏广告
    [XHLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:self];
}

#pragma mark ---------- 8.批量下载并缓存 ----------
//MARK: 批量下载并缓存图片
- (void)batchDownloadImageAndCache{
    
    [XHLaunchAd downLoadImageAndCacheWithURLArray:@[[NSURL URLWithString:imageURL1]] completed:^(NSArray * _Nonnull completedArray) {
        
        /** 打印批量下载缓存结果 */
        
        //url:图片的url字符串,
        //result:0表示该图片下载失败,1表示该图片下载并缓存完成或本地缓存中已有该图片
        NSLog(@"批量下载缓存图片结果 = %@" ,completedArray);
    }];
}

//MARK: 批量下载并缓存视频
-(void)batchDownloadVideoAndCache{
    
    [XHLaunchAd downLoadVideoAndCacheWithURLArray:@[[NSURL URLWithString:videoURL1]] completed:^(NSArray * _Nonnull completedArray) {
        
        /** 打印批量下载缓存结果 */
        
        //url:视频的url字符串,
        //result:0表示该视频下载失败,1表示该视频下载并缓存完成或本地缓存中已有该视频
        NSLog(@"批量下载缓存视频结果 = %@" ,completedArray);
    }];
}

#pragma mark ---------- subViews ----------
- (NSArray<UIView *> *)launchAdSubViews_alreadyView{
    
    CGFloat y = XH_IPHONEX ? 46:22;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-140, y, 60, 30)];
    label.text  = @"已预载";
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = 5.0;
    label.layer.masksToBounds = YES;
    label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    return [NSArray arrayWithObject:label];
}

- (NSArray<UIView *> *)launchAdSubViews{
    
    CGFloat y = XH_IPHONEX ? 54 : 30;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-170, y, 60, 30)];
    label.text  = @"subViews";
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = 5.0;
    label.layer.masksToBounds = YES;
    label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    return [NSArray arrayWithObject:label];
}

#pragma mark - customSkipView
//自定义跳过按钮
- (UIView *)customSkipView{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor =[UIColor orangeColor];
    button.layer.cornerRadius = 5.0;
    button.layer.borderWidth = 1.5;
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    CGFloat y = XH_IPHONEX ? 54 : 30;
    button.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-100,y, 85, 30);
    [button addTarget:self action:@selector(skipAction) forControlEvents:UIControlEventTouchUpInside];
    return button;
}
//跳过按钮点击事件
-(void)skipAction{
    
    //移除广告
    [XHLaunchAd removeAndAnimated:YES];
    
    NSLog(@"跳过按钮点击事件");
}

#pragma mark ---------- XHLaunchAdDelegate ----------
/**
 MARK: 广告点击
 
 @param launchAd launchAd
 @param openModel 打开页面参数(此参数即你配置广告数据设置的configuration.openModel)
 @param clickPoint 点击位置
 */
- (void)xhLaunchAd:(XHLaunchAd *)launchAd clickAndOpenModel:(id)openModel clickPoint:(CGPoint)clickPoint {
    
    NSLog(@"广告点击事件");
    
    /** openModel即配置广告数据设置的点击广告时打开页面参数(configuration.openModel) */
    if(openModel==nil) return;
    
    CXWebViewController *vc = [[CXWebViewController alloc] init];
    NSString *urlString = (NSString *)openModel;
    vc.URLString = urlString;
    //此处不要直接取keyWindow
    id root = [[UIApplication sharedApplication].delegate window].rootViewController;
    if ([root isMemberOfClass:[UIViewController class]]) {
        
        UIViewController *rootVC = (UIViewController *)root;
        [rootVC.navigationController pushViewController:vc animated:YES];
    }else if ([root isMemberOfClass:[UINavigationController class]]) {
        
        [root pushViewController:vc animated:YES];
    }
}

/**
 MARK: 图片本地读取/或下载完成回调
 
 @param launchAd  XHLaunchAd
 @param image 读取/下载的image
 @param imageData 读取/下载的imageData
 */
- (void)xhLaunchAd:(XHLaunchAd *)launchAd imageDownLoadFinish:(UIImage *)image imageData:(NSData *)imageData {
    
    NSLog(@"图片下载完成/或本地图片读取完成回调");
}

/**
 MARK: video本地读取/或下载完成回调
 
 @param launchAd XHLaunchAd
 @param pathURL  本地保存路径
 */
- (void)xhLaunchAd:(XHLaunchAd *)launchAd videoDownLoadFinish:(NSURL *)pathURL {
    
    NSLog(@"video本地读取/或下载完成回调");
}

/**
 MARK: 视频下载进度回调
 
 @param launchAd XHLaunchAd
 @param progress 下载进度
 @param total    总大小
 @param current  当前已下载大小
 */
- (void)xhLaunchAd:(XHLaunchAd *)launchAd videoDownLoadProgress:(float)progress total:(unsigned long long)total current:(unsigned long long)current {
    
    NSLog(@"总大小=%lld,已下载大小=%lld,下载进度=%f",total,current,progress);
}

/**
 MARK: 倒计时回调
 
 @param launchAd XHLaunchAd
 @param duration 倒计时时间
 */
- (void)xhLaunchAd:(XHLaunchAd *)launchAd customSkipView:(UIView *)customSkipView duration:(NSInteger)duration {
    
    //设置自定义跳过按钮时间
    UIButton *button = (UIButton *)customSkipView;//此处转换为你之前的类型
    //设置时间
    [button setTitle:[NSString stringWithFormat:@"自定义%lds",duration] forState:UIControlStateNormal];
}

/**
 MARK: 广告显示完成
 
 @param launchAd XHLaunchAd
 */
- (void)xhLaunchAdShowFinish:(XHLaunchAd *)launchAd {
 
    NSLog(@"广告显示完成");
}

/**
 MARK: 如果你想用SDWebImage等框架加载网络广告图片,请实现此代理,注意:实现此方法后,图片缓存将不受XHLaunchAd管理
 
 @param launchAd          XHLaunchAd
 @param launchAdImageView launchAdImageView
 @param url               图片url
 */
//- (void)xhLaunchAd:(XHLaunchAd *)launchAd launchAdImageView:(UIImageView *)launchAdImageView URL:(NSURL *)url;


@end
