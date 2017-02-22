//
//  BBMicroVideoRecordController.swift
//  BoBo
//
//  Created by alimysoyang on 16/10/9.
//  Copyright © 2016年 bobo. All rights reserved.
//

import UIKit
import Foundation
import MobileCoreServices

/// 短视频控制视图
class BBMicroVideoRecordController: BBaseViewController 
{
    // MARK: - property
    fileprivate let kViewTag:Int = 5500;
    
    fileprivate var viewSpace:CGFloat {
        get {
            //MARK: - 暂时注释掉
//            if (BBAppParams.shardInstance.deviceSizeType == .kPST_3_5)
//            {
//                return 10.0;
//            }
            
            return 30.0;
        }
    }
    
    fileprivate lazy var titleBgView:UIView = { [unowned self] in
        let view:UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 44.0));
        view.backgroundColor = UIColor.clear;
        return view;
    }();
    
    fileprivate lazy var btnClose:UIButton = { [unowned self] in
        let button:UIButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0));
        button.setImage(UIImage(named:"close"), for: .normal);
        button.isExclusiveTouch = true;
        button.tag = self.kViewTag;
        button.addTarget(self, action: #selector(BBMicroVideoRecordController.eventButtonClicked(sender:)), for: .touchUpInside);
        return button;
    }();
    
