//
//  BBLocalAVPlayerView.swift
//  BoBo
//
//  Created by alimysoyang on 16/12/15.
//  Copyright © 2016年 bobo. All rights reserved.
//

import Foundation

@objc protocol BBLocalAVPlayerViewDelegate
{
    func bbLocalAVPlayerViewDidPlayFailed();
}

// 播放本地编辑的视频界面
class BBLocalAVPlayerView: UIView 
{
    // MARK: - properties
    weak var delegate:BBLocalAVPlayerViewDelegate?;
    var gifLayer:GifAnimationLayer?{
        didSet {
            if let oldLayer:GifAnimationLayer = oldValue
            {
                oldLayer.stopAnimating();
                oldLayer.removeFromSuperlayer();
            }
            if let layer:GifAnimationLayer = gifLayer
            {
                layer.frame = CGRect(origin: .zero, size: self.frame.size);
                self.layer.addSublayer(layer);
                layer.startAnimating();
            }
        }
    }
    
    var volume:Float = 1.0 {
        didSet
        {
            self.videoPlayer?.volume = volume;
        }
    }
    
    fileprivate var playerState:BBAVPlayerState = .finished;
    fileprivate var videoPath:String?;
    fileprivate var videoPlayerItem:AVPlayerItem?;
    fileprivate var videoPlayer:AVPlayer?;
    fileprivate var videoPlayerLayer:AVPlayerLayer?;
    
    fileprivate lazy var btnStart:UIButton = { [unowned self] in
        let button:UIButton = UIButton(frame: CGRect(x: 0.0, y:0.0, width: self.frame.size.width, height:self.frame.size.height));
        button.setImage(UIImage(named:"videoplay"), for: .normal);
        button.alpha = 0.0;
        button.addTarget(self, action: #selector(BBLocalAVPlayerView.eventButtonClicked(_:)), for: .touchUpInside);
        return button;
    }();
    
//    fileprivate lazy var gifView:YLImageView = { [unowned self] in
//        let view:YLImageView = YLImageView(frame: CGRect(x: 0.0, y:0.0, width: self.frame.size.width, height:self.frame.size.height));
//        view.isUserInteractionEnabled = true;
//        view.isHidden = true;
//        return view;
//        }();
    
//    fileprivate lazy var gifView:UIImageView = { [unowned self] in
//        let view:UIImageView = UIImageView(frame: CGRect(x: 0.0, y:0.0, width: self.frame.size.width, height:self.frame.size.height));
//        view.isUserInteractionEnabled = true;
//        view.isHidden = true;
//        return view;
//    }();
    
    // MARK: - life cycle
    init(frame: CGRect, localVideoPath:String?) {
        super.init(frame: frame);
        self.videoPath = localVideoPath;
        self.initViews();
    }
    
    override init(frame:CGRect)
    {
		super.init(frame:frame);
    }
	
    required init?(coder aDecoder:NSCoder)
    {
		super.init(coder:aDecoder);
    }

    deinit
    {
        self.removeAll();
        self.delegate = nil;
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event);
        if (self.playerState == .playing)
        {
            self.pause();
        }
    }
    
