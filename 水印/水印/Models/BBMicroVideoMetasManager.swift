//
//  BBMicroVideoMetasManager.swift
//  BoBo
//
//  Created by alimysoyang on 16/10/18.
//  Copyright © 2016年 bobo. All rights reserved.
//

import Foundation

//视频编辑管理
class BBMicroVideoMetasManager: NSObject
{
    // MARK: - properties
//    fileprivate var videoFilePath:String?;
//    fileprivate let tmpVideoPath:String = "\(BBHelper.kAppTmpFilePath)tmpvideo";
//    fileprivate var metas:[BBMicroVideoMetaEntity] = [BBMicroVideoMetaEntity]();
    fileprivate var exportSession:AVAssetExportSession?;
    fileprivate var isExportRunning:Bool = false;
    
//    subscript(index:Int) -> BBMicroVideoMetaEntity?
//        {
//        get {
//            if (index < 0 || index > self.metas.count)
//            {
//                return nil;
//            }
//            return self.metas[index];
//        }
//    }
//    
//    var count:Int {
//        get {
//            return self.metas.count;
//        }
//    }
    
    // MARK: - life cycle
//    init(filePath:String?)
//    {
//		super.init();
//        self.videoFilePath = filePath;
//    }
	
    override init() {
        super.init();
    }
    
    deinit
    {
	
    }

    // MARK: - public methods
//    internal func addMeta(meta:BBMicroVideoMetaEntity)
//    {
//        self.metas.append(meta);
//    }
    
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
    
    //合成资源到视频
    internal func resourcesCompositeVideo(videoPath:String, resourceMetas:BBMicroVideoResourceMetas, progress: @escaping exportProgressClosure, completion: @escaping videoMergeCompletionClosure, failed: @escaping descriptionClosure)
    {
        let fm:FileManager = FileManager();
        
        let mixComposition:AVMutableComposition = AVMutableComposition();
        let compositionVideo:AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid);
        let compositionAudio:AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid);
        
        if (fm.fileExists(atPath: videoPath))
        {
            let asset:AVAsset = AVAsset(url: URL(fileURLWithPath: videoPath));
            //获取视频真实的时长
            let realDuration:CMTime = CMTime(value: asset.duration.value, timescale: asset.duration.timescale);
            let realTime:TimeInterval = TimeInterval(asset.duration.value) / TimeInterval(asset.duration.timescale);
            //视频数据
            let videoTracks:[AVAssetTrack] = asset.tracks(withMediaType: AVMediaTypeVideo);
            if (videoTracks.count == 0)
            {
                failed("无效视频，无法编辑");
                return;
            }
            let assetVideoTrack:AVAssetTrack = videoTracks[0];
            do
            {
                try compositionVideo.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: asset.duration), of: assetVideoTrack, at: kCMTimeZero);
                compositionVideo.scaleTimeRange(CMTimeRange(start: kCMTimeZero, duration: asset.duration), toDuration: realDuration);
            }
            catch {
                failed("无效视频，无法编辑");
                return;
            }
            //音频数据
            let audioTracks:[AVAssetTrack] = asset.tracks(withMediaType: AVMediaTypeAudio);
            if (audioTracks.count == 0)
            {
                failed("无效视频，无法编辑");
                return;
            }
            let assetAudioTrack:AVAssetTrack = audioTracks[0];
            do
            {
                try compositionAudio.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: asset.duration), of: assetAudioTrack, at: kCMTimeZero);
                compositionAudio.scaleTimeRange(CMTimeRange(start: kCMTimeZero, duration: asset.duration), toDuration: realDuration);
            }
            catch{
                failed("无效视频，无法编辑");
                return;
            }
            
            let sourceAudioParams:AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: assetAudioTrack);
            sourceAudioParams.trackID = compositionAudio.trackID;
            sourceAudioParams.setVolume(resourceMetas.sourceVolumn, at: kCMTimeZero);
            
            self.exportLastVideo(videoPath: videoPath, resources: resourceMetas, sourceTime: realTime, mixComposition: mixComposition, compositionVideoTrack: compositionVideo, sourceAudioParams: sourceAudioParams, progress: progress, completion: completion, failed: failed);
        }
        else
        {
            failed("无效视频，无法编辑");
        }
    }
    
