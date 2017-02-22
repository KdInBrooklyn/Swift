//
//  BBMicroPartVideoManager.swift
//  BoBo
//
//  Created by alimysoyang on 16/10/9.
//  Copyright © 2016年 bobo. All rights reserved.
//

import Foundation

@objc protocol BBMicroPartVideoManagerDelegate
{
    @objc optional func microVideoRecordDidUpdateTime(newTimeValue:TimeInterval);
    @objc optional func microPartVideoRemoveLast(newVideoDuration:TimeInterval, deleteVideoDuration:TimeInterval);
}

class BBMicroPartVideoManager: NSObject 
{
    // MARK: - properties
    weak var delegate:BBMicroPartVideoManagerDelegate?;
    
    var tmpVideoFileCount:Int = 0;
    var tmpVideoFilePath:String {
        get {
            return "\(BBHelper.tmpVideoPath)/\(self.tmpVideoFileCount).mov";
        }
    }
    
    var newOneVideoDuration:TimeInterval {
        get {
            if let partVideo:BBMicroPartVideoEntity = self.newMicroPartVideo, let filePath:String = partVideo.videoPath
            {
                let fm:FileManager = FileManager();
                if (fm.fileExists(atPath: filePath))
                {
                    return 0.0;
                }
                return partVideo.videoDuration;
            }
            return 0.0;
        }
    }
    
    var videoRecordTimeThread:BBMicroVideoRecordTimeThread = BBMicroVideoRecordTimeThread();
    
    fileprivate var multiPartValue:[BBMicroPartVideoEntity] = [BBMicroPartVideoEntity]();
    fileprivate var newMicroPartVideo:BBMicroPartVideoEntity?;
    fileprivate var exportSession:AVAssetExportSession?;
    fileprivate var isExportRunning:Bool = false;
    
    // MARK: - life cycle
    override init()
    {
		super.init();
        self.videoRecordTimeThread.delegate = self;
    }
	
    deinit
    {
        self.removeAll();
        self.delegate = nil;
    }

    // MARK: - public methods
    internal func addMicroPartVideo()
    {
        if let partVideo:BBMicroPartVideoEntity = self.newMicroPartVideo, (partVideo.isValidData)
        {
            self.tmpVideoFileCount += 1;
            self.multiPartValue.append(partVideo);
        }
    }
    
    internal func removeLastMicroPartVideo()
    {
        let delete:TimeInterval = self.removeTheLastOne();
        let total:TimeInterval = self.totalVideoDuration();
        self.videoRecordTimeThread.deleteUseTime(deleteVideoDuration: delete);
        if let closure = self.delegate?.microPartVideoRemoveLast
        {
            closure(total, delete);
        }
    }
    
    internal func removeAll()
    {
        String.removeFiles(BBHelper.kAppTmpFilePath);
        self.tmpVideoFileCount = 0;
        self.newMicroPartVideo = nil;
        self.multiPartValue.removeAll();
        self.videoRecordTimeThread.stop();
    }
    
    internal func clearNewPartVideo()
    {
        self.newMicroPartVideo = nil;
    }
    
    internal func cancelExport() -> Bool
    {
        if let session:AVAssetExportSession = self.exportSession, (self.isExportRunning)
        {
            session.cancelExport();
            self.isExportRunning = false;
            return true;
        }
        return false;
    }
    
    // MARK: - 路径控制
    internal func createTempVideoDir() -> (Bool, String)
    {
        String.removeFiles(BBHelper.tmpVideoPath);
        var fm:FileManager? = FileManager();
        do
        {
            try fm?.createDirectory(atPath: BBHelper.tmpVideoPath, withIntermediateDirectories: true, attributes: nil);
            fm = nil;
            return (true, "");
        }catch {
            fm = nil;
            return (false, "临时文件夹创建失败，无法进行视频录制");
        }
    }
    
    internal func createNewMicroPartVideo(maxTimeValue:TimeInterval, videoFilePath:String?)
    {
        self.newMicroPartVideo = BBMicroPartVideoEntity();
        self.newMicroPartVideo?.maxVideoDuration = maxTimeValue;
        if let filePath:String = videoFilePath
        {
            self.newMicroPartVideo?.videoPath = filePath;
        }
        else
        {
            self.newMicroPartVideo?.videoPath = self.tmpVideoFilePath;
        }
    }
    
    internal func importVideoDuration(videoDuration:TimeInterval)
    {
        self.newMicroPartVideo?.videoDuration = videoDuration;
    }
    
