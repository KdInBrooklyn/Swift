//
//  MergeVideoViewController.swift
//  VideoPlayRecord
//
//  Created by Andy on 2/1/15.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AssetsLibrary
import MediaPlayer
import CoreMedia

class MergeVideoViewController: UIViewController {
  var firstAsset: AVAsset?
  var secondAsset: AVAsset?
  var audioAsset: AVAsset?
  var loadingAssetOne = false

  @IBOutlet var activityMonitor: UIActivityIndicatorView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func savedPhotosAvailable() -> Bool {
    if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
      let alert = UIAlertController(title: "Not Available", message: "No Saved Album found", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
      present(alert, animated: true, completion: nil)
      return false
    }
    return true
  }
    
    //MARK: - private method
  func startMediaBrowserFromViewController(_ viewController: UIViewController!, usingDelegate delegate : (UINavigationControllerDelegate & UIImagePickerControllerDelegate)!) -> Bool {
    if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
      return false
    }

    let mediaUI = UIImagePickerController()
    mediaUI.sourceType = .savedPhotosAlbum
    mediaUI.mediaTypes = [kUTTypeMovie as NSString as String]
    mediaUI.allowsEditing = true
    mediaUI.delegate = delegate
    present(mediaUI, animated: true, completion: nil)
    return true
  }

    func exportDidFinish(session: AVAssetExportSession) {
        if session.status == .completed {
            let outputURL = session.outputURL
            let library = ALAssetsLibrary()
            if library.videoAtPathIs(compatibleWithSavedPhotosAlbum: outputURL) {
                library.writeVideoAtPath(toSavedPhotosAlbum: outputURL, completionBlock: { (assetUTK:URL?, error: Error?) in
                    var title = ""
                    var message = ""
                    if error != nil {
                        title = "Error"
                        message = "Failed to save video"
                    } else {
                        title = "Success"
                        message = "Video Saved"
                    }
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                });
            }
        }
        
        activityMonitor.stopAnimating()
        firstAsset = nil
        secondAsset = nil
        audioAsset = nil
    }
    
    //MARK: - event response
  @IBAction func loadAssetOne(_ sender: AnyObject) {
    if savedPhotosAvailable() {
      loadingAssetOne = true
      startMediaBrowserFromViewController(self, usingDelegate: self)
    }
  }


  @IBAction func loadAssetTwo(_ sender: AnyObject) {
    if savedPhotosAvailable() {
      loadingAssetOne = false
      startMediaBrowserFromViewController(self, usingDelegate: self)
    }
  }

  
  @IBAction func loadAudio(_ sender: AnyObject) {
    let mediaPickerController = MPMediaPickerController(mediaTypes: .any)
    mediaPickerController.delegate = self
    mediaPickerController.prompt = "Select Audio"
    self.present(mediaPickerController, animated: true, completion: nil)
  }
  
  
  @IBAction func merge(_ sender: AnyObject) {
    if let firstAsset = firstAsset, let secondAsset = secondAsset {
        activityMonitor.startAnimating()
        
        //1.
        var mixComposition = AVMutableComposition()
        
        //2. video track
        let firstTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        do {
            try firstTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, firstAsset.duration), of: firstAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: kCMTimeZero)
        } catch _ {
            print("Failed to load first track")
        }
        
        let secondTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        do {
            try secondTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, secondAsset.duration), of: secondAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: firstAsset.duration)
        } catch _ {
            print("Failed to load second track")
        }
        
        //3. audio track
        if let loadedAudioAsset = audioAsset {
            let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
            do {
                try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration)), of: loadedAudioAsset.tracks(withMediaType: AVMediaTypeAudio)[0], at: kCMTimeZero)
            } catch _ {
                print("Failed to load audio track")
            }
        }
        
        //4. Get path
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        
        let date = dateFormatter.string(from: Date())
        let savePath = (documentDirectory as NSString).strings(byAppendingPaths: ["mergeVideo-\(date).mov"])
    }
    
  }
  
    
    
    
}

extension MergeVideoViewController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    let mediaType = info[UIImagePickerControllerMediaType] as! NSString
    dismiss(animated: true, completion: nil)

    if mediaType == kUTTypeMovie {
      let avAsset = AVAsset(url:info[UIImagePickerControllerMediaURL] as! URL)
      var message = ""
      if loadingAssetOne {
        message = "Video one loaded"
        firstAsset = avAsset
      } else {
        message = "Video two loaded"
        secondAsset = avAsset
      }
      let alert = UIAlertController(title: "Asset Loaded", message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
      present(alert, animated: true, completion: nil)
    }
  }

}

extension MergeVideoViewController: UINavigationControllerDelegate {

}

extension MergeVideoViewController: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        let selectedSongs = mediaItemCollection.items;
        if selectedSongs.count > 0 {
            let song = selectedSongs[0]
            if let url = song.value(forProperty: MPMediaItemPropertyAssetURL) as? URL {
                audioAsset = AVAsset(url: url)
                dismiss(animated: true, completion: nil)
                let alert = UIAlertController(title: "Asset Loaded", message: "Audio Loaded", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            } else {
                dismiss(animated: true, completion: nil)
                let alert = UIAlertController(title: "Asset Not Avaliable", message: "Audio Not Loaded", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
}