//    internal func compositeVideo(progress: @escaping exportProgressClosure, completion: @escaping videoMergeCompletionClosure, failed: @escaping descriptionClosure)
//    {
//        if let filePath:String = self.videoFilePath
//        {
//            let tmpVideoFilePath:String = "\(self.tmpVideoPath)/tmplast1.mp4";
//            String.removeFiles(tmpVideoFilePath);
//            let fm:FileManager = FileManager();
//            
//            let mixComposition:AVMutableComposition = AVMutableComposition();
//            let compositionVideo:AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid);
//            let compositionAudio:AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid);
//            
//            var layerInstructions:[AVMutableVideoCompositionLayerInstruction] = [AVMutableVideoCompositionLayerInstruction]();
//            if (fm.fileExists(atPath: filePath))
//            {
//                let asset:AVAsset = AVAsset(url: URL(fileURLWithPath: filePath));
//                //获取视频真实的时长
//                let realDuration:CMTime = CMTime(value: asset.duration.value, timescale: asset.duration.timescale);
//                //视频数据
//                let videoTracks:[AVAssetTrack] = asset.tracks(withMediaType: AVMediaTypeVideo);
//                if (videoTracks.count == 0)
//                {
//                    failed("无效视频，无法编辑");
//                    return;
//                }
//                let assetVideoTrack:AVAssetTrack = videoTracks[0];
//                do
//                {
//                    try compositionVideo.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: asset.duration), of: assetVideoTrack, at: kCMTimeZero);
//                    compositionVideo.scaleTimeRange(CMTimeRange(start: kCMTimeZero, duration: asset.duration), toDuration: realDuration);
//                }
//                catch {
//                    failed("无效视频，无法编辑");
//                    return;
//                }
//                //音频数据
//                let audioTracks:[AVAssetTrack] = asset.tracks(withMediaType: AVMediaTypeAudio);
//                if (audioTracks.count == 0)
//                {
//                    failed("无效视频，无法编辑");
//                    return;
//                }
//                do
//                {
//                    try compositionAudio.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: asset.duration), of: audioTracks[0], at: kCMTimeZero);
//                    compositionAudio.scaleTimeRange(CMTimeRange(start: kCMTimeZero, duration: asset.duration), toDuration: realDuration);
//                }
//                catch{
//                    failed("无效视频，无法编辑");
//                    return;
//                }
//                
//                let layerInstruction:AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideo);
//                layerInstructions.append(layerInstruction);
//            }
//            
//            let parentLayer:CALayer = CALayer();
//            let videoLayer:CALayer = CALayer();
//            parentLayer.frame = CGRect(x: 0.0, y: 0.0, width: BBHelper.outVideoSize.width, height: BBHelper.outVideoSize.height);
//            videoLayer.frame = parentLayer.frame;
//            parentLayer.addSublayer(videoLayer);
//            for metaValue in self.metas
//            {
//                let metaLayer:CALayer = CALayer();
//                metaLayer.frame = metaValue.rect;
//                metaLayer.contents = metaValue.metaView?.cgImage;
//                metaLayer.masksToBounds = false;
//                parentLayer.addSublayer(metaLayer);
//            }
//            
//            let timeRangeToMakeSureNotToLong:CMTimeRange = CMTimeRange(start: kCMTimeZero, duration: CMTimeMakeWithSeconds(CMTimeGetSeconds(mixComposition.duration), mixComposition.duration.timescale));
//            let mainInstruction:AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction();
//            mainInstruction.timeRange = timeRangeToMakeSureNotToLong;
//            mainInstruction.layerInstructions = layerInstructions;
//            
//            let videoComposition:AVMutableVideoComposition = AVMutableVideoComposition();
//            videoComposition.renderSize = BBHelper.outVideoSize;
//            videoComposition.frameDuration = CMTimeMake(1, 30);
//            videoComposition.instructions = [mainInstruction];
//            
//            videoComposition.animationTool = AVVideoCompositionCoreAnimationTool.init(postProcessingAsVideoLayer: videoLayer, in: parentLayer);
//            
//            self.exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality);
//            if let session:AVAssetExportSession = self.exportSession
//            {
//                session.videoComposition = videoComposition;
//                session.shouldOptimizeForNetworkUse = true;
//                session.timeRange = timeRangeToMakeSureNotToLong;
//                session.outputURL = URL(fileURLWithPath: tmpVideoFilePath);
//                session.outputFileType = AVFileTypeMPEG4;
//                
//                self.isRunning = true;
//                var oldProgressValue:Float = -1.0;
//                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
//                    while (session.progress < 1.0)
//                    {
//                        DispatchQueue.main.async(execute: {
//                            if (oldProgressValue != session.progress)
//                            {
//                                oldProgressValue = session.progress;
//                                progress(oldProgressValue);
//                            }
//                        })
//                    }
//                })
//                
//                session.exportAsynchronously(completionHandler: { [weak self] in
//                    if let strongSelf = self
//                    {
//                        strongSelf.isRunning = false;
//                        if (session.status == AVAssetExportSessionStatus.completed)
//                        {
//                            let videoThumbnailFilePath:String? = strongSelf.createVideoThumbnail(videoFilePath: tmpVideoFilePath);
//                            DispatchQueue.main.async(execute: {
//                                completion(tmpVideoFilePath, videoThumbnailFilePath);
//                            })
//                        }
//                        else
//                        {
//                            session.cancelExport();
//                            DispatchQueue.main.async(execute: {
//                                failed("视频处理失败");
//                            })
//                        }
//                        strongSelf.exportSession = nil;
//                    }
//                })
//            }
//            else
//            {
//                failed("视频处理失败");
//            }
//        }
//        else
//        {
//            failed("无效视频，无法编辑");
//        }
//    }

    
    // MARK: - event response

    // MARK: - private methods
