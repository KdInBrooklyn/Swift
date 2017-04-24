//
//  ViewController.swift
//  2048
//
//  Created by 李森 on 2017/4/4.
//  Copyright © 2017年 李森. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var lsWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//       let path = Bundle.main.path(forResource: "index", ofType: "html")
//        let url = URL.init(fileURLWithPath: path!)
//        let request = URLRequest(url: url)
//        lsWebView.delegate = self
//        lsWebView.loadRequest(request)
        
        /**
        加载本地HTML文件方式
        */
//        let path = Bundle.main.bundlePath
//        let baseURL = URL(fileURLWithPath: path)
//        
//        let htmlPath = Bundle.main.path(forResource: "index", ofType: "html")
//        
//        do {
//            let htmlCon = try String(contentsOfFile: htmlPath!, encoding: String.Encoding.utf8)
//            lsWebView.loadHTMLString(htmlCon, baseURL: baseURL)
//        } catch  {
//            print(error)
//        }
        
        /**
         从网络加载HTML
         */
        let request: URLRequest = URLRequest(url: URL(string: "http://192.168.1.114:8860/FlyGame/")!)//"http://www.code4app.com/thread-10784-1-1.html")!)
        lsWebView.loadRequest(request)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
}

