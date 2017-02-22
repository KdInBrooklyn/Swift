//
//  VideoRecordViewController.swift
//  视频录制合成
//
//  Created by BoBo on 17/2/22.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

import UIKit

class VideoRecordViewController: UIViewController {

    @IBOutlet weak var closeBtn: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func closeButtonDidClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil);
    }
}
