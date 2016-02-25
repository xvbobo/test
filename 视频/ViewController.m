//
//  ViewController.m
//  视频
//
//  Created by alan on 15/8/19.
//  Copyright (c) 2015年 alan. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()<AVAudioPlayerDelegate,AVCaptureFileOutputRecordingDelegate>
@property (nonatomic,strong) AVPlayer *player;//播放器对象
@property (nonatomic,strong) UIView * container;//播放器容器
@property (nonatomic,strong) UIButton * playOrPause;//播放或暂停
@property (nonatomic,strong) UIProgressView * progress;//播放进度
@property (nonatomic,strong) MPMoviePlayerController * moviePlayer;
@property (nonatomic,strong) NSTimer *myTimer;
@end

@implementation ViewController{
    AVCaptureMovieFileOutput * output;//Movie的文件输出
    NSURL * fileUrl;
    int a;
   
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
  //    UIWebView *myWeb = [[UIWebView alloc] initWithFrame:self.view.bounds];
//    
//    NSURL *url = [NSURL URLWithString:@"http://114.80.180.236/youku/67721D1A72B3781250D0CC314E/030008010055FE646F91B3003E8803C7EB817D-B5ED-1C81-581E-6CCD1370A719.mp4"];
//                  
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//                  
//                  [myWeb setDelegate:self];
//                  
//                  [myWeb loadRequest:request];
//                  
//                  [self.view addSubview:myWeb];
    [self addNotification];
    [self luzhiShiPin];//录制视频

   
    a = 30;
    UILongPressGestureRecognizer *longPress =[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(LongPressed:)];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor redColor];
    button.frame = CGRectMake(200, 400, 70, 70);
    [button addGestureRecognizer:longPress];
    [button addTarget:self action:@selector(clickVideoBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
     [self.moviePlayer play];
}
- (void)LongPressed:(UILongPressGestureRecognizer *)longGesture
{
    if (longGesture.state==UIGestureRecognizerStateBegan) {
        NSLog(@"1");
        self.myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerMove) userInfo:nil repeats:YES];
    }else if(longGesture.state == UIGestureRecognizerStateEnded){//长按结束 录音也结束
        [self.myTimer invalidate];
        self.myTimer=nil;
        //停止录音
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"录制结束" message:@"最多允许录制30秒" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        alert.delegate=self;
        [alert show];
    }
}
- (void)timerMove
{   a -- ;
   NSLog(@"time : %d",a );
    if (a == 0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"录制结束" message:@"最多允许录制30秒" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        alert.delegate=self;
        [alert show];
        [self.myTimer  invalidate];
        
    }
}
- (void)luzhiShiPin
{
    //1.创建视频设备（摄像头前，后）
//     AVCaptureDevice  * deviceAudio1 = [AVCaptureDevice defaultDeviceWithMediaType:AVCaptureDevicePositionBack];
    //2.初始化一个摄像头(first是后置摄像头，last是前置摄像头)
    AVCaptureDevice * deviceAudio = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
     AVCaptureDevice * deviceVideo = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput * inputVideo = [AVCaptureDeviceInput deviceInputWithDevice:deviceVideo error:NULL];
    //3.创建麦克风设备
    
    //4.初始化麦克风输入设备
    AVCaptureDeviceInput * inputAudio=  [AVCaptureDeviceInput deviceInputWithDevice:deviceAudio error:NULL];
    //5.初始化一个movie的文件输出
    output = [[AVCaptureMovieFileOutput alloc] init];
    //6.初始化一个会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
         //7.将输入输出设备添加到会话中
        if ([session canAddInput:inputVideo]) {
                 [session addInput:inputVideo];
             }
        if ([session canAddInput:inputAudio]) {
                 [session addInput:inputAudio];
             }
         if ([session canAddOutput:output]) {
                 [session addOutput:output];
            }
    //8.创建一个预览图层
    AVCaptureVideoPreviewLayer * preLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    //设置图层的大小
    preLayer.frame = self.view.bounds;
    //添加到view上
    [self.view.layer addSublayer:preLayer];
    //9.开始会话
    [session startRunning];
}
- (void)clickVideoBtn:(UIButton *) btn
{

     //判断是否在录制,如果在录制，就停止，并设置按钮title
    if ([output isRecording]) {
        [output stopRecording];
        [btn setTitle:@"录制" forState:UIControlStateNormal];
        return;
    }
    [btn setTitle:@"停止" forState:UIControlStateNormal];
     //10.开始录制视频
     //设置录制视频保存的路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"myVidio.mov"];
    //转为视频保存的url
    NSURL *url = [NSURL fileURLWithPath:path];
    //开始录制,并设置控制器为录制的代理
    [output startRecordingToOutputFileURL:url recordingDelegate:self];
}
#pragma  mark - AVCaptureFileOutputRecordingDelegate
//录制完成代理
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    NSLog(@"%@",outputFileURL);
    //向七牛上传文件
    NSString  * token = @"";//从服务端SDK获取
    NSData * dada = [NSData dataWithContentsOfURL:@"http://7xpayi.media1.z0.glb.clouddn.com/27579_1450692320.mp4"];
    
   