    // MARK: -视频合成，水印处理
    internal func mergeVideos(progress: @escaping exportProgressClosure, completion: @escaping videoMergeCompletionClosure, failed: @escaping descriptionClosure)
    {
        if (self.multiPartValue.count == 0)
        {
            failed("无效视频");
            return;
        }
        let lastVideoFilePath:String = BBHelper.lastVideoPath();//"\(self.tmpVideoPath)/tmplast.mp4";
        String.removeFiles(lastVideoFilePath);
        let fm:FileManager = FileManager();
        
        let mixComposition:AVMutableComposition = AVMutableComposition();
        let compositionVideo:AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid);
        let compositionAudio:AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid);
        
        var timeOffset:CMTime = kCMTimeZero;
        var layerInstructions:[AVMutableVideoCompositionLayerInstruction] = [AVMutableVideoCompositionLayerInstruction]();
        for index in 0..<self.multiPartValue.count
        {
            let partVideo:BBMicroPartVideoEntity = self.multiPartValue[index];
            if let videoPath:String = partVideo.videoPath
            {
                if (fm.fileExists(atPath: videoPath))
                {
                    let asset:AVAsset = AVAsset(url: URL(fileURLWithPath: videoPath));
                    //获取视频真实的时长
                    let realDuration:CMTime = CMTime(value: asset.duration.value, timescale: asset.duration.timescale);
                    //视频数据
                    let videoTracks:[AVAssetTrack] = asset.tracks(withMediaType: AVMediaTypeVideo);
                    if (videoTracks.count == 0)
                    {
                        continue;
                    }
                    let assetVideoTrack:AVAssetTrack = videoTracks[0];
                    do
                    {
                        try compositionVideo.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: asset.duration), of: assetVideoTrack, at: timeOffset);
                        compositionVideo.scaleTimeRange(CMTimeRange(start: timeOffset, duration: asset.duration), toDuration: realDuration);
                    }
                    catch {
                        continue;
                    }
                    //音频数据
                    let audioTracks:[AVAssetTrack] = asset.tracks(withMediaType: AVMediaTypeAudio);
                    if (audioTracks.count == 0)
                    {
                        continue;
                    }
                    do
                    {
                        try compositionAudio.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: asset.duration), of: audioTracks[0], at: timeOffset);
                        compositionAudio.scaleTimeRange(CMTimeRange(start: timeOffset, duration: asset.duration), toDuration: realDuration);
                    }
                    catch{
                        continue;
                    }
                    
                    //视频修改尺寸和方向
                    let ratio:CGFloat = BBHelper.outVideoSize.width / assetVideoTrack.naturalSize.height;
                    let offSetY:Double = Double(assetVideoTrack.naturalSize.width * ratio - BBHelper.outVideoSize.height);
                    let layerInstruction:AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideo);
                    //缩放
                    let scaleTransform:CGAffineTransform = CGAffineTransform(scaleX: ratio, y: ratio);
                    //平移
                    let translationTransform:CGAffineTransform = CGAffineTransform(translationX: 0.0, y: CGFloat(-ceil(offSetY) / 2.0));
                    let transform:CGAffineTransform = assetVideoTrack.preferredTransform.concatenating(scaleTransform).concatenating(translationTransform);
                    layerInstruction.setTransform(transform, at: timeOffset);
                    layerInstructions.append(layerInstruction);
                    timeOffset = CMTimeAdd(timeOffset, realDuration);
                }
            }
        }
        
        self.exportLastVideo(lastVideoFilePath: lastVideoFilePath, mixComposition: mixComposition, layerInstructions: layerInstructions, progress: progress, completion: completion, failed: failed);
    }
    
    internal func importVideo(videoAsset:AVAsset?, minTime:TimeInterval, maxTime:TimeInterval, progress: @escaping exportProgressClosure, completion: @escaping videoMergeCompletionClosure, failed: @escaping descriptionClosure)
    {
        if let asset:AVAsset = videoAsset
        {
            let lastVideoFilePath:String = BBHelper.lastVideoPath();
            String.removeFiles(lastVideoFilePath);
            
            let videoTime:TimeInterval = TimeInterval(asset.duration.value) / TimeInterval(asset.duration.timescale);
            if (videoTime < minTime || videoTime > maxTime)
            {
                failed("视频时长错误(\(minTime)秒 - \(maxTime)秒)");
                return;
            }
            
            let mixComposition:AVMutableComposition = AVMutableComposition();
            let compositionVideo:AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid);
            let compositionAudio:AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid);
            
            var layerInstructions:[AVMutableVideoCompositionLayerInstruction] = [AVMutableVideoCompositionLayerInstruction]();
            //获取视频真实的时长
            let realDuration:CMTime = CMTime(value: asset.duration.value, timescale: asset.duration.timescale);
            
            //视频数据
            let videoTracks:[AVAssetTrack] = asset.tracks(withMediaType: AVMediaTypeVideo);
            if (videoTracks.count == 0)
            {
                failed("无效视频，无法导入");
                return;
            }
            let assetVideoTrack:AVAssetTrack = videoTracks[0];
            do
            {
                try compositionVideo.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: asset.duration), of: assetVideoTrack, at: kCMTimeZero);
                compositionVideo.scaleTimeRange(CMTimeRange(start: kCMTimeZero, duration: asset.duration), toDuration: realDuration);
            }
            catch {
                failed("无效视频，无法导入");
                return;
            }
            //音频数据
            let audioTracks:[AVAssetTrack] = asset.tracks(withMediaType: AVMediaTypeAudio);
            if (audioTracks.count == 0)
            {
                failed("无效视频，无法导入");
                return;
            }
            do
            {
                try compositionAudio.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: asset.duration), of: audioTracks[0], at: kCMTimeZero);
                compositionAudio.scaleTimeRange(CMTimeRange(start: kCMTimeZero, duration: asset.duration), toDuration: realDuration);
            }
            catch{
                failed("无效视频，无法导入");
                return;
            }
            
            //视频修改尺寸和方向
