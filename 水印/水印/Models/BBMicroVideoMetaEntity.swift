//
//  BBMicroVideoMetaEntity.swift
//  BoBo
//
//  Created by alimysoyang on 16/10/18.
//  Copyright © 2016年 bobo. All rights reserved.
//

import Foundation

//编辑视频的文字和静态图片
class BBMicroVideoMetaEntity: NSObject 
{
    // MARK: - properties
    fileprivate (set) var type:BBMicroVideoMetaType = .none;          //类型
    fileprivate (set) var metaView:UIImage?;
    fileprivate (set) var rect:CGRect = .zero;                                  //尺寸
    var degress:CGFloat = -1;                                                       //角度
    var startTime:TimeInterval = 0.0;                                             //开始时间
    var endTime:TimeInterval = 0.0;                                              //结束时间
    fileprivate let scale:CGFloat = BBHelper.outVideoSize.width / UIView.kScreenWidth;       //缩放比例
    
    // MARK: - life cycle
    init(metaType:BBMicroVideoMetaType, sourceView:UIView)
    {
		super.init();
        
        self.type = metaType;
        if (self.type == .text)
        {
            self.metaView = UIImage.imageWithScaleView(sourceView, scale: self.scale);
        }
        else if (self.type == .image)
        {
            if let view:UIImageView = sourceView as? UIImageView
            {
                self.metaView = view.image?.scaleImage(scale: self.scale);
            }
        }
        
        self.rect = CGRect(x: self.scale * sourceView.frame.origin.x, y: BBHelper.outVideoSize.height - (sourceView.frame.origin.y + sourceView.frame.size.height) * self.scale, width: sourceView.frame.size.width * self.scale, height: sourceView.frame.size.height * self.scale);
    }
	
    deinit
    {
	
    }

    // MARK: - public methods

    // MARK: - event response

    // MARK: - private methods

}
