//
//  ViewController.swift
//  App之间的跳转
//
//  Created by BoBo on 2017/4/11.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        //在info.plist中添加 URL Types,添加URL Scheme 和 URL Identifier
        //在Safari中输入URL Scheme://即可完成App的跳转
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

