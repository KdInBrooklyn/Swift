//
//  BBEditLocalResource.swift
//  BoBo
//
//  Created by alimysoyang on 16/12/14.
//  Copyright © 2016年 bobo. All rights reserved.
//

import Foundation

// 本地已保存的视频编辑资源
class BBEditLocalResource: NSObject 
{
    // MARK: - properties
    var resourceId:Int = -1;                                                //资源编号
    var resourceType:BBEditMicroVideoType = .animation;    //资源类型
    var resourceLocalPath:String?                                       //资源本地地址

    // MARK: - life cycle
    override init()
    {
		super.init();
    }
	
    init(data:SD.SDRow)
    {
        super.init();
        
        self.resourceId = (data["resourceId"]?.asInt() ?? -1);
        if let value:Int = data["type"]?.asInt(), let type:BBEditMicroVideoType = BBEditMicroVideoType(rawValue: value)
        {
            self.resourceType = type;
        }
        self.resourceLocalPath = data["localpath"]?.asString();
    }
    
    deinit
    {
	
    }

    // MARK: - public methods

    // MARK: - event response

    // MARK: - private methods

}
