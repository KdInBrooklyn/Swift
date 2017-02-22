//
//  BBMicroPartVideoEntity.swift
//  BoBo
//
//  Created by alimysoyang on 16/10/9.
//  Copyright © 2016年 bobo. All rights reserved.
//

import Foundation

/// 录制视频时的临时视频对象
class BBMicroPartVideoEntity: NSObject
{
    // MARK: - properties
    var videoPath:String?;                                      //文件路径
    var videoDuration:TimeInterval = 0.0;              //视频时长
    var maxVideoDuration:TimeInterval = 120.0;    //最大时长，可设置
    
    var videoProgressPartValue:Float {                   //当前视频占总时长的百分比
        get {
            return Float(videoDuration / maxVideoDuration);
        }
    }
    
    var isValidData:Bool {
        get {
            if let path:String = videoPath, (!path.trim().isEmpty && videoDuration > 0)
            {
                return true;
            }
            return false;
        }
    }
    
    // MARK: - life cycle
    override init()
    {
		super.init();
    }
	
    deinit
    {
	
    }

    // MARK: - public methods

    // MARK: - event response

    // MARK: - private methods

}
