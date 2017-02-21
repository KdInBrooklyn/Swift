//
//  FunctionViewController.m
//  录制视频
//
//  Created by BoBo on 17/2/21.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

#import "FunctionViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#pragma mark 使用AVFoundation实现视频录制和拍照功能涉及到的相关类
/**
 1. AVCaptureSession: 媒体(音.视频)捕捉会话,负责把捕获的音视频数据输出到输出设备中,一个AVCaptureSession可以有多个输入输出;
 2. AVCaptureDeviceInput: 输入设备数据管理对象,可以根据AVCaptureDevice创建对应的AVCaptureDeviceInput对象,该对象会被添加到AVCaptureSession中去;
 3. AVCaptureOutput: 输出数据管理对象,用于接收各类输出数据,通常使用对应的子类AVCaptureAudioDataOutput,AVCaptureStillImageOutput,AVCaptureVideoDataOutput,AVCaptureFileOutput.该对象将会被添加到AVCaptureSession中管理. 注意: 前面几个对象的输出数据都是NSData类型,而AVCaptureFileOutput代表数据以文件形式输出,类似的,AVCaptureFileOutput也不会直接创建使用,通常会使用其子类: AVCaptureAudioFileOutput,AVCaptureMovieFileOutput.
 4. 当把一个输入或者输出添加到AVCaptureSession之后,AVCaptureSession就会在所有相符的输入,输出设备之间建立连接(AVCaptionConnection);
 5. AVCaptureVideoPreviewLayer: 相机拍摄预览图层,是CALayer类.使用该对象可以实时查看拍照或视频录制结果,创建该对象需要指定对应的AVCaptureSession对象
 */

#pragma mark 使用AVFoundation拍照和录制视频一般步骤如下:
/**
 1. 创建AVCaptureSession对象;
 2. 使用AVCaptureDevice的静态方法获取需要使用的设备,例如:拍照和录像需要获得摄像头设备,录音就要获得麦克风设备;
 3. 利用输入设备AVCaptureDevice初始化AVCaptureDeviceInput对象;
 4. 初始化输出数据管理对象.如果要拍照就初始化AVCaptureStillImageOutput;如果拍摄视频就初始化AVCaptureMovieFileOutput对象;
 5. 将数据输入对象AVCaptureDeviceInput, 数据输出对象AVCaptureOutput添加到媒体会话管理AVCaptureSession中;
 6. 创建视频预览图层AVCaptureVideoPreviewLayer并指定媒体会话,添加图层到显示容器中,调用AVCaptureSession的startRunning方法开始捕获;
 7. 将捕获的音频或视频数据输出到指定文件
 */

#pragma mark 功能: 摄像头预览,切换前后摄像头,闪光灯设置,对焦,拍照保存

typedef void(^propertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface  FunctionViewController() <AVCaptureFileOutputRecordingDelegate> //视频文件输出代理

@property (nonatomic, strong) AVCaptureSession *captureSession; //负责输入和输出设备之间的数据传递
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput; //负责从AVCaptureDevice获得输入数据
@property (nonatomic, strong) AVCaptureStillImageOutput *captureStillImageOutput; //照片输出流
@property (nonatomic, strong) AVCaptureMovieFileOutput *captureMovieFileOutput;   //视频输出流
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer; //相机拍摄预览图层
@property (nonatomic, assign) BOOL enableRotation; //是否允许旋转(注意:在视频录制过程中进制屏幕旋转)
@property (nonatomic, assign) CGRect *lastBounds;  //旋转前的大小
@property (nonatomic, assign) UIBackgroundTaskIdentifier *backgroundTaskIdentifier; //后台任务标识



@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UIButton *flashAutoBtn; //自动闪光灯按钮
@property (weak, nonatomic) IBOutlet UIButton *flashOnBtn;   //打开闪光灯按钮
@property (weak, nonatomic) IBOutlet UIButton *flashOffBtn;  //关闭闪光灯按钮
@property (weak, nonatomic) IBOutlet UIButton *takeBtn;      //拍照按钮
@property (weak, nonatomic) IBOutlet UIButton *changeCameraBtn; //转换摄像头按钮
@property (weak, nonatomic) IBOutlet UIImageView *focusCursor;  //聚焦光标
@end

@implementation FunctionViewController

#pragma mark life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //初始化会话
    _captureSession = [[AVCaptureSession alloc] init];
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) { //设置分辨率
        _captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    //获得输入设备
    AVCaptureDevice *captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    if (!captureDevice) {
        NSLog(@"获取后置摄像头时出现问题");
        return;
    }
    
    NSError *error = nil;
    //根据输入设备初始化设备输入对象,用于获取输入数据
    _captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"获取设备输入对象时出错,错误原因: %@",error.localizedDescription);
        return;
    }
    
    //初始化设备输出对象,用于获取输出数据
    _captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
    //输出设置
    [_captureStillImageOutput setOutputSettings:outputSettings];
    
    //将设备输入添加到会话中
    if ([_captureSession canAddInput:_captureDeviceInput]) {
        [_captureSession addInput:_captureDeviceInput];
    }
    
    //将设备输出添加到会话中
    if ([_captureSession canAddOutput:_captureStillImageOutput]) {
        [_captureSession addOutput:_captureStillImageOutput];
    }
    
    //创建视频预览层,用于实时展示摄像头状态
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    
    CALayer *layer = self.viewContainer.layer;