//    fileprivate lazy var btnBFace:UIButton = { [unowned self] in
//        let button:UIButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 142.0, y: 0.0, width: 44.0, height: 44.0));
//        button.setImage(UIImage.QPImageNamed("record_ico_mackup"), for: .normal);
//        button.isExclusiveTouch = true;
//        button.tag = self.kViewTag + 1;
//        button.addTarget(self, action: #selector(BBMicroVideoRecordController.eventButtonClicked(sender:)), for: .touchUpInside);
//        return button;
//    }();
    
    fileprivate lazy var btnFlash:UIButton = { [unowned self] in
        let button:UIButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 93.0, y: 0.0, width: 44.0, height: 44.0));
        button.setImage(UIImage(named:"record_flash_off"), for: .normal);
        button.isExclusiveTouch = true;
        button.tag = self.kViewTag + 2;
        button.addTarget(self, action: #selector(BBMicroVideoRecordController.eventButtonClicked(sender:)), for: .touchUpInside);
        return button;
    }();
    
    fileprivate lazy var btnCameraPosition:UIButton = { [unowned self] in
        let button:UIButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 44.0, y: 0.0, width: 44.0, height: 44.0));
        button.setImage(UIImage(named:"record_camera"), for: .normal);
        button.isExclusiveTouch = true;
        button.tag = self.kViewTag + 3;
        button.addTarget(self, action: #selector(BBMicroVideoRecordController.eventButtonClicked(sender:)), for: .touchUpInside);
        return button;
    }();
    
    fileprivate lazy var btnRecord:BBRecordTouchView = { [unowned self] in
        let button:BBRecordTouchView = BBRecordTouchView(frame: CGRect(x: self.view.frame.size.width / 2.0 - 40.0, y: self.view.frame.size.width + 47.0 + self.viewSpace, width: 80.0, height: 80.0));
        button.delegate = self;
        return button;
    }();
    
    fileprivate lazy var btnDelete:UIButton = { [unowned self] in
        let button:UIButton = UIButton(frame: CGRect(x: 20.0, y: self.view.frame.size.width + 47.0 + self.viewSpace, width: 80.0, height: 80.0));
        button.setImage(UIImage(named:"record_del"), for: .normal);
        button.isExclusiveTouch = true;
        button.tag = self.kViewTag + 4;
        button.isHidden = true;
        button.addTarget(self, action: #selector(BBMicroVideoRecordController.eventButtonClicked(sender:)), for: .touchUpInside);
        return button;
    }();
    
    fileprivate lazy var btnNext:UIButton = { [unowned self] in
        let button:UIButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 100.0, y: self.view.frame.size.width + 47.0 + self.viewSpace, width: 80.0, height: 80.0));
        button.setImage(UIImage(named:"record_done"), for: .normal);
        button.isExclusiveTouch = true;
        button.tag = self.kViewTag + 5;
        button.isHidden = true;
        button.addTarget(self, action: #selector(BBMicroVideoRecordController.eventButtonClicked(sender:)), for: .touchUpInside);
        return button;
    }();
    
    fileprivate lazy var btnImport:UIButton = { [unowned self] in
        let button:UIButton = UIButton(frame: CGRect(x: 20.0, y: self.view.frame.size.width + 47.0 + self.viewSpace, width: 80.0, height: 80.0));
        button.setImage(UIImage(named:"record_photo_library"), for: .normal);
        button.isExclusiveTouch = true;
        button.tag = self.kViewTag + 6;
        button.addTarget(self, action: #selector(BBMicroVideoRecordController.eventButtonClicked(sender:)), for: .touchUpInside);
        return button;
    }();
    
    fileprivate lazy var videoPreviewView:UIView = { [unowned self] in
        let view:UIView = UIView(frame: CGRect(x: 0.0, y: 44.0, width: self.view.frame.size.width, height: self.view.frame.size.width));
        view.backgroundColor = UIColor.clear;
        return view;
    }();
    
    fileprivate lazy var multiPartProgressView:BBMultiPartProgressView = BBMultiPartProgressView(frame: CGRect(x: 0.0, y: self.view.frame.size.width + 44.0, width: self.view.frame.size.width, height: 24.0), minTimeValue:self.minVideoTime , maxTimeValue: self.maxVideoTime);
    
    fileprivate lazy var captureSession:AVCaptureSession = {
        let session:AVCaptureSession = AVCaptureSession();
        session.sessionPreset = AVCaptureSessionPreset640x480;//AVCaptureSessionPresetMedium;
        return session;
    }();
    
    fileprivate lazy var movieFileOutput:AVCaptureMovieFileOutput = {
        let output:AVCaptureMovieFileOutput = AVCaptureMovieFileOutput();
        return output;
    }();
    
    fileprivate lazy var captureVideoPreviewLayer:AVCaptureVideoPreviewLayer = { [unowned self] in
        let layer:AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession);
        layer.frame = self.videoPreviewView.bounds;
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        return layer;
    }();
    
    fileprivate var videoInput:AVCaptureDeviceInput?;
    fileprivate var audioInput:AVCaptureDeviceInput?;
    
    fileprivate lazy var microPartVideoManager:BBMicroPartVideoManager = {
        let manager:BBMicroPartVideoManager = BBMicroPartVideoManager();
        manager.delegate = self;
        return manager;
    }();
    
    fileprivate var minVideoTime:TimeInterval = TimeInterval(BBLoginManager.shardInstance.minRecordTime);      //最短时长
    fileprivate var maxVideoTime:TimeInterval = TimeInterval(BBLoginManager.shardInstance.maxRecordTime);     //最长时长
    fileprivate var isRecording:Bool = false;                                                                                                       //录制中
    fileprivate var isVideoEncoding:Bool = false;                                                                                                //编码处理中
    fileprivate var isOverMaxTime:Bool = false;
    fileprivate var currentCameraPosition:AVCaptureDevicePosition = .back;                                                       //当前摄像头位置
    fileprivate var uploadVideo:BBUploadVideoEntity?;
    fileprivate var isDelPartOK:Bool = false;
    fileprivate var isCancelExport:Bool = false;
    fileprivate lazy var videoResult:BBMicroVideoResult = BBMicroVideoResult();
    
    override var prefersStatusBarHidden: Bool
    {
        return true;
    }
    
    // MARK: - life cycle
    init(uploadVideo:BBUploadVideoEntity)
    {
        super.init(nibName: nil, bundle: nil);
        self.uploadVideo = uploadVideo;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.isPresentViewController = true;
        self.initViews().initRecorder().createTempVideoDir();
    }

    deinit
    {
        String.removeFiles(BBHelper.kAppTmpFilePath);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.isNavigationBarHidden = true;
        
        if (!self.captureSession.isRunning)
        {
            self.captureSession.startRunning();
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated);
        self.captureSession.stopRunning();
        self.movieFileOutput.stopRecording();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func eventEnterBackgroundNotification(_ notification: Notification) {
        super.eventEnterBackgroundNotification(notification);
        UIApplication.dLog("退入后台停止录像");
        self.stopRecording();
        self.isCancelExport = self.microPartVideoManager.cancelExport();
    }
    
    override func eventEnterForegroundNotification(_ notification: Notification) {
        super.eventEnterForegroundNotification(notification);
        if (self.isCancelExport)
        {
            self.isCancelExport = false;
            self.view.alert("视频处理中断", type: .kAVTFailed);
        }
    }
    
    override func viewControllerRepeatLoginNeedDismiss() {
        self.dismiss(animated: true, completion: nil);
    }
    
    // MARK: - public methods

    // MARK: - event response
    internal func eventButtonClicked(sender:UIButton)
    {
        let index:Int = sender.tag - self.kViewTag;
        if (index == 0)//关闭
        {
            self.close(dismiss: { [weak self] in
                if let strongSelf = self
                {
                    strongSelf.dismiss(animated: true, completion: nil);
                }
                }, reset: { [weak self] in
                    if let strongSelf = self
                    {
                        strongSelf.resetMicroVideo();
                    }
                });
        }
        else if (index == 1)//美颜
        {
        }
        else if (index == 2)//Flash
        {
            self.changeFlash();
        }
        else if (index == 3)//摄像头切换
        {
            self.changeCameraPosition();
        }
        else if (index == 4)
        {
            self.deletePartVideo();
        }
        else if (index == 5)//下一步，视频合并
        {
            if (self.videoResult.step == .edit)
            {
                self.toEditViewController();
            }
            else
            {
                if (self.isVideoEncoding || self.isRecording)
                {
                    return;
                }
                self.isVideoEncoding = true;
                let hud:MBProgressHUD = self.view.progressLoading("视频转换中...");
                self.microPartVideoManager.mergeVideos(progress: { (progressValue:Float) in
                    DispatchQueue.main.async(execute: {
                        hud.progress = progressValue;
                    })
                }, completion: { [weak self] (videoFilePath:String, videoThumbnailFilePath:String?) in
                    hud.hide(animated: true);
                    if let strongSelf = self
                    {
                        strongSelf.mergeVideoSuccess(videoFilePath: videoFilePath, videoThumbnailFilePath: videoThumbnailFilePath);
                    }
                    }, failed: { [weak self] (description:String) in
                        hud.hide(animated: true);
                        if let strongSelf = self
                        {
                            strongSelf.mergeVideoFailed(description: description);
                        }
                })
            }
        }
        else if (index == 6)//导入视频
        {
            self.openVideoPickerController();
        }
    }
    
    // MARK: - private methods
    fileprivate func initViews() -> Self
    {
        self.view.backgroundColor = UIColor(rgb: 0x1a1825);
        self.view.addSubview(self.titleBgView);
        self.titleBgView.addSubview(self.btnClose);
//        self.titleBgView.addSubview(self.btnBFace);
        self.titleBgView.addSubview(self.btnFlash);
        self.titleBgView.addSubview(self.btnCameraPosition);
        self.view.addSubview(self.videoPreviewView);
        self.view.addSubview(self.multiPartProgressView);
        self.view.addSubview(self.btnDelete);
        self.view.addSubview(self.btnImport);
        self.view.addSubview(self.btnRecord);
        self.view.addSubview(self.btnNext);
        return self;
    }
    
    fileprivate func createTempVideoDir()
    {
        let value = self.microPartVideoManager.createTempVideoDir();
        if (!value.0)
        {
            self.alertDialog("录制提示", message: value.1, completion: { [weak self] in
                if let strongSelf = self
                {
                    strongSelf.dismiss(animated: true, completion: nil);
                }
            })
        }
    }
    
    fileprivate func initRecorder() -> Self
    {
        if let device:AVCaptureDevice = self.cameraPosition(position: .back)
        {
            do
            {
                self.videoInput = try AVCaptureDeviceInput(device: device);
            }
            catch {
                return self;
            }
        }
        
        let device:AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio);
        do
        {
            self.audioInput = try AVCaptureDeviceInput(device: device);
        }
        catch {
            return self;
        }
        
        if let vInput:AVCaptureDeviceInput = self.videoInput, let aInput:AVCaptureDeviceInput = self.audioInput, self.captureSession.canAddInput(vInput)
        {
            self.captureSession.addInput(vInput);
            if (self.captureSession.canAddInput(aInput))
            {
                self.captureSession.addInput(aInput);
            }
            if (self.captureSession.canAddOutput(self.movieFileOutput))
            {
                self.captureSession.addOutput(self.movieFileOutput);
            }
            if let connection:AVCaptureConnection = self.movieFileOutput.connection(withMediaType: AVMediaTypeVideo)
            {
                connection.preferredVideoStabilizationMode = .auto;
            }
            
            self.videoPreviewView.layer.addSublayer(self.captureVideoPreviewLayer);
            self.captureSession.startRunning();
        }
        
        return self;
    }
    
    fileprivate func cameraPosition(position:AVCaptureDevicePosition) -> AVCaptureDevice?
    {
        let cameras:[Any] = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo);
        for item in cameras
        {
            if let camera:AVCaptureDevice = item as? AVCaptureDevice, (camera.position == position)
            {
                return camera;
            }
        }
        return nil;
    }
    
    // MARK: - 摄像头切换
    fileprivate func changeCameraPosition()
    {
        if (self.isRecording || self.isVideoEncoding)
        {
            return;
        }
        
        if (self.currentCameraPosition == .back)
        {
            self.currentCameraPosition = .front;
            self.btnFlash.isHidden = true;
        }
        else
        {
            self.currentCameraPosition = .back;
            self.showFlashIcon();
        }
        
        if let device:AVCaptureDevice = self.cameraPosition(position: self.currentCameraPosition)
        {
            do
            {
                let newVideoInput:AVCaptureDeviceInput = try AVCaptureDeviceInput(device: device);
                self.captureSession.beginConfiguration();
                self.captureSession.removeInput(self.videoInput!);
                if (self.captureSession.canAddInput(newVideoInput))
                {
                    self.captureSession.addInput(newVideoInput);
                    self.videoInput = newVideoInput;
                }
                else
                {
                    self.captureSession.addInput(self.videoInput!);
                }
                self.captureSession.commitConfiguration();
            }
            catch {
                return;
            }
        }
    }
    
    
    // MARK: - 闪光灯切换
    fileprivate func showFlashIcon()
    {
        self.btnFlash.isHidden = false;
        self.btnFlash.setImage(UIImage(named:"record_flash_off"), for: .normal);
    }
    
    fileprivate func changeFlash()
    {
        if (self.isRecording || self.isVideoEncoding || self.currentCameraPosition == .front)
        {
            return;
        }
        
        if let device:AVCaptureDevice = self.cameraPosition(position: self.currentCameraPosition)
        {
            if (device.torchMode == AVCaptureTorchMode.off)
            {
                do
                {
                    try device.lockForConfiguration();
                    device.torchMode = AVCaptureTorchMode.on;
                    device.unlockForConfiguration();
                    self.btnFlash.setImage(UIImage(named:"record_flash_on"), for: .normal);
                }catch {
                    
                }
            }
            else
            {
                do
                {
                    try device.lockForConfiguration();
                    device.torchMode = AVCaptureTorchMode.off;
                    device.unlockForConfiguration();
                    self.btnFlash.setImage(UIImage(named:"record_flash_off"), for: .normal);
                }catch {
                    
                }
            }
        }
    }
    
    // MARK: - 录像控制
    fileprivate func startRecording()
    {
        if (self.isRecording || self.isVideoEncoding)
        {
            return;
        }
        
        if (self.isOverMaxTime)
        {
            self.view.alert("已经超过录制时间上限", type: .kAVTFailed);
            return;
        }
        
        let connection:AVCaptureConnection = self.movieFileOutput.connection(withMediaType: AVMediaTypeVideo);
        if (connection.isVideoOrientationSupported)
        {
            connection.videoOrientation = AVCaptureVideoOrientation.portrait;
        }
        
        self.movieFileOutput.startRecording(toOutputFileURL: URL(fileURLWithPath: self.microPartVideoManager.tmpVideoFilePath), recordingDelegate: self);
    }
    
    fileprivate func stopRecording()
    {
        self.movieFileOutput.stopRecording();
        if (self.microPartVideoManager.videoRecordTimeThread.state == .running)
        {
            self.microPartVideoManager.videoRecordTimeThread.pause();
        }
    }
    
    fileprivate func deletePartVideo()
    {
        if (self.isRecording || self.isVideoEncoding)
        {
            return;
        }
        
        if (self.isDelPartOK)
        {
            self.microPartVideoManager.removeLastMicroPartVideo();
            self.isDelPartOK = false;
            self.btnDelete.setImage(UIImage(named:"record_del"), for: .normal);
        }
        else
        {
            self.isDelPartOK = true;
            self.btnDelete.setImage(UIImage(named:"record_del_ok"), for: .normal);
        }
    }
    
    fileprivate func resetDeletePartVideo()
    {
        if (self.isDelPartOK)
        {
            self.isDelPartOK = false;
            self.btnDelete.setImage(UIImage(named:"record_del"), for: .normal);
        }
    }
    
    // MARK: - 视频合并处理结果
    fileprivate func mergeVideoSuccess(videoFilePath:String, videoThumbnailFilePath:String?)
    {
        if (!self.btnFlash.isHidden)
        {
            self.showFlashIcon();
        }
        self.isVideoEncoding = false;
        self.videoResult.step = .edit;
        self.videoResult.videoFilePath = videoFilePath;
        self.videoResult.videoThumbnailFilePath = videoThumbnailFilePath;
        UIApplication.dLog("视频转换成功\(videoFilePath)");
        self.toEditViewController();
        
//        UIApplication.dLog("视频转换成功\(videoFilePath)");
//        self.uploadVideo?.uid = BBLoginManager.shardInstance.uId;
//        self.uploadVideo?.videoPath = videoFilePath;
//        self.uploadVideo?.thumbnailPath = videoThumbnailFilePath;
//        let uploadRecordVideoViewController:BBUploadRecordVideoViewController = BBUploadRecordVideoViewController(uploadVideo: self.uploadVideo);
//        self.navigationController?.pushViewController(uploadRecordVideoViewController, animated: true);
    }
    
    fileprivate func mergeVideoFailed(description:String)
    {
        self.isVideoEncoding = false;
        self.view.alert(description, type: .kAVTFailed);
    }
    
    fileprivate func close(dismiss:@escaping emptyClosure, reset:@escaping emptyClosure)
    {
        let alertController:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet);
        let dropAction:UIAlertAction = UIAlertAction(title: "放弃录制", style: .default) { (action:UIAlertAction) in
            dismiss();
        }
        
        let resetAction:UIAlertAction = UIAlertAction(title: "重新录制", style: .destructive) { (action:UIAlertAction) in
            reset();
        }
        
        let cancelAction:UIAlertAction = UIAlertAction(title: "取消", style: .cancel) { (action:UIAlertAction) in
            
        }
        
        alertController.addAction(dropAction);
        alertController.addAction(resetAction);
        alertController.addAction(cancelAction);
        self.present(alertController, animated: true, completion: nil);
    }
    
    fileprivate func resetMicroVideo()
    {
        self.videoResult.reset();
        self.microPartVideoManager.removeAll();
        self.multiPartProgressView.progressView.progress = 0.0;
        self.multiPartProgressView.lbCurrentTime.text = "0.0秒";
        self.resetDeletePartVideo();
        self.btnDelete.isHidden = true;
        self.btnNext.isHidden = true;
        self.btnImport.isHidden = false;
    }
    
    // MARK: - 视频导入
    fileprivate func openVideoPickerController()
    {
        self.showFlashIcon();
        let videoPickerController:UIImagePickerController = UIImagePickerController();
        videoPickerController.allowsEditing = true;
        videoPickerController.delegate = self;
        videoPickerController.mediaTypes = [kUTTypeMovie as String];
        videoPickerController.videoMaximumDuration = self.maxVideoTime;
        videoPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary;
        videoPickerController.view.backgroundColor = UIColor.white;
        self.navigationController?.present(videoPickerController, animated: true, completion: nil);
    }
    
    fileprivate func executeImportVideo(videoAsset:AVAsset?)
    {
        if (self.isRecording || self.isVideoEncoding)
        {
            return;
        }
        
        self.isVideoEncoding = true;
        let hud:MBProgressHUD = self.view.progressLoading("视频导入中...");
        self.microPartVideoManager.importVideo(videoAsset: videoAsset, minTime:self.minVideoTime, maxTime:self.maxVideoTime, progress: { (progressValue:Float) in
            DispatchQueue.main.async(execute: {
                hud.progress = progressValue;
            })
            }, completion: { [weak self] (videoFilePath:String, videoThumbnailFilePath:String?) in
                hud.hide(animated: true);
                if let strongSelf = self
                {
                    strongSelf.mergeVideoSuccess(videoFilePath: videoFilePath, videoThumbnailFilePath: videoThumbnailFilePath);
                }
            }, failed: { [weak self] (description:String) in
                hud.hide(animated: true);
                if let strongSelf = self
                {
                    strongSelf.mergeVideoFailed(description: description);
                }
            })
    }
    
    fileprivate func toEditViewController()
    {
        let editMicroVideoController:BBEditMicroVideoController = BBEditMicroVideoController(result: self.videoResult, uploadVideo: self.uploadVideo);
        self.navigationController?.pushViewController(editMicroVideoController, animated: true);
    }
}


// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate(视频导入界面回调控制)
extension BBMicroVideoRecordController : UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil);
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var videoAsset:AVAsset?;
        if let imageType:String = info[UIImagePickerControllerMediaType] as? String, (imageType == "public.movie")
        {
            if let path:URL = info[UIImagePickerControllerMediaURL] as? URL
            {
                videoAsset = AVAsset(url: path);
            }
        }
        
        picker.dismiss(animated: true, completion: { [weak self] in
            if let strongSelf = self
            {
                strongSelf.executeImportVideo(videoAsset: videoAsset);
            }
        });
    }
}

// MARK: - BBRecordTouchViewDelegate(录制按钮回调，录制开始，录制结束)
extension BBMicroVideoRecordController : BBRecordTouchViewDelegate
{
    func bbRecordTouchViewDidStartRecord(view: BBRecordTouchView) {
        self.videoResult.reset();
        self.resetDeletePartVideo();
        self.startRecording();
    }
    
    func bbRecordTouchViewDidStopRecord(view: BBRecordTouchView) {
        self.stopRecording();
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate(视频录制回调)
extension BBMicroVideoRecordController : AVCaptureFileOutputRecordingDelegate
{
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        if (self.microPartVideoManager.videoRecordTimeThread.state == .stopped)
        {
            self.microPartVideoManager.videoRecordTimeThread.start();
        }
        else if (self.microPartVideoManager.videoRecordTimeThread.state == .suspend)
        {
            self.microPartVideoManager.videoRecordTimeThread.resume();
        }
        self.isRecording = true;
        self.microPartVideoManager.createNewMicroPartVideo(maxTimeValue: self.maxVideoTime, videoFilePath: nil);
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        self.isRecording = false;
        if (error == nil)//录制成功
        {
            self.microPartVideoManager.addMicroPartVideo();
            
            if (self.microPartVideoManager.tmpVideoFileCount >= 1 && self.btnDelete.isHidden)
            {
                self.btnDelete.isHidden = false;
            }
            
        }
        else//录制失败
        {
            if ((error as NSError).code == -11818)
            {
                return;
            }
            UIApplication.dLog("录像错误");
            self.multiPartProgressView.removeErrorVideoDuration(videoDuration: self.microPartVideoManager.newOneVideoDuration);
            self.microPartVideoManager.clearNewPartVideo();
            if (self.microPartVideoManager.tmpVideoFileCount == 0)
            {
                self.btnImport.isHidden = false;
                self.btnDelete.isHidden = true;
            }
        }
        
        UIApplication.dLog(outputFileURL.absoluteString);
        UIApplication.dLog(error);
    }
}

extension BBMicroVideoRecordController : BBMicroPartVideoManagerDelegate
{
    func microVideoRecordDidUpdateTime(newTimeValue: TimeInterval) {
        if (newTimeValue <= self.maxVideoTime)
        {
            self.multiPartProgressView.lbCurrentTime.text = String(format: "%.1f秒", newTimeValue);
            UIApplication.dLog(Float(newTimeValue / self.maxVideoTime));
            self.multiPartProgressView.progressView.progress = Float(newTimeValue / self.maxVideoTime);
            if (newTimeValue > self.minVideoTime && self.btnNext.isHidden)
            {
                self.btnNext.isHidden = false;
            }
            if (!self.btnImport.isHidden)
            {
                self.btnImport.isHidden = true;
            }
        }
        else
        {
            self.isOverMaxTime = true;
            self.stopRecording();
        }
    }
    
    func microPartVideoRemoveLast(newVideoDuration: TimeInterval, deleteVideoDuration: TimeInterval) {
        self.multiPartProgressView.progressView.progress = Float(newVideoDuration / self.maxVideoTime);
        let isRemoveAll:Bool = (newVideoDuration == 0);
        self.btnDelete.isHidden = isRemoveAll;
        self.btnNext.isHidden = (newVideoDuration < self.minVideoTime);
        self.btnImport.isHidden = !isRemoveAll;
        if (isRemoveAll)
        {
            self.multiPartProgressView.lbCurrentTime.text = "0.0秒";
        }
        else
        {
            self.multiPartProgressView.lbCurrentTime.text = String(format: "%.1f秒", newVideoDuration);
        }
        self.isOverMaxTime = false;
        self.videoResult.reset();
    }
}
