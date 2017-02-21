//
//  RecordVideoViewController.swift
//  VideoPlayRecord
//
//  Created by Andy on 2/1/15.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit
//导入框架
import MobileCoreServices

class RecordVideoViewController: UIViewController {
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
    //MARK: - event response
  @IBAction func record(_ sender: AnyObject) {
    startCametaFromViewController(self, withDelegate: self)
  }
    
    func video(videoPath: NSString, didFinishSavingWithError error: Error?, contextInfo info:Any) {
        var title = "Success";
        var message = "Video was saved"
        if let _ = error {
            title = "Error"
            message = "Video failed to save"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil));
        self.present(alert, animated: true, completion: nil);
    }
    
    //MARK: - private method
    func startCametaFromViewController(_ viewController: UIViewController, withDelegate delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            return false;
        }
        
        var cameraController = UIImagePickerController();
        cameraController.sourceType = .camera;
        cameraController.mediaTypes = [kUTTypeMovie as NSString as String];
        cameraController.allowsEditing = true;
        cameraController.delegate = self;
        
        viewController.present(cameraController, animated: true, completion: nil);
        
        return true
    }
}

//MARK: - UIImagePickerControllerDelegate
extension RecordVideoViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        self.dismiss(animated: true) { 
            if mediaType == kUTTypeMovie {
                guard let path = (info[UIImagePickerControllerMediaURL] as? URL)?.path else {
                    return
                }
                
                if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {
                    UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(RecordVideoViewController.video(videoPath:didFinishSavingWithError:contextInfo:)), nil);
                }
                
            }
        }
    }
}

//MARK: - UINavigationControllerDelegate
extension RecordVideoViewController: UINavigationControllerDelegate {
    
}