//    fileprivate func createVideoThumbnail(videoFilePath:String) -> String?
//    {
//        let asset:AVAsset = AVAsset(url: URL(fileURLWithPath: videoFilePath));
//        let duration:Float64 = CMTimeGetSeconds(asset.duration);
//        let generator:AVAssetImageGenerator = AVAssetImageGenerator(asset: asset);
//        generator.appliesPreferredTrackTransform = true;
//        let time:CMTime = CMTimeMakeWithSeconds(duration / 3.0, 600);
//        var actualTime:CMTime = kCMTimeZero;
//        do
//        {
//            let image:CGImage = try generator.copyCGImage(at: time, actualTime: &actualTime);
//            do
//            {
//                let videoThumbnailFilePath:String = "\(self.tmpVideoPath)/tmpvideothumbnail.jpg";
//                try UIImageJPEGRepresentation(UIImage(cgImage:image), 0.8)?.write(to: URL(fileURLWithPath: videoThumbnailFilePath), options: [.atomic]);
//                return videoThumbnailFilePath;
//            }
//            catch {
//                return nil;
//            }
//        }
//        catch {
//            return nil;
//        }
//    }
    
    //叠加GIF图层
    fileprivate func exportGIFLayer(gifLayer:GifAnimationLayer?, sourceTime:TimeInterval, timeRange:CMTimeRange, compositionVideoTrack:AVMutableCompositionTrack) -> AVMutableVideoComposition?
    {
        if let layer:GifAnimationLayer = gifLayer
        {
            let parentLayer:CALayer = CALayer();
            let videoLayer:CALayer = CALayer();
            let animationLayer:AVSynchronizedLayer = layer.keyAnimationLayer();
            parentLayer.frame = CGRect(x: 0.0, y: 0.0, width: BBHelper.outVideoSize.width, height: BBHelper.outVideoSize.height);
            videoLayer.frame = parentLayer.frame;
            animationLayer.frame = parentLayer.frame;
            parentLayer.addSublayer(videoLayer);
            parentLayer.addSublayer(animationLayer);
            
            let layerInstruction:AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack);
            let mainInstruction:AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction();
            mainInstruction.timeRange = timeRange;
            mainInstruction.layerInstructions = [layerInstruction];
            
            let videoComposition:AVMutableVideoComposition = AVMutableVideoComposition();
            videoComposition.renderSize = BBHelper.outVideoSize;
            videoComposition.frameDuration = CMTimeMake(1, 30);
            videoComposition.instructions = [mainInstruction];
            
            videoComposition.animationTool = AVVideoCompositionCoreAnimationTool.init(postProcessingAsVideoLayer: videoLayer, in: parentLayer);
            return videoComposition;
        }
        
        return nil;
    }
    
    //混音
    fileprivate func exportAudioMix(sourceDuration:TimeInterval, sourceAudioParams:AVMutableAudioMixInputParameters, composition:AVMutableComposition, resourceMetas:BBMicroVideoResourceMetas) -> AVMutableAudioMix?
    {
        if let mix:AVAsset = resourceMetas.mixAsset
        {
            if let mixAudioTrack:AVAssetTrack = mix.tracks(withMediaType: AVMediaTypeAudio).first
            {
                let mixDuration:TimeInterval = TimeInterval(mix.duration.value) / TimeInterval(mix.duration.timescale);
                let mixCompositionAudio:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid);
                
                if (mixDuration < sourceDuration) //音频时长小于视频时长,重复添加
                {
                    var count:Int = Int(sourceDuration / mixDuration);
                    if (sourceDuration - TimeInterval(count) * mixDuration > 0)
                    {
                        count += 1;
                    }
                    var timeOffset:CMTime = kCMTimeZero;
                    let loopAudio:CMTime = CMTime(value: mix.duration.value, timescale: mix.duration.timescale);
                    for _ in 0..<count
                    {
                        do
                        {
                            try mixCompositionAudio.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: mix.duration), of: mixAudioTrack, at: timeOffset);
                            mixCompositionAudio.scaleTimeRange(CMTimeRange(start: timeOffset, duration: mix.duration), toDuration: loopAudio);
                        }catch{
                            return nil;
                        }
                        timeOffset = CMTimeAdd(timeOffset, loopAudio);
                    }

                }
                else
                {
                    do
                    {
                        try mixCompositionAudio.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: mix.duration), of: mixAudioTrack, at: kCMTimeZero);
                    }catch{
                        return nil;
                    }
                }
                
                let mixParams:AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: mixAudioTrack);
                mixParams.trackID = mixCompositionAudio.trackID;
                mixParams.setVolume(resourceMetas.mixVolumn, at: kCMTimeZero);
                let retVal:AVMutableAudioMix = AVMutableAudioMix();
                retVal.inputParameters = [sourceAudioParams, mixParams];
                return retVal;
            }
        }
        return nil;
    }
    
    fileprivate func exportLastVideo(videoPath:String, resources:BBMicroVideoResourceMetas, sourceTime:TimeInterval, mixComposition:AVMutableComposition, compositionVideoTrack:AVMutableCompositionTrack, sourceAudioParams:AVMutableAudioMixInputParameters, progress: @escaping exportProgressClosure, completion: @escaping videoMergeCompletionClosure, failed: @escaping descriptionClosure)
    {
        let timeRangeToMakeSureNotToLong:CMTimeRange = CMTimeRange(start: kCMTimeZero, duration: CMTimeMakeWithSeconds(CMTimeGetSeconds(mixComposition.duration), mixComposition.duration.timescale));
        let outPutPath:String = BBHelper.lastVideoPath();
        
        self.exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality);
        if let session:AVAssetExportSession = self.exportSession
        {
            var isChanged:Bool = false;
            if let videoComposition:AVMutableVideoComposition = self.exportGIFLayer(gifLayer: resources.gifLayer, sourceTime:sourceTime, timeRange: timeRangeToMakeSureNotToLong, compositionVideoTrack: compositionVideoTrack)
            {
                session.videoComposition = videoComposition;
                isChanged = true;
            }
            if let audioMix:AVMutableAudioMix = self.exportAudioMix(sourceDuration: sourceTime, sourceAudioParams: sourceAudioParams, composition: mixComposition, resourceMetas: resources)
            {
                session.audioMix = audioMix;
                isChanged = true;
            }
            
            if (!isChanged)
            {
                let videoThumbnailFilePath:String? = BBHelper.createVideoThumbnail(videoFilePath: videoPath);
                DispatchQueue.main.async(execute: {
                    completion(videoPath, videoThumbnailFilePath);
                })
                return;
            }
            
            self.isExportRunning = true;
            session.shouldOptimizeForNetworkUse = true;
            session.timeRange = timeRangeToMakeSureNotToLong;
            session.outputURL = URL(fileURLWithPath: outPutPath);
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
                        let videoThumbnailFilePath:String? = BBHelper.createVideoThumbnail(videoFilePath: outPutPath);
                        DispatchQueue.main.async(execute: {
                            completion(outPutPath, videoThumbnailFilePath);
                        })
                    }
                    else
                    {
                        session.cancelExport();
                        DispatchQueue.main.async(execute: {
                            failed("视频编辑中断");
                        })
                    }
                    strongSelf.isExportRunning = false;
                }
            })
        }
        else
        {
            failed("视频编辑失败");
        }
    }
}
