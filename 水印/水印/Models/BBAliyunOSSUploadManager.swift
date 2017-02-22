//
//  BBAliyunOSSUploadManager.swift
//  BoBo
//
//  Created by alimysoyang on 16/10/21.
//  Copyright © 2016年 bobo. All rights reserved.
//

import Foundation


/// 阿里云文件上传管理
class BBAliyunOSSUploadManager: NSObject 
{
    // MARK: - properties
    fileprivate let endPointValue:String = "http://oss-cn-beijing.aliyuncs.com";
    fileprivate let videoBucketName = "bobo-sql";
    fileprivate let remotePartUrlPath:String = "http://upload.guaishoubobo.com";
    
    fileprivate lazy var credential:OSSPlainTextAKSKPairCredentialProvider = OSSPlainTextAKSKPairCredentialProvider(plainTextAccessKey: BBHelper.kAliyunOSSKeyId, secretKey: BBHelper.kAliyunOSSKeySecret);
    fileprivate lazy var conf:OSSClientConfiguration = {
        let conf:OSSClientConfiguration = OSSClientConfiguration();
        conf.maxRetryCount = 3; // 网络请求遇到异常失败后的重试次数
        conf.timeoutIntervalForRequest = 60; // 网络请求的超时时间
        return conf;
    }();
    
    fileprivate lazy var client:OSSClient = OSSClient(endpoint: self.endPointValue, credentialProvider: self.credential, clientConfiguration: self.conf);

    // MARK: - life cycle
    override init()
    {
		super.init();
    }
	
    deinit
    {
	
    }

    // MARK: - public methods
    internal func uploadVideo(videoFilePath:String?, videoThumbnailFilePath:String?, uploadProgress:@escaping progressClosure, success:@escaping videoMergeCompletionClosure, failure:@escaping descriptionClosure)
    {
        if let vFilePath:String = videoFilePath, (!vFilePath.trim().isEmpty)
        {
            var progressCoe:CGFloat = 1.0;
            if let thumbnailFilePath:String = videoThumbnailFilePath, (!thumbnailFilePath.trim().isEmpty)
            {
                progressCoe = 0.8;
            }
            
            var currentProgress:CGFloat = 0.0;
            self.fileUpload(filePath: vFilePath, uploadProgress: { (progress:CGFloat) in
                currentProgress += (progressCoe * progress);
                uploadProgress(currentProgress);
                }, success: { [weak self] (remoteFilePath:String) in
                    if let strongSelf = self
                    {
                        if (progressCoe < 1.0)
                        {
                            let otherProgressCoe:CGFloat = 0.2;
                            strongSelf.fileUpload(filePath: videoThumbnailFilePath!, uploadProgress: { (progress:CGFloat) in
                                currentProgress += (otherProgressCoe * progress);
                                uploadProgress(currentProgress);
                                }, success: { (remoteThumbnailFilePath:String) in
                                    success(remoteFilePath, remoteThumbnailFilePath);
                                }, failure: { (description:String) in
                                    success(remoteFilePath, nil);
                            })
                        }
                        else
                        {
                            success(remoteFilePath, nil);
                        }
                    }
                }, failure: { (description:String) in
                    failure(description);
            })
        }
        else
        {
            failure("本地视频文件错误，无法上传");
        }
    }
    
    // MARK: - event response

    // MARK: - private methods
    fileprivate func objectKeyName(filePath:String) -> String
    {
        #if DEBUG
            return "cs\(BBLoginManager.shardInstance.uId)/\(filePath.lastPathComponent())";
        #else
            return "\(BBLoginManager.shardInstance.uId)/\(filePath.lastPathComponent())";
        #endif
        
    }
    
    fileprivate func remoteUrlPath(objectKey:String) -> String
    {
        return "\(self.remotePartUrlPath)/\(objectKey)";
    }
    
    fileprivate func fileUpload(filePath:String, uploadProgress:@escaping progressClosure, success:@escaping descriptionClosure, failure:@escaping descriptionClosure)
    {
        let putRequest:OSSPutObjectRequest = OSSPutObjectRequest();
        putRequest.bucketName = self.videoBucketName;
        putRequest.objectKey = self.objectKeyName(filePath: filePath);
        if (filePath.hasSuffix(".mp4"))
        {
            putRequest.contentType = "video/mp4";
        }
        putRequest.uploadingFileURL = URL(fileURLWithPath: filePath);
        putRequest.uploadProgress = ({ (bytesSent:Int64, totalBytesSent:Int64, totalBytesExpectedToSend:Int64) in          
            uploadProgress(CGFloat(bytesSent) / CGFloat(totalBytesExpectedToSend));
        })
        
        let putTask:OSSTask = self.client.putObject(putRequest);
        putTask.osscontinue { (task:OSSTask<AnyObject>) -> Any? in
            if let err:Error = task.error
            {
                failure(((err as NSError).userInfo[AnyHashable("ErrorMessage")] as? String) ?? "文件上传失败");
            }
            else
            {
                success(self.remoteUrlPath(objectKey: putRequest.objectKey));
            }
            UIApplication.dLog("上传结束");
            return nil;
        }
    }
    
}