//            UIApplication.dLog(NSStringFromCGSize(assetVideoTrack.naturalSize));
            let layerInstruction:AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideo);
            if (self.isVideoLandscape(track: assetVideoTrack))
            {
                let ratioX:CGFloat = BBHelper.outVideoSize.width / assetVideoTrack.naturalSize.width;
                let ratioY:CGFloat = BBHelper.outVideoSize.height / assetVideoTrack.naturalSize.height;
                var ratio:CGFloat = ratioY;
                if (ratioX > ratioY)
                {
                    ratio = ratioX;
                }
                let offSetX:Double = Double(assetVideoTrack.naturalSize.width * ratio - BBHelper.outVideoSize.height);
                let offSetY:Double = Double(assetVideoTrack.naturalSize.height * ratio - BBHelper.outVideoSize.height);
                
                //缩放
                let scaleTransform:CGAffineTransform = CGAffineTransform(scaleX: ratio, y: ratio);
                //平移
                let translationTransform:CGAffineTransform = CGAffineTransform(translationX: CGFloat(-ceil(offSetX) / 2.0), y: CGFloat(-ceil(offSetY) / 2.0));
                let transform:CGAffineTransform = assetVideoTrack.preferredTransform.concatenating(scaleTransform).concatenating(translationTransform);
                layerInstruction.setTransform(transform, at: kCMTimeZero);
            }
            else
            {
                let ratio:CGFloat = BBHelper.outVideoSize.width / assetVideoTrack.naturalSize.height;
                let offSetY:Double = Double(assetVideoTrack.naturalSize.width * ratio - BBHelper.outVideoSize.height);
                //缩放
                let scaleTransform:CGAffineTransform = CGAffineTransform(scaleX: ratio, y: ratio);
                //平移
                let translationTransform:CGAffineTransform = CGAffineTransform(translationX: 0.0, y: CGFloat(-ceil(offSetY) / 2.0));
                let transform:CGAffineTransform = assetVideoTrack.preferredTransform.concatenating(scaleTransform).concatenating(translationTransform);
                layerInstruction.setTransform(transform, at: kCMTimeZero);
            }
            layerInstructions.append(layerInstruction);
            
            self.exportLastVideo(lastVideoFilePath: lastVideoFilePath, mixComposition: mixComposition, layerInstructions: layerInstructions, progress: progress, completion: completion, failed: failed);
        }
        else
        {
            failed("无效视频，无法导入");
        }
        
    }
    
    // MARK: - event response

    // MARK: - private methods
    // MARK: - 水印图层
    fileprivate func waterImage(videoSize:CGSize) -> CALayer
    {
        let image:UIImage = UIImage(contentsOfFile: Bundle.main.path(forResource: "videowatermark", ofType: "png")!)!;
        let retVal:CALayer = CALayer();
        retVal.contents = image.cgImage;
        retVal.frame = CGRect(x: videoSize.width - image.size.width, y: videoSize.height - image.size.height, width: image.size.width, height: image.size.height);
        retVal.masksToBounds = false;
        return retVal;
    }
    
    // MARK: - 判断视频是否横屏
    fileprivate func isVideoLandscape(track:AVAssetTrack) -> Bool
    {
        let transform:CGAffineTransform = track.preferredTransform;
        switch (transform.a, transform.b, transform.c, transform.d) {
        case (0.0, 1.0, -1.0, 0.0):
            return false;
        case (0.0, -1.0, 1.0, 0.0):
            return false;
        case (1.0, 0.0, 0.0, 1.0):
            return true;
        case (-1.0, 0.0, 0.0, -1.0):
            return true;
        default:
            return false;
        }
    }
    
    fileprivate func totalVideoDuration() -> TimeInterval
    {
        var retVal:TimeInterval = 0.0;
        for item in self.multiPartValue
        {
            retVal += item.videoDuration;
        }
        return retVal;
    }
    
    fileprivate func removeTheLastOne() -> TimeInterval
    {
        var retVal:TimeInterval = 0.0;
        if (self.multiPartValue.count > 0)
        {
            if let lastOne:BBMicroPartVideoEntity = self.multiPartValue.last
            {
                retVal = lastOne.videoDuration;
                if let filePath:String = lastOne.videoPath, (!filePath.trim().isEmpty)
                {
                    String.removeFiles(filePath);
                }
            }
            self.multiPartValue.removeLast();
            self.tmpVideoFileCount -= 1;
        }
        if (self.tmpVideoFileCount <= 0)
        {
            self.tmpVideoFileCount = 0;
        }
        return retVal;
    }
    
    fileprivate func exportLastVideo(lastVideoFilePath:String, mixComposition:AVMutableComposition, layerInstructions:[AVMutableVideoCompositionLayerInstruction], progress: @escaping exportProgressClosure, completion: @escaping videoMergeCompletionClosure, failed: @escaping descriptionClosure)
    {
        let waterLayer:CALayer = self.waterImage(videoSize: BBHelper.outVideoSize);
        let parentLayer:CALayer = CALayer();
        let videoLayer:CALayer = CALayer();
        parentLayer.frame = CGRect(x: 0.0, y: 0.0, width: BBHelper.outVideoSize.width, height: BBHelper.outVideoSize.height);
        videoLayer.frame = parentLayer.frame;
        parentLayer.addSublayer(videoLayer);
        parentLayer.addSublayer(waterLayer);
        
        let timeRangeToMakeSureNotToLong:CMTimeRange = CMTimeRange(start: kCMTimeZero, duration: CMTimeMakeWithSeconds(CMTimeGetSeconds(mixComposition.duration), mixComposition.duration.timescale));
        let mainInstruction:AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction();
        mainInstruction.timeRange = timeRangeToMakeSureNotToLong;
        mainInstruction.layerInstructions = layerInstructions;
        
        let videoComposition:AVMutableVideoComposition = AVMutableVideoComposition();
        videoComposition.renderSize = BBHelper.outVideoSize;
        videoComposition.frameDuration = CMTimeMake(1, 30);
        videoComposition.instructions = [mainInstruction];
        
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool.init(postProcessingAsVideoLayer: videoLayer, in: parentLayer);
        
        self.exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality);
        if let session:AVAssetExportSession = self.exportSession //AVAssetExportPresetMediumQuality)
        {
            self.isExportRunning = true;
            session.videoComposition = videoComposition;
            session.shouldOptimizeForNetworkUse = true;
            session.timeRange = timeRangeToMakeSureNotToLong;
            session.outputURL = URL(fileURLWithPath: lastVideoFilePath);
            session.outputFileType = AVFileTypeMPEG4;
            
            var oldProgressValue:Float = -1.0;
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async(execute: {
                while (self.isExportRunning && session.progress < 1.0)
                {
                    if (oldProgressValue != session.progress)
                    {
                        oldProgressValue = session.progress;
                        progress(oldProgressValue);
                    }
                }
            })
            
            session.exportAsynchronously(completionHandler: { [weak self] in
                if let strongSelf = self
                {
                    if (session.status == AVAssetExportSessionStatus.completed)
                    {
//                        let videoThumbnailFilePath:String? = strongSelf.createVideoThumbnail(videoFilePath: lastVideoFilePath);
                        DispatchQueue.main.async(execute: {
                            completion(lastVideoFilePath, "");
                        })
                    }
                    else
                    {
                        session.cancelExport();
                        DispatchQueue.main.async(execute: {
                            failed("视频处理中断");
                        })
                    }
                    strongSelf.isExportRunning = false;
                }
            })
        }
        else
        {
            failed("视频处理失败");
        }
    }
}

// MARK: - BBMicroVideoRecordTimeThreadDelegate(时间更新回调)
extension BBMicroPartVideoManager : BBMicroVideoRecordTimeThreadDelegate
{
    func microVideoRecordTimeDidPaused(newPartTimeValue: TimeInterval) {
        if let partVideo:BBMicroPartVideoEntity = self.newMicroPartVideo
        {
            partVideo.videoDuration = newPartTimeValue;
        }
    }
    
    func microVideoRecordTimeDidUpdateTime(newTimeValue: TimeInterval) {
        if let closure = self.delegate?.microVideoRecordDidUpdateTime
        {
            closure(newTimeValue);
        }
    }
}
