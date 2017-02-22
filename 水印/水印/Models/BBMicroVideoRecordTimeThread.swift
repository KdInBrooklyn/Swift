//
//  BBMicroVideoRecordTimeThread.swift
//  BoBo
//
//  Created by alimysoyang on 16/10/10.
//  Copyright © 2016年 bobo. All rights reserved.
//

import Foundation

@objc protocol BBMicroVideoRecordTimeThreadDelegate
{
    func microVideoRecordTimeDidPaused(newPartTimeValue:TimeInterval);
    func microVideoRecordTimeDidUpdateTime(newTimeValue:TimeInterval);
}

class BBMicroVideoRecordTimeThread: NSObject 
{
    // MARK: - properties
    weak var delegate:BBMicroVideoRecordTimeThreadDelegate?;
    var state:BBThreadState = .stopped;
    
    fileprivate var isRunning:Bool = false;
    fileprivate var queue:DispatchQueue?;
    fileprivate let sleepTime:TimeInterval = 0.1;
    fileprivate var useTime:TimeInterval = 0.0;
    fileprivate var partUseTime:TimeInterval = 0.0;
    
    fileprivate var displayLink:CADisplayLink?;
    
    // MARK: - life cycle
    override init()
    {
		super.init();
    }
	
    deinit
    {
        self.delegate = nil;
    }

    // MARK: - public methods
    internal func start()
    {
        self.state = .running;
        self.createDisplayLink();
    }
    
    internal func stop()
    {
        self.freeDisplayLink();
        self.state = .stopped;
        self.useTime = 0.0;
        self.partUseTime = 0.0;
    }
    
    internal func pause()
    {
        self.freeDisplayLink();
        self.state = .suspend;
        DispatchQueue.main.async(execute: { [weak self] in
            if let strongSelf = self
            {
                guard let _ = strongSelf.delegate?.microVideoRecordTimeDidPaused(newPartTimeValue: strongSelf.partUseTime) else
                {
                    return;
                }
            }
        })
    }
    
    internal func resume()
    {
        self.partUseTime = 0.0;
        self.state = .running;
        self.createDisplayLink();
    }
    
    internal func deleteUseTime(deleteVideoDuration:TimeInterval)
    {
        self.useTime -= deleteVideoDuration;
        if (self.useTime <= 0)
        {
            self.useTime = 0.0;
        }
    }
    // MARK: - event response

    // MARK: - private methods
    fileprivate func createDisplayLink()
    {
        if (self.displayLink == nil)
        {
            self.displayLink = CADisplayLink(target: self, selector: #selector(BBMicroVideoRecordTimeThread.runLink(_:)));
            self.displayLink?.frameInterval = 6;
            self.displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes);
        }
    }
    
    fileprivate func freeDisplayLink()
    {
        if let _ = self.displayLink
        {
            self.displayLink?.invalidate();
            self.displayLink = nil;
        }
    }
    
    internal func runLink(_ sender:CADisplayLink)
    {
        self.useTime += self.sleepTime;
        self.partUseTime += self.sleepTime;
        UIApplication.dLog(self.useTime);
        DispatchQueue.main.async(execute: { [weak self] in
            if let strongSelf = self
            {
                guard let _ = strongSelf.delegate?.microVideoRecordTimeDidUpdateTime(newTimeValue: strongSelf.useTime) else
                {
                    return;
                }
            }
        })
    }
}
