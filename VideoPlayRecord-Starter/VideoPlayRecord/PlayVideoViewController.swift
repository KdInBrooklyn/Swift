//
//  PlayVideoViewController.swift
//  VideoPlayRecord
//
//  Created by Andy on 2/1/15.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit

import MediaPlayer
import MobileCoreServices

//添加框架

class PlayVideoViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
    //MARK: - event response
  @IBAction func playVideo(_ sender: AnyObject) {
    let _ = self.startMediaBrowserFromViewController(self, usingDelegate: self);
  }
    //MARK: - private method
    func startMediaBrowserFromViewController(_ viewController: UIViewController, usingDelegate delegate: UINavigationControllerDelegate & UIImagePickerControllerDelegate) -> Bool {
        //确保可以从设备上获取到
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
            return false;
        }
        
        var mediaUI = UIImagePickerController();
        mediaUI.sourceType = .savedPhotosAlbum;
        mediaUI.mediaTypes = [kUTTypeMovie as String]; //只筛选视频
        mediaUI.allowsEditing = true;
        mediaUI.delegate = self;
        
        present(mediaUI, animated: true, completion: nil);
        
        return true;
    }
}

//MARK: UIImagePickerControllerDelegate
extension PlayVideoViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        dismiss(animated: true) { 
            if mediaType == kUTTypeMovie {
                let moviePlayer = MPMoviePlayerViewController(contentURL: info[UIImagePickerControllerMediaURL] as! URL)
                self.presentMoviePlayerViewControllerAnimated(moviePlayer!)
            }
        }
    }
}

//MARK: UINavigationControllerDelegate
extension PlayVideoViewController: UINavigationControllerDelegate {
    
}
