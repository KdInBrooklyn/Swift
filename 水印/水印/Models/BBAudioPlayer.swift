//
//  BBAudioPlayer.swift
//  BoBo
//
//  Created by alimysoyang on 16/12/15.
//  Copyright © 2016年 bobo. All rights reserved.
//

import Foundation
//import AVFoundation

@objc protocol BBAudioPlayerDelegate
{
    func bbAudioPlayerFailed();
}

// <#Description#>
class BBAudioPlayer: NSObject 
{
    // MARK: - properties
    weak var delegate:BBAudioPlayerDelegate?;
    
    var volume:Float = 1.0 {
        didSet
        {
            self.audioPlayer?.volume = volume;
        }
    }
    
    fileprivate var audioPlayer:AVAudioPlayer?;
    fileprivate var playerState:BBAVPlayerState = .finished;

    // MARK: - life cycle
    init(localFilePath:String, loopNumber:Int = -1)
    {
        super.init();
        
        self.initLocal(filePath: localFilePath, loopNumber: loopNumber);
    }
    
    init(remoteFilePath:String, loopNumber:Int = -1)
    {
        super.init();
        
        self.initRemote(filePath: remoteFilePath, loopNumber: loopNumber);
    }
    
    override init()
    {
		super.init();
    }
	
    deinit
    {
        self.audioPlayer?.stop();
        self.audioPlayer?.delegate = nil;
        self.audioPlayer = nil;
        self.delegate = nil;
    }

    // MARK: - public methods
    internal func pause()
    {
        if (self.playerState == .playing)
        {
            self.audioPlayer?.pause();
        }
    }
    
    internal func resume()
    {
        if (self.playerState == .paused)
        {
            self.audioPlayer?.play();
        }
    }
    
    internal func stop()
    {
        self.audioPlayer?.stop();
    }
    
    // MARK: - event response
    internal func eventEnterBackgroundNotification(_ notification:Notification)
    {
        self.pause();
    }
    
    internal func eventEnterForegroundNotification(_ notification:Notification)
    {
        self.resume();
    }
    
    // MARK: - private methods
    fileprivate func initLocal(filePath:String, loopNumber:Int)
    {
        do
        {
            try self.audioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath));
            if (!self.prepare(loopNumber: loopNumber))
            {
                self.failed();
            }
            else
            {
                self.playerState = .playing;
            }
        }
        catch
        {
            self.failed();
        }

    }
    
    fileprivate func initRemote(filePath:String, loopNumber:Int)
    {
        if let urlPath:URL = URL(string: filePath)
        {
            do
            {
                try self.audioPlayer = AVAudioPlayer(contentsOf: urlPath);
                if (!self.prepare(loopNumber: loopNumber))
                {
                    self.failed();
                }
                else
                {
                    self.playerState = .playing;
                }
            }
            catch
            {
                self.failed();
            }
        }
    }
    
    fileprivate func prepare(loopNumber:Int = -1) -> Bool
    {
        self.audioPlayer?.numberOfLoops = loopNumber;
        self.audioPlayer?.volume = 1.0;
        self.audioPlayer?.delegate = self;
        if let retVal:Bool = self.audioPlayer?.prepareToPlay()
        {
            if (retVal)
            {
                self.audioPlayer?.play();
            }
            return retVal;
        }
        return false;
    }
    
    fileprivate func failed()
    {
        self.playerState = .failed;
        self.audioPlayer?.stop();
        self.audioPlayer?.delegate = nil;
        guard let _ = self.delegate?.bbAudioPlayerFailed() else {
            return;
        }
    }
}

extension BBAudioPlayer : AVAudioPlayerDelegate
{
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        self.failed();
    }
}
