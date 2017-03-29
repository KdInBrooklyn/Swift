//
//  ViewController.swift
//  WebView与JS交互
//
//  Created by BoBo on 17/3/15.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var triggerBtn: UIButton!
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //从本地加载html
        let path: String = Bundle.main.path(forResource: "index", ofType: "html")!
        webView.loadRequest(URLRequest(url: URL(fileURLWithPath: path)))
        
        //MARK: - app调用js方法
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //直接调用JS的方法
    @IBAction func eventButtonDidClick(_ sender: UIButton) {
       webView.stringByEvaluatingJavaScript(from: "hi()")
    }
}