//    [self.moviePlayer play];
    
     NSLog(@"完成录制,可以自己做进一步的处理");
}
- (void)uploadSucceeded:(NSString *)filePath ret:(NSDictionary *)ret
{
     NSLog(@"成功 = %@",ret);
}
- (void)uploadFailed:(NSString *)filePath error:(NSError *)error
{
    NSLog(@"error = %@",error);
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _moviePlayer.fullscreen = NO;
}
- (void)stopButton
{
    [self.moviePlayer stop];
}
- (void)PlayMovieAction:(UIButton*)btn
{
    [self.moviePlayer play];
//    [self.moviePlayer stop];

   

}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//- (NSURL*)getFileUrl{
//    NSString * urlStr = [[NSBundle mainBundle] pathForResource:@"20130116 屌丝男士贺岁版副本" ofType:@"mp4"];
//    NSURL * url = [NSURL fileURLWithPath:urlStr];
//    return url;
//}
- (MPMoviePlayerController * )moviePlayer
{
    //file:///var/mobile/Containers/Data/Application/6DB521AD-677B-4435-8823-6523513A3C7F/Documents/myVidio.mov
//    if (!_moviePlayer) {
        NSURL * url = [NSURL URLWithString:@"http://7xpayi.media1.z0.glb.clouddn.com/27579_1450692320.mp4"];
        _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
        _moviePlayer.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
        _moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        fileUrl = nil;
//        _moviePlayer.controlStyle = MPMovieControlStyleNone;
        [self.view addSubview:_moviePlayer.view];
//    }
    return _moviePlayer;
}
- (void)addNotification
{
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackStateChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.moviePlayer];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlayback:) name:MPMoviePlayerWillEnterFullscreenNotification object:self.moviePlayer];
}
/**
 *  播放状态改变，注意播放完成时的状态是暂停
 *
 *  @param notification 通知对象
 */
- (void)mediaPlayerPlayback:(NSNotification *)notification
{
    
    _moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
}
-(void)mediaPlayerPlaybackStateChange:(NSNotification *)notification{
    switch (self.moviePlayer.playbackState) {
        case MPMoviePlaybackStatePlaying:
            NSLog(@"正在播放...");
            break;
        case MPMoviePlaybackStatePaused:
            NSLog(@"暂停播放.");
            break;
        case MPMoviePlaybackStateStopped:
            NSLog(@"停止播放.");
            break;
        default:
            NSLog(@"播放状态:%li",self.moviePlayer.playbackState);
            break;
    }
}
//**
//*  播放完成
//*
//*  @param notification 通知对象
//*/
-(void)mediaPlayerPlaybackFinished:(NSNotification *)notification{
    NSLog(@"播放完成.%li",self.moviePlayer.playbackState);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
