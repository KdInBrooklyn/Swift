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
        button.tag = self.kViewTag + 2;
        button.addTarget(self, action: #selector(VideoRecordViewController.eventButtonClicked(sender:)), for: .touchUpInside);
        return button;
        }();
    
    //摄像头转换按钮
    fileprivate lazy var btnCameraPosition:UIButton = { [unowned self] in
        let button:UIButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 44.0, y: 0.0, width: 44.0, height: 44.0));
        button.setImage(UIImage(named:"record_camera"), for: .normal);
        button.isExclusiveTouch = true;
        button.tag = self.kViewTag + 3;
        button.addTarget(self, action: #selector(VideoRecordViewController.eventButtonClicked(sender:)), for: .touchUpInside);
        return button;
        }();
    
    //视频预览层
    fileprivate lazy var videoPreviewView:UIView = { [unowned self] in
        let view:UIView = UIView(frame: CGRect(x: 0.0, y: 64.0, width: self.view.frame.size.width, height: self.view.frame.size.width));
        view.backgroundColor = UIColor.red;
        return view;
        }();
    
    
    //录制一段时间之后显示为删除按钮
    fileprivate lazy var btnDelete:UIButton = { [unowned self] in
        let button:UIButton = UIButton(frame: CGRect(x: 20.0, y: self.view.frame.size.width + 67.0 + self.viewSpace, width: 80.0, height: 80.0));
        button.setImage(UIImage(named:"record_del"), for: .normal);
        button.isExclusiveTouch = true;
        button.tag = self.kViewTag + 4;
        button.isHidden = true;
        button.addTarget(self, action: #selector(VideoRecordViewController.eventButtonClicked(sender:)), for: .touchUpInside);
        return button;
        }();
    
    //视频录制完成之后的操作按钮
    fileprivate lazy var btnNext:UIButton = { [unowned self] in
        let button:UIButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 100.0, y: self.view.frame.size.width + 67.0 + self.viewSpace, width: 80.0, height: 80.0));
        button.setImage(UIImage(named:"record_done"), for: .normal);
        button.isExclusiveTouch = true;
        button.tag = self.kViewTag + 5;
        button.isHidden = true;
        button.addTarget(self, action: #selector(VideoRecordViewController.eventButtonClicked(sender:)), for: .touchUpInside);
        return button;
        }();
    
    //导入本地视频操作按钮
    fileprivate lazy var btnImport:UIButton = { [unowned self] in
        let button:UIButton = UIButton(frame: CGRect(x: 20.0, y: self.view.frame.size.width + 67.0 + self.viewSpace, width: 80.0, height: 80.0));
        button.setImage(UIImage(named:"record_photo_library"), for: .normal);
        button.isExclusiveTouch = true;
        button.tag = self.kViewTag + 6;
        button.addTarget(self, action: #selector(VideoRecordViewController.eventButtonClicked(sender:)), for: .touchUpInside);
        return button;
        }();
    
    //视频录制按钮
    fileprivate lazy var btnRecord:UIButton = { [unowned self] in
        let button:UIButton = UIButton(frame: CGRect(x: self.view.frame.size.width / 2.0 - 40.0, y: self.view.frame.size.width + 67.0 + self.viewSpace, width: 80.0, height: 80.0))
        button.setImage(UIImage(named: "record_start"), for: .normal)
        button.tag = self.kViewTag + 7
        button.addTarget(self, action: #selector(VideoRecordViewController.eventButtonClicked(sender:)), for: .touchUpInside)
        return button;
        }();
    
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
    
    
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "视频录制"
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
    
    //MARK: - event response
    func eventButtonClicked(sender: UIButton) {
        let index: Int = sender.tag - self.kViewTag
        if index == 0 {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - private method
    fileprivate func initViews() {
        self.view.addSubview(self.titleBgView);
        self.titleBgView.addSubview(self.btnClose);
        self.titleBgView.addSubview(self.btnFlash);
        self.titleBgView.addSubview(self.btnCameraPosition);
        self.view.addSubview(self.videoPreviewView);
//        self.view.addSubview(self.multiPartProgressView);
        self.view.addSubview(self.btnDelete);
        self.view.addSubview(self.btnImport);
        self.view.addSubview(self.btnRecord);
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
            
            self.videoPreviewView.layer.addSublayer(self.captureVideoPreviewLayer!)
            
            
            
        }
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
    
    
    
    
}

//MARK: - 视频文件输出代理
extension VideoRecordViewController: AVCaptureFileOutputRecordingDelegate {
    //开始录制
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        
    }
    //录制完成
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
    }
}
