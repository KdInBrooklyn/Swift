//
//  ViewController.swift
//  支付宝加载动画
//
//  Created by BoBo on 17/3/14.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    fileprivate lazy var animationView: AnimationView = {
        let view: AnimationView = AnimationView(frame: CGRect(x: 0.0, y: 64.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(animationView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

