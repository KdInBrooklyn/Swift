//
//  ViewController.swift
//  WKWebView与JS交互
//
//  Created by BoBo on 17/3/15.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

import UIKit
import WebKit

//WKWebView的基本使用
class ViewController: UIViewController {
    
    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var barView: UIView!
    var wkWebView: WKWebView?
    
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var urlField: UITextField!
    required init?(coder aDecoder: NSCoder) {
        self.wkWebView = WKWebView(frame: CGRect.zero)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(wkWebView!)
        //禁止自动约束
        wkWebView?.translatesAutoresizingMaskIntoConstraints = false
        //对wkWebView的宽高添加约束
        let top = NSLayoutConstraint(item: wkWebView!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 64.0)
        let left = NSLayoutConstraint(item: wkWebView!, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0)
        let height = NSLayoutConstraint(item: wkWebView!, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: -108.0)
        let width = NSLayoutConstraint(item: wkWebView!, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
        view.addConstraints([top, left, height, width])
        
        let url: URL = URL(string: "https://www.appcoda.com")!
        let request: URLRequest = URLRequest(url: url)
        let _ = wkWebView?.load(request)
        
        self.leftBtn.isEnabled = false
        self.rightBtn.isEnabled = false
        
        wkWebView?.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField.text == nil {
//            return
//        }
        urlField.resignFirstResponder()
        let _ = wkWebView?.load(URLRequest(url: URL(string: textField.text!)!))
        return false
    }
}

extension ViewController: WKUIDelegate, WKNavigationDelegate {
    
}