    /// AVPlayerItem属性监视
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let playerItem = object as? AVPlayerItem, let key = keyPath
        {
            if (key == "status")
            {
                switch (playerItem.status)
                {
                case .unknown, .failed:
                    self.playerState = .failed;
                    self.playerFailed();
                case .readyToPlay:
                    self.playerState = .playing;
                    self.videoPlayer?.play();
                }
            }
        }
    }
    
    // MARK: - public methods
    internal func start()
    {
        if let path:String = self.videoPath, (!path.trim().isEmpty)
        {
            self.initPlayer(path: path);
            NotificationCenter.default.addObserver(self, selector: #selector(BBLocalAVPlayerView.eventVideoPlayerDidEndNotification(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.videoPlayerItem);
        }
        else
        {
            self.playerFailed();
        }
    }
    
    internal func pause()
    {
        self.btnStart.alpha = 1.0;
        self.playerState = .paused;
        self.videoPlayer?.pause();
    }
    
    internal func resume()
    {
        self.btnStart.alpha = 0.0;
        self.playerState = .playing;
        self.videoPlayer?.play();
    }
    
    internal func videoComposition()
    {
        self.playerState = .paused;
        self.videoPlayer?.pause();
        self.gifLayer?.pauseAnimating();
//        self.gifView.stopAnimating();
    }
    
    internal func removeAll()
    {
        NotificationCenter.default.removeObserver(self);
        if let _ = self.videoPlayerItem
        {
            self.videoPlayerItem?.cancelPendingSeeks();
            self.videoPlayerItem?.asset.cancelLoading();
            self.videoPlayerItem?.removeObserver(self, forKeyPath: "status");
        }
        self.videoPlayer?.pause();
        self.videoPlayerLayer?.removeFromSuperlayer();
        self.videoPlayerItem = nil;
        self.videoPlayerLayer = nil;
        self.videoPlayer = nil;
        if let _ = self.gifLayer
        {
            self.gifLayer?.stopAnimating();
            self.gifLayer?.removeFromSuperlayer();
            self.gifLayer = nil;
        }
    }
    
//    internal func loadGif(localFilePath:String, completion:@escaping emptyClosure)
//    {
//        do
//        {
//            self.gifView.isHidden = false;
//            self.bringSubview(toFront: self.gifView);
//            let gifData:Data = try Data(contentsOf: URL(fileURLWithPath: localFilePath));
//            self.gifView.image = YLGIFImage(data: gifData);
//            completion();
////            self.gifView.loadGif(data: gifData, completion:{
////                completion();
////            });
//        }catch
//        {
//            self.emptyGif();
//        }
//        
//    }
//    
//    internal func emptyGif()
//    {
//        self.gifView.image = nil;
//        self.gifView.isHidden = true;
//    }
    
    // MARK: - event response
    internal func eventButtonClicked(_ sender:UIButton)
    {
        if (self.playerState == .finished || self.playerState == .failed)
        {
            self.start();
        }
        else if (self.playerState == .paused)
        {
            self.resume();
        }
    }
    
    /// 播放视频结束通知
    internal func eventVideoPlayerDidEndNotification(_ notification:Notification)
    {
        self.videoPlayer?.seek(to: kCMTimeZero, completionHandler: { [weak self](finished:Bool) in
            if let strongSelf = self
            {
                strongSelf.videoPlayer?.play();
            }
        })
    }
    
    // MARK: - private methods
    fileprivate func initViews()
    {
        self.backgroundColor = UIColor.clear;
        self.addSubview(self.btnStart);
//        self.addSubview(self.gifView);
    }
    
    fileprivate func initPlayer(path:String)
    {
        self.videoPlayerItem = AVPlayerItem(url: URL(fileURLWithPath: path));
        //视频状态
        self.videoPlayerItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil);
        self.videoPlayer = AVPlayer(playerItem: self.videoPlayerItem!);
        self.videoPlayerLayer = AVPlayerLayer(player:self.videoPlayer);
        self.videoPlayerLayer?.backgroundColor = UIColor.black.cgColor;
        self.videoPlayerLayer?.videoGravity = AVLayerVideoGravityResizeAspect;
        self.videoPlayerLayer?.frame = CGRect(x:0.0, y:0.0, width:self.frame.size.width, height:self.frame.size.height);
        self.layer.addSublayer(self.videoPlayerLayer!);
        self.bringSubview(toFront: self.btnStart);
//        self.bringSubview(toFront: self.gifView);
    }
    
    fileprivate func playerFailed()
    {
        self.btnStart.alpha = 1.0;
        guard let _ = self.delegate?.bbLocalAVPlayerViewDidPlayFailed() else
        {
            return;
        }
    }
    
    
}
