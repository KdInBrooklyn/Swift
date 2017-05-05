//
//  SecondViewController.swift
//  WKWebView与JS交互
//
//  Created by BoBo on 2017/4/27.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

import UIKit
import WebKit

//从网页拦截数据
class SecondViewController: UIViewController {
    
    let screenWidth: CGFloat = UIScreen.main.bounds.width
    let screenHeight: CGFloat = UIScreen.main.bounds.height
    fileprivate lazy var wkWebView: WKWebView = {
        let webView: WKWebView = WKWebView(frame: CGRect(x: 0.0, y: 64.0, width: self.screenWidth, height: self.screenHeight))
        webView.navigationDelegate = self
        webView.uiDelegate = self
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: UIBarButtonItemStyle.done, target: self, action: #selector(SecondViewController.eventLeftBarButtonDidClick(_:)))
        
        view.addSubview(wkWebView)
        let url: URL = URL(string: "https://www.zhibo8.cc")!
        let request: URLRequest = URLRequest(url: url)
        let _ = wkWebView.load(request)
        wkWebView.addObserver(self, forKeyPath: "title", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "title") {
            title = wkWebView.title
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func eventLeftBarButtonDidClick(_ sender: UIBarButtonItem) {
        
    }
}

extension SecondViewController: WKNavigationDelegate {
    ///该方法在网页加载时会被多次调用.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.navigationType == WKNavigationType.linkActivated) {
            
        } else {
            decisionHandler(.allow)
        }
    }
}

extension SecondViewController: WKUIDelegate {
    
}