//    layer.masksToBounds = YES;
    
    _captureVideoPreviewLayer.frame = layer.frame;
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill; //填充模式
    //将视频预览层添加到界面中
//    [layer addSublayer:_captureVideoPreviewLayer];
    [layer insertSublayer:_captureVideoPreviewLayer below:self.focusCursor.layer];
    
    [self addNotificationToCaptureDevice:captureDevice];
    [self addGestureRecognizer];
    [self setFlashModeButtonStatus];
}

//在视图展示时启动会话
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.captureSession startRunning];
}

//在视图离开界面时停止会话
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.captureSession stopRunning];
}

- (void)dealloc {
    [self removeAllNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark event response
//自动闪光灯开启
- (IBAction)flashAutoDidClick:(UIButton *)sender {
    [self setFlashModel:AVCaptureFlashModeAuto];
    [self setFlashModeButtonStatus];
}

//打开闪光灯
- (IBAction)flashOnDidClick:(UIButton *)sender {
    [self setFlashModel:AVCaptureFlashModeOn];
    [self setFlashModeButtonStatus];
}

//关闭闪光灯
- (IBAction)flashOffDidClick:(UIButton *)sender {
    [self setFlashModel:AVCaptureFlashModeOff];
    [self setFlashModeButtonStatus];
}

//转换摄像头按钮的点击事件
/**
 定义切换摄像头功能,切换摄像头的过程就是讲原有输入移除,在会话中添加新的输入.但是注意动态修改会话需要哦首先开启配置,配置成功之后提交配置
 */
- (IBAction)toggleButtonDidClick:(UIButton *)sender {
    AVCaptureDevice *currentDevice = [self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition = [currentDevice position];
    [self removeNotificationFromCaptureDevice:currentDevice];
    
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition = AVCaptureDevicePositionFront;
    if (currentPosition == AVCaptureDevicePositionUnspecified || currentPosition == AVCaptureDevicePositionFront) {
        toChangePosition = AVCaptureDevicePositionBack;
    }
    
    toChangeDevice = [self getCameraDeviceWithPosition:toChangePosition];
    [self addNotificationToCaptureDevice:toChangeDevice];
    
    //获得要调整的设备输入对象
    AVCaptureDeviceInput *toChangeDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:toChangeDevice error:nil];
    //改变会话的配置前一定要先开启配置,配置完成后提交配置改变
    [self.captureSession beginConfiguration];
    //移除原有输入对象
    [self.captureSession removeInput:self.captureDeviceInput];
    
    //添加新的输入对象
    if ([self.captureSession canAddInput:toChangeDeviceInput]) {
        [self.captureSession addInput:toChangeDeviceInput];
        self.captureDeviceInput = toChangeDeviceInput;
    }
    //提交会话配置
    [self.captureSession commitConfiguration];
    
    [self setFlashModeButtonStatus];
}

//拍照按钮的点击事件
/**
 定义拍照功能,拍照的过程就是获取连接,从连接中获得捕获的输出数据并做保存操作
 */
- (IBAction)takeButtonDidClick:(UIButton *)sender {
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection = [self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    //根据连接取得设备输出的数据
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
    }];
}

#pragma mark Notification
/**
 给输入设备添加通知
 */
- (void)addNotificationToCaptureDevice: (AVCaptureDevice *)captureDevice {
    //注意: 添加区域改变捕获的通知必须首先是设置设备允许捕获
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled = YES;
    }];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    //捕获区域发生改变
    [notificationCenter addObserver:self selector:@selector(areaChanged:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}

- (void)removeNotificationFromCaptureDevice: (AVCaptureDevice *)captureDevice {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}

/**
 
 */
- (void)addNotificationToCaptureSession: (AVCaptureSession *)captureSession {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    //会话出错的通知
    [notificationCenter addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:captureSession];
}

/**
 移除所有通知
 */

- (void)removeAllNotifications {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

/**
 设备连接成功
 
 @param notification 通知对象
 */
- (void)deviceConnected: (NSNotification *)notification {
    NSLog(@"设备已连接");
}

/**
 设备断开连接
 
 @param notification 通知对象
 */
- (void)deviceDisconnected: (NSNotification *)notification {
    NSLog(@"设备已断开");
}

/**
 捕获区域改变
 
 @param notification 通知对象
 */
- (void)areaChanged: (NSNotification *)notification {
    NSLog(@"捕获区域改变");
}

/**
 会话出错
 
 @param notification 通知对象
 */
- (void)sessionRuntimeError: (NSNotification *)notification {
    NSLog(@"会话发生错误");
}

#pragma mark private method
/**
 获得制定位置的摄像头
 
 @param position 摄像头位置
 @return 摄像头设备
 */
- (AVCaptureDevice *)getCameraDeviceWithPosition: (AVCaptureDevicePosition)position {
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    
    return nil;
}

/**
 改变设备属性的统一操作方法
 定义闪光灯开闭及自动模式,注意: 无论是设置闪光灯,白平衡还是其他输入设备属性,在设置之前必须先锁定配置,修改完后解锁
 @param propertyChange 属性改变操作
 */
- (void)changeDeviceProperty: (propertyChangeBlock)propertyChange {
    AVCaptureDevice *captureDevice = [self.captureDeviceInput device];
    NSError *error;
    
    //注意改变设备属性前一定要首先调用lockForConfiguration,调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    } else {
        NSLog(@"设置设备属性过程发生错误,错误信息: %@",error.localizedDescription);
    }
}

/**
 设置闪光灯模式
 
 @param flashMode 闪光灯模式
 */
- (void)setFlashModel: (AVCaptureFlashMode) flashMode {
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];
}

