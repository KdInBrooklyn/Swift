//
//  BBEditMicroVideoController.swift
//  BoBo
//
//  Created by alimysoyang on 16/10/18.
//  Copyright © 2016年 bobo. All rights reserved.
//

import UIKit
import Foundation
import AVKit

//视频编辑界面
class BBEditMicroVideoController: BBaseViewController 
{

    // MARK: - property
    fileprivate let kViewTag:Int = 6100;
    fileprivate  var bottomHeight:CGFloat {
        get {
            if (BBAppParams.shardInstance.deviceSizeType == .kPST_4_7 || BBAppParams.shardInstance.deviceSizeType == .kPST_5_5)
            {
                return 210.0;
            }
            return UIView.kScreenHeight - UIView.kScreenWidth - 44.0;
        }
    }
    
    fileprivate lazy var btnBack:UIButton = { [unowned self] in
        let button:UIButton = UIButton(frame:CGRect(x: 0.0, y: 0.0, width: 80.0, height: 44.0));
        button.setImage(UIImage(named:"record_bar_back"), for: .normal);
        button.titleLabel?.font = BBHelper.p14;
        button.setTitleColor(BBHelper.darkGrayTextColor, for: .normal);
        button.setTitle("返回", for: .normal);
        button.titleEdgeInsets = UIEdgeInsetsMake(0.0, -3.0, 0.0, 0.0);
        button.imageEdgeInsets = UIEdgeInsetsMake(0.0, -7.0, 0.0, 0.0);
        button.tag = self.kViewTag;
        button.addTarget(self, action: #selector(BBEditMicroVideoController.eventButtonClicked(sender:)), for: .touchUpInside);
        return button;
    }();
    
    fileprivate lazy var btnNext:UIButton = { [unowned self] in
        let image:UIImage = UIImage(named:"record_bar_next")!;
        let button:UIButton = UIButton(frame:CGRect(x: self.view.frame.size.width - 80.0, y: 0.0, width: 80.0, height: 44.0));
        button.setImage(image, for: .normal);
        button.titleLabel?.font = BBHelper.p14;
        button.setTitleColor(BBHelper.darkGrayTextColor, for: .normal);
        button.setTitle("下一步", for: .normal);
        button.imageEdgeInsets = UIEdgeInsetsMake(0.0, 40.0, 0.0, -40.0);
        button.titleEdgeInsets = UIEdgeInsetsMake(0.0, -(image.size.width + 5.0), 0.0, (image.size.width + 5.0));
        button.tag = self.kViewTag + 1;
        button.addTarget(self, action: #selector(BBEditMicroVideoController.eventButtonClicked(sender:)), for: .touchUpInside);
        return button;
    }();
    
    fileprivate lazy var lbTitle:UILabel = {
        let label:UILabel = UILabel(frame: CGRect(x: self.view.frame.size.width / 2.0 - 50.0, y: 0.0, width: 100.0, height: 44.0));
        label.text = "编辑视频";
        label.font = BBHelper.p14;
        label.textColor = BBHelper.darkGrayTextColor;
        label.textAlignment = .center;
        return label;
    }();
    
    fileprivate lazy var playerView:BBLocalAVPlayerView = { [unowned self] in
        let view:BBLocalAVPlayerView = BBLocalAVPlayerView(frame: CGRect(x: 0.0, y: 44.0, width: self.view.frame.size.width, height: self.view.frame.size.width), localVideoPath: self.videoResult?.videoFilePath);
        view.delegate = self;
        return view;
    }();
    
    fileprivate lazy var loadingView:BBLoadEditResourceView = { [unowned self] in
        let view:BBLoadEditResourceView = BBLoadEditResourceView(frame: CGRect(x: 0.0, y: UIView.kScreenHeight - self.bottomHeight, width: UIView.kScreenWidth, height: self.bottomHeight));
        view.delegate = self;
        return view;
    }();
    
    fileprivate lazy var editMicroVideoKeyboardView:BBEditMicroVideoKeyboardView = BBEditMicroVideoKeyboardView(frame: CGRect(x: 0.0, y:UIView.kScreenHeight, width:UIView.kScreenWidth, height: self.bottomHeight));
    fileprivate lazy var audioControlView:BBEditAudioControlView = {
        let view:BBEditAudioControlView = BBEditAudioControlView(frame: CGRect(x: 0.0, y:UIView.kScreenHeight - self.bottomHeight - 36.0, width:UIView.kScreenWidth, height: 36.0));
        view.isHidden = true;
        view.delegate = self;
        return view;
    }();
    
    fileprivate var audioPlayer:BBAudioPlayer?;
    fileprivate var videoResult:BBMicroVideoResult?;
    fileprivate var uploadVideo:BBUploadVideoEntity?;
    fileprivate var microVideoMetasManager:BBMicroVideoMetasManager = BBMicroVideoMetasManager();
    fileprivate var isVideoEncoding:Bool = false;
    fileprivate var isCancelExport:Bool = false;
    
    override var prefersStatusBarHidden: Bool
    {
        return true;
    }
    
    // MARK: - life cycle
    init(result:BBMicroVideoResult, uploadVideo:BBUploadVideoEntity?)
    {
        self.videoResult = result;
        self.uploadVideo = uploadVideo;
        super.init(nibName: nil, bundle: nil);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.initViews();
        
        self.requestResource();
        
        self.playerView.start();
        
        self.keyboardViewClosure();
    }

    deinit
    {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        self.audioPlayer?.pause();
        self.playerView.pause();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func eventEnterBackgroundNotification(_ notification: Notification) {
        super.eventEnterBackgroundNotification(notification);
        self.isCancelExport = self.microVideoMetasManager.cancelExport();
        if (!self.isCancelExport)
        {
            self.playerView.gifLayer?.pauseAnimating();
        }
    }
    
    override func eventEnterForegroundNotification(_ notification: Notification) {
        super.eventEnterForegroundNotification(notification);
        if (self.isCancelExport)
        {
            self.isCancelExport = false;
            self.isVideoEncoding = false;
            self.view.alert("视频生成中断", type: .kAVTFailed);
        }
        
        self.playerView.resume();
        self.audioPlayer?.resume();
        self.playerView.gifLayer?.resumeAnimating();
    }
    
    // MARK: - public methods

    // MARK: - event response
    internal func eventButtonClicked(sender:UIButton)
    {
        if (self.isVideoEncoding)
        {
            return;
        }
        
        let index:Int = sender.tag - self.kViewTag;
        if (index == 0)
        {
            let _ = self.navigationController?.popViewController(animated: true);
        }
        else
        {
            self.toResourcesComposite();
        }
    }
    
    // MARK: - private methods
    fileprivate func initViews()
    {
        self.view.addSubview(self.btnBack);
        self.view.addSubview(self.lbTitle);
        self.view.addSubview(self.btnNext);
        self.view.addSubview(self.playerView);
        self.view.addSubview(self.loadingView);
        self.view.addSubview(self.audioControlView);
        self.view.addSubview(self.editMicroVideoKeyboardView);
    }
    
    fileprivate func requestResource()
    {
        self.loadingView.startAnimating();
        BBNetworking.shardInstance.loadEditMicroVideoResources(success: { [weak self] (manager:BBEditResourceManager) in
            if let strongSelf = self
            {
                strongSelf.loadingView.stopAnimating();
                strongSelf.loadingView.removeFromSuperview();
                strongSelf.showEditKeyboardView(manager: manager);
            }
        }, failed: { [weak self] (description:String) in
            if let strongSelf = self
            {
                strongSelf.loadingView.stopAnimating();
                strongSelf.loadingView.failed();
                strongSelf.view.alert(description, type: .kAVTFailed);
            }
        })
    }
    
    fileprivate func keyboardViewClosure()
    {
        //选择了空的资源
        self.editMicroVideoKeyboardView.editMicroVideoResourceEmpty = { [weak self] (type:Int) in
            if let strongSelf = self, let typeValue:BBEditMicroVideoType = BBEditMicroVideoType(rawValue: type)
            {
                if (typeValue == .animation)
                {
                    strongSelf.playerView.gifLayer = nil;
//                    strongSelf.playerView.emptyGif();
                }
                else if (typeValue == .music)
                {
                    strongSelf.audioPlayerRemove();
                }
            }
        }
        
        //正在下载时，选择其他资源
        self.editMicroVideoKeyboardView.editMicroVideoResourceDownloading = { [weak self] in
            if let strongSelf = self
            {
                strongSelf.view.alert("资源下载中，暂不能切换", type: .kAVTFailed);
            }
        }
        
        //下载失败了
        self.editMicroVideoKeyboardView.editMicroVideoResourceDownloadFailed = { [weak self] (description:String) in
            if let strongSelf = self
            {
                strongSelf.view.alert(description, type: .kAVTFailed);
            }
        }
        
        //下载成功和选择已下载的资源
        self.editMicroVideoKeyboardView.editMicroVideoResourceShow = { [weak self] (resource:BBEditResource) in
            if let strongSelf = self
            {
                if (resource.resourceType == .animation)
                {
//                    strongSelf.loadGif(resource: resource);
                    strongSelf.playerView.gifLayer = GifAnimationLayer(gifFilePath: resource.fullocalPath);
                }
                else if (resource.resourceType == .music)
                {
                    strongSelf.initAudioPlayer(localPath: resource.fullocalPath);
                }
            }
        }
        
        //变换到音频资源时
        self.editMicroVideoKeyboardView.editMicroVideoResourceChangeToAudio = { [weak self] (isAudio:Bool) in
            if let strongSelf = self
            {
                strongSelf.audioControlView.isHidden = !isAudio;
            }
        }
    }
    
    fileprivate func showEditKeyboardView(manager:BBEditResourceManager)
    {
        self.editMicroVideoKeyboardView.resourceManager = manager;
        UIView.animate(withDuration: 0.25) { 
            var frame:CGRect = self.editMicroVideoKeyboardView.frame;
            frame.origin.y = UIView.kScreenHeight - self.bottomHeight;
            self.editMicroVideoKeyboardView.frame = frame;
        }
    }
    
    fileprivate func audioPlayerRemove()
    {
        self.audioPlayer?.stop();
        self.audioPlayer = nil;
        self.playerView.volume = 1.0;
    }
    
    fileprivate func initAudioPlayer(localPath:String)
    {
        self.audioPlayerRemove();
        self.audioPlayer = BBAudioPlayer(localFilePath: localPath, loopNumber: -1);
        self.audioPlayer?.delegate = self;
        self.playerView.volume = self.audioControlView.volumn;
        self.audioPlayer?.volume = 1.0 - self.audioControlView.volumn;
    }
    
    fileprivate func toResourcesComposite()
    {
        if let videoPath:String = self.videoResult?.videoFilePath
        {
            self.audioPlayer?.pause();
            self.playerView.videoComposition();
            
            var resources:BBMicroVideoResourceMetas = self.editMicroVideoKeyboardView.resourceMetas();
            if (resources.isEmpty)
            {
                let videoThumbnailFilePath:String? = BBHelper.createVideoThumbnail(videoFilePath: videoPath);
                self.resourcesCompositeSuccess(videoFilePath: videoPath, videoThumbnailFilePath: videoThumbnailFilePath);
            }
            else
            {
                resources.sourceVolumn = self.playerView.volume;
                if let player = self.audioPlayer
                {
                    resources.mixVolumn = player.volume;
                }
                else
                {
                    resources.mixVolumn = 0.0;
                }
                self.isVideoEncoding = true;
                let hud:MBProgressHUD = self.view.progressLoading("视频生成中...");
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
                    self.microVideoMetasManager.resourcesCompositeVideo(videoPath: videoPath, resourceMetas: resources, progress: { (progressValue:Float) in
                        DispatchQueue.main.async(execute: {
                            hud.progress = progressValue;
                        })
                    }, completion: { [weak self] (videoFilePath:String, videoThumbnailFilePath:String?) in
                        hud.hide(animated: true);
                        if let strongSelf = self
                        {
                            strongSelf.resourcesCompositeSuccess(videoFilePath: videoFilePath, videoThumbnailFilePath: videoThumbnailFilePath);
                        }
                        }, failed: { [weak self] (description:String) in
                            hud.hide(animated: true);
                            if let strongSelf = self
                            {
                                strongSelf.resourcesCompositeFailure(descripiton: description);
                            }
                    })
                })
            }
        }
    }
    
    fileprivate func resourcesCompositeSuccess(videoFilePath:String, videoThumbnailFilePath:String?)
    {
        self.playerView.removeAll();
        self.audioPlayer?.stop();
        
        self.isVideoEncoding = false;
        UIApplication.dLog("视频编辑成功\(videoFilePath)");
        self.uploadVideo?.uid = BBLoginManager.shardInstance.uId;
        self.uploadVideo?.videoPath = videoFilePath;
        self.uploadVideo?.thumbnailPath = videoThumbnailFilePath;
        let uploadRecordVideoViewController:BBUploadRecordVideoViewController = BBUploadRecordVideoViewController(uploadVideo: self.uploadVideo);
        self.navigationController?.pushViewController(uploadRecordVideoViewController, animated: true);
    }
    
    fileprivate func resourcesCompositeFailure(descripiton:String)
    {
        self.isVideoEncoding = false;
        self.view.alert("视频生成失败", type: .kAVTFailed);
    }
    
//    fileprivate func loadGif(resource:BBEditResource)
//    {
//        self.view.alertLoading("加载动图");
//        self.playerView.loadGif(localFilePath: resource.fullocalPath, completion:{ [weak self] in
//            if let strongSelf = self
//            {
//                strongSelf.view.hideAlertLoading();
//            }
//        });
//    }
}

// MARK: - BBLoadEditResourceViewDelegate(编辑资源加载回调)
extension BBEditMicroVideoController : BBLoadEditResourceViewDelegate
{
    func reloadResource() {
        self.requestResource();
    }
}

// MARK: - BBLocalAVPlayerViewDelegate(视频播放回到)
extension BBEditMicroVideoController : BBLocalAVPlayerViewDelegate
{
    func bbLocalAVPlayerViewDidPlayFailed() {
        self.view.alert("无效视频，无法播放", type: .kAVTFailed);
    }
}

// MARK: - BBAudioPlayerDelegate(声音播放回调)
extension BBEditMicroVideoController : BBAudioPlayerDelegate
{
    func bbAudioPlayerFailed() {
        self.view.alert("声音资源无效，无法播放", type: .kAVTFailed);
    }
}

// MARK: - BBEditAudioControlViewDelegate(音量控制回调)
extension BBEditMicroVideoController : BBEditAudioControlViewDelegate
{
    func editAudioControlView(videoAudioVolumn: Float, didValueChanged mixAudioVolumn: Float) {
        self.playerView.volume = videoAudioVolumn;
        self.audioPlayer?.volume = mixAudioVolumn;
    }
}
