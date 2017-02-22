//
//  BBMicroVideoResourceMetas.swift
//  BoBo
//
//  Created by alimysoyang on 16/12/20.
//  Copyright © 2016年 bobo. All rights reserved.
//

import Foundation

// 短视频资源编辑最后需要的数据对象
struct BBMicroVideoResourceMetas
{
    // MARK: - properties
    var gifPath:String?;                                //动画资源的地址
    var musicPath:String?;                          //混音资源的地址
    var sourceVolumn:Float = 0.0;               //原音的大小
    var mixVolumn:Float = 1.0;                  //混音的大小
    
    var isEmpty:Bool {
        get {
            var tmp1:Bool = true;
            var tmp2:Bool = true;
            if let value1:String = self.gifPath, (!value1.trim().isEmpty)
            {
                tmp1 = false;
            }
            
            if let value2:String = self.musicPath, (!value2.trim().isEmpty)
            {
                tmp2 = false;
            }
            
            return (tmp1 && tmp2);
        }
    }
    
    var gifLayer:GifAnimationLayer? {
        get {
            if let value:String = self.gifPath, (!value.trim().isEmpty)
            {
                let layer:GifAnimationLayer = GifAnimationLayer(gifFilePath: value);
                layer.frame = CGRect(origin: CGPoint.zero, size: BBHelper.outVideoSize);
                layer.speed = Float(layer.totalDuration);//30.0 / Float(layer.totalDuration);
                return layer;
            }
            return nil;
        }
    }
    
    var mixAsset:AVAsset? {
        get {
            if let value:String = self.musicPath, (!value.trim().isEmpty)
            {
                let asset:AVAsset = AVAsset(url: URL(fileURLWithPath: value));
                return asset;
            }
            return nil;
        }
    }

    // MARK: - life cycle

    // MARK: - public methods

    // MARK: - event response

    // MARK: - private methods

}
