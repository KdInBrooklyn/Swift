//
//  BBEditResource.swift
//  BoBo
//
//  Created by alimysoyang on 16/12/13.
//  Copyright © 2016年 bobo. All rights reserved.
//

import Foundation

// 短视频编辑中可供编辑的资源对象
class BBEditResource:NSObject
{
    // MARK: - properties
    var resourceId:Int = -1;                                                //资源编号
    var resourceType:BBEditMicroVideoType = .animation;    //资源类型
//    var resourceGroupName:String?;                                  //分组名
    var resourceTitleImage:String?;                                     //资源展示图片
    var resourceName:String?;                                           //资源名称
    var resourceUrlPath:String?;                                         //资源下载地址
    var resourceLocalPath:String?                                       //资源本地地址(相对路径非完整路径)
    var isDownLoading:Bool = false;                                   //准备下载
    var isSelected:Bool = false;                                           //被选中
    
    var isDownloaded:Bool {
        get {
            if (!self.fullocalPath.trim().isEmpty)//let localPath:String = self.resourceLocalPath, (!localPath.trim().isEmpty)
            {
                let fm:FileManager = FileManager();
                return fm.fileExists(atPath: self.fullocalPath);
            }
            return false;
        }
    }
    
    //完整路径
    var fullocalPath:String {
        get {
            if let value:String = self.resourceLocalPath, (!value.trim().isEmpty)
            {
                return BBHelper.kAppFilePath + value;
            }
            return "";
        }
    }
    
    //保存到数据库中的相对路径
    var localPath:String {
        get {
            if let value:String = self.resourceLocalPath, (!value.trim().isEmpty)
            {
                return value;
            }
            return "";
        }
    }
    
    var downLoadUrlPath:String {
        get {
            if let urlPath:String = self.resourceUrlPath, let encodePath = urlPath.urlQueryEncodingAllowed()
            {
                return encodePath;
            }
            return "";
        }
    }
//    
//    var groupName:String {
//        get {
//            if let value:String = self.resourceGroupName, (!value.trim().isEmpty)
//            {
//                return value;
//            }
//            return "未知分组";
//        }
//    }
    
    var titleImageUrlPath:String {
        get {
            if let urlPath:String = self.resourceTitleImage, let encodePath = urlPath.urlQueryEncodingAllowed()
            {
                return encodePath;
            }
            return "";
        }
    }
    
//    fileprivate var downloadLocalPath:String {
//        get {
//            if self.resourceType == .animation
//            {
//                return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path + "/\(BBLoginManager.shardInstance.uId)/VideoResource/GIF/";
//            }
//            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path + "/\(BBLoginManager.shardInstance.uId)/VideoResource/Music/";
//        }
//    }
    
    fileprivate var localPartPath:String {
        get {
            if self.resourceType == .animation
            {
                return "/\(BBLoginManager.shardInstance.uId)/VideoResource/GIF/";
            }
            return "/\(BBLoginManager.shardInstance.uId)/VideoResource/Music/";
        }
    }
    
    fileprivate var localNewFileName:String? {
        get {
            if let urlPath:String = self.resourceUrlPath
            {
                let lastName:String = (urlPath as NSString).lastPathComponent;
                if let retVal:String = urlPath.md5String()
                {
                    return retVal + "_" + lastName;
                }
                else
                {
                    return "\(self.resourceId)_" + lastName;
                }
            }
            return nil;
        }
    }
    
    // MARK: - life cycle
    override init()
    {
        super.init();
    }
    
    init(data:JSON, type:BBEditMicroVideoType)
    {
        super.init();
        
        self.resourceId = data["id"].intValue;
        self.resourceType = type;
//        self.resourceGroupName = data["group_name"].string;
        self.resourceTitleImage = data["pic"].string;
        self.resourceName = data["title"].string;
        self.resourceUrlPath = data["url"].string;
    }
    
    deinit
    {
        
    }
    
    // MARK: - public methods
    internal func moveDownloadFile(sourceFilePath:String) -> Bool
    {
        if let lastName:String = self.localNewFileName, (self.createDir(dirPath: BBHelper.kAppFilePath + self.localPartPath))
        {
            var fm:FileManager? = FileManager();
            do
            {
                let partFilePath:String = self.localPartPath + lastName;
                let newFilePath:String = BBHelper.kAppFilePath + partFilePath;
                try fm?.moveItem(atPath: sourceFilePath, toPath: newFilePath);
                fm = nil;
                self.resourceLocalPath = partFilePath;
            }catch
            {
                fm = nil;
                return false;
            }
            return true;
        }
        return false;
    }
    
    internal func resourceDownloadFile(progress:@escaping progressClosure, success:@escaping emptyClosure, failure: @escaping descriptionClosure)
    {
        if (!self.downLoadUrlPath.trim().isEmpty)
        {
            BBNetworking.shardInstance.downloadFile(self.downLoadUrlPath, progress: { (progressValue:CGFloat) in
                progress(progressValue);
            }, success: { (downloadFilePath:String) in
                if self.moveDownloadFile(sourceFilePath: downloadFilePath)
                {
                    BBLocalDBManager.sharedInstance.saveEditLocalResource(self);
                    success();
                }
                else
                {
                    failure("文件下载失败");
                }
            }, failure: { (description:String) in
                failure(description);
            });
        }
    }
    // MARK: - event response

    // MARK: - private methods
    fileprivate func createDir(dirPath:String) -> Bool
    {
        var fm:FileManager? = FileManager();
        do
        {
            try fm?.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil);
            fm = nil;
        }catch {
            fm = nil;
            return false;
        }
        return true;
    }
    
   
}
