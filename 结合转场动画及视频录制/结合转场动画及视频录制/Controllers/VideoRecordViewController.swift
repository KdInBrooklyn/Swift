//
//  VideoRecordViewController.swift
//  结合转场动画及视频录制
//
//  Created by 李森 on 2017/2/23.
//  Copyright © 2017年 李森. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import MobileCoreServices

typealias propertyChangeClosure = (_ captureDevice: AVCaptureDevice) -> Void

class VideoRecordViewController: UIViewController {
    
    //MARK: - properties
    var kViewTag: Int = 0
    fileprivate var viewSpace: CGFloat = 10.0
    
    fileprivate lazy var titleBgView:UIView = { [unowned self] in
        let view:UIView = UIView(frame: CGRect(x: 0.0, y: 20.0, width: self.view.frame.size.width, height: 44.0));
        view.backgroundColor = UIColor.clear;
        return view;
        }();
    
    //关闭按钮
    fileprivate lazy var btnClose:UIButton = { [unowned self] in
        let button:UIButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0));
        button.setImage(UIImage(named:"close"), for: .normal);
        button.isExclusiveTouch = true;
        button.tag = self.kViewTag;
        button.addTarget(self, action: #selector(VideoRecordViewController.eventButtonClicked(sender:)), for: .touchUpInside);
        return button;
        }();
    
    //开启闪光灯
    fileprivate lazy var btnFlash:UIButton = { [unowned self] in
        let button:UIButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 93.0, y: 0.0, width: 44.0, height: 44.0));
        button.setImage(UIImage(named:"record_flash_off"), for: .normal);
        button.isExclusiveTouch = true;
        button.tag = self.kViewTag + 1;
        button.addTarget(self, action: #selector(VideoRecordViewController.eventButtonClicked(sender:)), for: .touchUpInside);
        return button;
        }();
    
    //摄像头转换按钮
    fileprivate lazy var btnCameraPosition:UIButton = { [unowned self] in
        let button:UIButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 44.0, y: 0.0, width: 44.0, height: 44.0));
        button.setImage(UIImage(named:"record_camera"), for: .normal);
        button.isExclusiveTouch = true;
        button.tag = self.kViewTag + 2;
        button.addTarget(self, action: #selector(VideoRecordViewController.eventButtonClicked(sender:)), for: .touchUpInside);
        return button;
        }();
    
    //视频预览层
    fileprivate lazy var videoPreviewView:UIView = { [unowned self] in
        let view:UIView = UIView(frame: CGRect(x: 0.0, y: 64.0, width: self.view.frame.size.width, height: self.view.frame.size.width));
        view.backgroundColor = UIColor.gray
        return view;
        }();
    
    //聚焦视图
    fileprivate lazy var focusView: FocusView = { [unowned self] in
        let view: FocusView = FocusView(frame: CGRect(x: (self.videoPreviewView.frame.size.width - 60) / 2.0, y: (self.videoPreviewView.frame.size.height - 60.0) / 2.0, width: 60.0, height: 60.0))
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    //录制一段时间之后显示为删除按钮
    fileprivate lazy var btnDelete:UIButton = { [unowned self] in
        let button:UIButton = UIButton(frame: CGRect(x: 20.0, y: self.view.frame.size.width + 67.0 + self.viewSpace, width: 80.0, height: 80.0));
        button.setImage(UIImage(named:"record_del"), for: .normal);
        button.isExclusiveTouch = true;
        button.tag = self.kViewTag + 3;
        button.isHidden = true;
        button.addTarget(self, action: #selector(VideoRecordViewController.eventButtonClicked(sender:)), for: .touchUpInside);
        return button;
        }();
    
    //视频录制完成之后的操作按钮
    fileprivate lazy var btnNext:UIButton = { [unowned self] in
        let button:UIButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 100.0, y: self.view.frame.size.width + 67.0 + self.viewSpace, width: 80.0, height: 80.0));
        button.setImage(UIImage(named:"record_done"), for: .normal);
        button.isExclusiveTouch = true;
        button.tag = self.kViewTag + 4;
        button.isHidden = true;
        button.addTarget(self, action: #selector(VideoRecordViewController.eventButtonClicked(sender:)), for: .touchUpInside);
        return button;
        }();
    
    //导入本地视频操作按钮
    fileprivate lazy var btnImport:UIButton = { [unowned self] in
        let button:UIButton = UIButton(frame: CGRect(x: 20.0, y: self.view.frame.size.width + 67.0 + self.viewSpace, width: 80.0, height: 80.0));
        button.setImage(UIImage(named:"record_photo_library"), for: .normal);
        button.isExclusiveTouch = true;
        button.tag = self.kViewTag + 5;
        button.addTarget(self, action: #selector(VideoRecordViewController.eventButtonClicked(sender:)), for: .touchUpInside);
        return button;
        }();
    
    //视频录制按钮
    fileprivate lazy var recordView:RecordView = { //[unowned self] in
        let view:RecordView = RecordView(frame: CGRect(x: self.view.frame.size.width / 2.0 - 40.0, y: self.view.frame.size.width + 67.0 + self.viewSpace, width: 80.0, height: 80.0))
        view.backgroundColor = UIColor.clear
        view.delegate = self
        return view;
        }();
//    fileprivate lazy var btnRecord:UIButton = { [unowned self] in
//        let button:UIButton = UIButton(frame: CGRect(x: self.view.frame.size.width / 2.0 - 40.0, y: self.view.frame.size.width + 67.0 + self.viewSpace, width: 80.0, height: 80.0))
//        button.setImage(UIImage(named: "record_start"), for: .normal)
//        button.tag = self.kViewTag + 6
//        button.addTarget(self, action: #selector(VideoRecordViewController.eventButtonClicked(sender:)), for: .touchUpInside)
//        return button;
//        }();
    
    
    //MARK: - 实现视频录制需要的几个类
    //负责输入和输出设备之间的数据传递
    fileprivate var captureSession: AVCaptureSession = {
        let session: AVCaptureSession = AVCaptureSession()
        if session.canSetSessionPreset(AVCaptureSessionPreset640x480) {//设置分辨率
            session.sessionPreset = AVCaptureSessionPreset640x480 //AVCaptureSessionPresetMedium
        }
        
        return session
    }()
    fileprivate var captureDeviceInput: AVCaptureDeviceInput? //负责从AVCaptureDevice获得输入数据
    fileprivate var captureAudioInput: AVCaptureDeviceInput?  //负责获取音频数据
    fileprivate var captureMovieFileOutput: AVCaptureMovieFileOutput = {
       return AVCaptureMovieFileOutput()
    }() //视频输出流
    fileprivate var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer? //相机拍摄预览层
    fileprivate var isEnabelRotation: Bool = false // 是否允许旋转(在视频录制过程中禁止屏幕旋转)
    fileprivate var lastBounds: CGRect? //旋转前的大小
    fileprivate var backgroundIdentifier: UIBackgroundTaskIdentifier? //后台任务标识
    
    //测试视频是否存储在该目录下
    fileprivate var videoPath: String?
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        self.initViews()
        self.initRecords()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.captureSession.stopRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        
    }
    
    //MARK: - event response
    func eventButtonClicked(sender: UIButton) {
        let index: Int = sender.tag - self.kViewTag
        if index == 0 { //关闭按钮
            self.dismiss(animated: true, completion: nil)
        } else if index == 1 { //开启闪光灯
            
        } else if index == 2 { //转换摄像头
            
        } else if index == 3 { //删除录制的之前的视频
            
        } else if index == 4 { //录制完成之后出现的按钮
            
        } else if index == 5 { //导入本地视频
            //视频导入成功之后直接进入视频编辑界面
            self.openVideoPickerController()
        } else if index == 6 { //录制按钮
            self.recordVideo()
        }
    }
    
    func eventUserTapScreen(sender: UITapGestureRecognizer) {
        let point: CGPoint = sender.location(in: self.videoPreviewView)
        //将UI坐标转换为摄像头坐标
        let cameraPoint = self.captureVideoPreviewLayer?.captureDevicePointOfInterest(for: point)
        
        //界面上聚焦光标的放大缩小动画
        UIView.animate(withDuration: 0.2, animations: {
            self.focusView.alpha = 0.0
        }) { (isFinished: Bool) in
            self.focusView.center = point
            self.focusView.alpha = 1.0
        }
        UIView.animate(withDuration: 0.2, delay: 0.1, options: [.curveEaseInOut], animations: {
            self.focusView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { (isFinished: Bool) in
            self.focusView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        
        //设置摄像头的聚焦点
        self.changeDeviceProperty { (captureDevice: AVCaptureDevice) in
            if captureDevice.isFocusModeSupported(AVCaptureFocusMode.autoFocus) {
                captureDevice.focusMode = AVCaptureFocusMode.autoFocus
            }
            if captureDevice.isFocusPointOfInterestSupported {
                captureDevice.focusPointOfInterest = cameraPoint!
            }
            
            if captureDevice.isExposureModeSupported(AVCaptureExposureMode.autoExpose) {
                captureDevice.exposureMode = AVCaptureExposureMode.autoExpose
            }
            if captureDevice.isExposurePointOfInterestSupported {
                captureDevice.exposurePointOfInterest = cameraPoint!
            }
        }
    }
    
    //MARK: - private method
    fileprivate func initViews() {
        self.view.addSubview(self.titleBgView);
        self.titleBgView.addSubview(self.btnClose);
        self.titleBgView.addSubview(self.btnFlash);
        self.titleBgView.addSubview(self.btnCameraPosition);
        self.videoPreviewView.addSubview(self.focusView);
        self.view.addSubview(self.videoPreviewView);
//        self.view.addSubview(self.multiPartProgressView);
        self.view.addSubview(self.btnDelete);
        self.view.addSubview(self.btnImport);
        self.view.addSubview(self.recordView);
        self.view.addSubview(self.btnNext);
    }
    
    fileprivate func initRecords() {
        //获取输入设备
        if let device: AVCaptureDevice = self.getCameraDevice(withPosition: .back) {
            do {
                self.captureDeviceInput = try AVCaptureDeviceInput(device: device)
            } catch  {
                print("\(error.localizedDescription)")
            }
        }
        
        //添加一个音频输入设备
        let device: AVCaptureDevice? = AVCaptureDevice.devices(withMediaType: AVMediaTypeAudio).first as? AVCaptureDevice
        do {
            self.captureAudioInput = try AVCaptureDeviceInput(device: device)
        } catch {
            print("\(error.localizedDescription)")
        }
        
        //初始化设备输出对象，用于获得输出数据(本Demo使用懒加载创建对象）
        
        //将设备输入添加到会话中
        if let vInput: AVCaptureDeviceInput = self.captureDeviceInput, let audioInput: AVCaptureDeviceInput = self.captureAudioInput, self.captureSession.canAddInput(vInput) {
            self.captureSession.addInput(vInput)
            if self.captureSession.canAddInput(audioInput) {
                self.captureSession.addInput(audioInput)
            }
            
            //将设备输出添加到会话中
            if self.captureSession.canAddOutput(self.captureMovieFileOutput) {
                self.captureSession.addOutput(self.captureMovieFileOutput)
            }
            
            if let connection = self.captureMovieFileOutput.connection(withMediaType: AVMediaTypeVideo) {
                connection.preferredVideoStabilizationMode = .auto
            }
            
            //创建视频预览层，用于实时展示摄像头状态
            self.captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.captureVideoPreviewLayer?.frame = self.videoPreviewView.bounds
            self.captureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            
//            self.videoPreviewView.layer.addSublayer(self.captureVideoPreviewLayer!)
            self.videoPreviewView.layer.insertSublayer(self.captureVideoPreviewLayer!, below: self.focusView.layer)
            self.addTapGesture()
        }
    }
    
    //给视频展示层添加点按聚焦手势
    fileprivate func addTapGesture() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(VideoRecordViewController.eventUserTapScreen(sender:)))
        
        self.videoPreviewView.addGestureRecognizer(tapGesture)
    }
    
    //获得输入设备
    fileprivate func getCameraDevice(withPosition position: AVCaptureDevicePosition) -> AVCaptureDevice?{
        let cameras: [Any] = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        for item in cameras {
            if let camera = item as? AVCaptureDevice, camera.position == position {
                return camera
            }
        }
        
        return nil
    }
    
    
    //导入本地视频
    fileprivate func openVideoPickerController() {
        let pickerController: UIImagePickerController = UIImagePickerController()
        pickerController.allowsEditing = true
        pickerController.delegate = self
        pickerController.mediaTypes = [kUTTypeMovie as String]
        pickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        pickerController.transitioningDelegate = self
        self.present(pickerController, animated: true, completion: nil)
    }
    
    //视频录制
    fileprivate func recordVideo() {
        //根据设备输出获得连接
        let captureConnection: AVCaptureConnection = self.captureMovieFileOutput.connection(withMediaType: AVMediaTypeVideo)
        //根据连接取得设备输出的数据
        if (!self.captureMovieFileOutput.isRecording) { //视频为录制时的按钮点击事件
            if (UIDevice.current.isMultitaskingSupported) {
                self.backgroundIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
            }
            
            //创建视频文件保存路径
            let outputFilePath = NSTemporaryDirectory().appending("myMovie.mov")
            
            self.videoPath = outputFilePath
            
            
            let fileURL = URL(fileURLWithPath: outputFilePath)
            
            //将录制的视频文件保存到上面的路径里面
            self.captureMovieFileOutput.startRecording(toOutputFileURL: fileURL, recordingDelegate: self)
            
            
            print(outputFilePath)
            
            
        } else { //视频录制过程中的按钮点击事件
            self.captureMovieFileOutput.stopRecording()
        }
    }
    
    //改变设备属性的统一操作方法
    fileprivate func changeDeviceProperty(_ propertyChange: propertyChangeClosure) {
        let captureDevice = self.captureDeviceInput?.device
        //注意改变设备属性前一定要首先调用,调用完之后解锁
        do {
            if (try captureDevice?.lockForConfiguration() != nil) {
                propertyChange(captureDevice!)
                captureDevice?.unlockForConfiguration()
            }
        } catch  {
            print("\(error.localizedDescription)")
        }
        
    }
    
}

//转场代理
extension VideoRecordViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomAnimator()
    }
}