/**
 设置聚焦模式
 
 @param focusMode 聚焦模式
 */
- (void)setFocusMode: (AVCaptureFocusMode)focusMode {
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}

/**
 设置曝光模式
 
 @param exposureMode 曝光模式
 */
- (void)setExposureMode: (AVCaptureExposureMode)exposureMode {
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [self setExposureMode:exposureMode];
        }
    }];
}

/**
 设置聚焦点
 
 @param point 聚焦点
 */
- (void)focusWithMode: (AVCaptureFocusMode)focusMode exposureMode: (AVCaptureExposureMode)exposureMode atPoint: (CGPoint)point {
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}

/**
 设置闪光灯按钮状态
 */
- (void)setFlashModeButtonStatus {
    AVCaptureDevice *captureDevice = [self.captureDeviceInput device];
    AVCaptureFlashMode flashMode = captureDevice.flashMode;
    
    if ([captureDevice isFlashAvailable]) {
        self.flashAutoBtn.hidden = NO;
        self.flashOnBtn.hidden = NO;
        self.flashOffBtn.hidden = NO;
        
        self.flashAutoBtn.enabled = YES;
        self.flashOnBtn.enabled  = YES;
        self.flashOffBtn.enabled = YES;
        
        switch (flashMode) {
            case AVCaptureFlashModeAuto:
                self.flashAutoBtn.enabled = NO;
                break;
            case AVCaptureFlashModeOn:
                self.flashOnBtn.enabled = NO;
                break;
            case AVCaptureFlashModeOff:
                self.flashOffBtn.enabled = NO;
                break;
            default:
                break;
        }
    } else {
        self.flashAutoBtn.hidden = YES;
        self.flashOnBtn.hidden = YES;
        self.flashOffBtn.hidden = YES;
    }
}

/**
 *设置聚焦光标位置
 
 *@param point 光标位置
 */
- (void)setFocusCursorWithPoint: (CGPoint)point {
    self.focusCursor.center = point;
    self.focusCursor.transform = CGAffineTransformMakeScale(1.5, 1.5);
    self.focusCursor.alpha = 1.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.focusCursor.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursor.alpha = 0.0;
    }];
}

/**
 * 添加点按手势,点按时预览视图时进行聚焦,白平衡设置
 */
- (void)addGestureRecognizer {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventTapGestureResponse:)];
    [self.viewContainer addGestureRecognizer:tapGesture];
}

-(void)eventTapGestureResponse: (UITapGestureRecognizer *)tapGesture {
    CGPoint point = [tapGesture locationInView:self.view];
    //将UI坐标转换为摄像头坐标
    CGPoint cameraPoint = [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

@end
