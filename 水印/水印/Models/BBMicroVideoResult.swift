//
//  BBMicroVideoResult.swift
//  BoBo
//
//  Created by alimysoyang on 16/10/19.
//  Copyright © 2016年 bobo. All rights reserved.
//

import Foundation

//视频结果对象
class BBMicroVideoResult: NSObject 
{
    // MARK: - properties
    var step:BBMicroCompositeVideoStep = .merge;
    var videoFilePath:String?;
    var videoThumbnailFilePath:String?;

    // MARK: - life cycle
    override init()
    {
		super.init();
    }
	
    deinit
    {
	
    }

    // MARK: - public methods
    internal func reset()
    {
        if (self.step != .merge)
        {
            self.step = .merge;
            self.videoFilePath = nil;
            self.videoThumbnailFilePath = nil;
        }
    }
    // MARK: - event response

    // MARK: - private methods

}