//MARK: - 视频文件输出代理
extension VideoRecordViewController: AVCaptureFileOutputRecordingDelegate {
    //开始录制
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("开始录制")
    }
    
    //录制完成
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        //视频录制完成之后在后台将视频保存到相册
        let lastBackgroundTaskIdentifier = self.backgroundIdentifier
        self.backgroundIdentifier = UIBackgroundTaskInvalid
        let assetsLibrary = ALAssetsLibrary()
        assetsLibrary.writeVideoAtPath(toSavedPhotosAlbum: outputFileURL) { (assetURL: URL?, error: Error?) in
            if (error != nil) {
                print("保存视频到相册中发生错误\(error?.localizedDescription)")
            }
            
            //暂时注释掉,不理解其具体作用
//            if (lastBackgroundTaskIdentifier != UIBackgroundTaskInvalid) {
//                UIApplication.shared.endBackgroundTask(lastBackgroundTaskIdentifier!)
//            }
            
        }
        
        let fileManager: FileManager = FileManager.default
        
        do {
            let files = try fileManager.contents(atPath: self.videoPath!)
            
            for item in files! {
//                print(item)
            }
        } catch {
            print("\(error.localizedDescription)")
        }
    }
}

extension VideoRecordViewController: RecordViewDelegate {
    //中间录制按钮开始录制
    func recordViewDidStart(_ recordView: RecordView) {
        self.recordVideo()
    }
    
    //中间录制按钮结束录制
    func recordViewDidSop(_ recordView: RecordView) {
        
    }
}

//MARK: -
extension VideoRecordViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
