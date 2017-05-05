//
//  ViewController.swift
//  WKWebView与JS交互
//
//  Created by BoBo on 17/3/15.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

import UIKit
import WebKit

//WKWebView的基本使用(实现简单的Safari)
/**
 需要优化的地方
 1. 用户输入网址时必须要输入http://, 
 2. 界面优化
 */
class ViewController: UIViewController {
    
    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var barView: UIView!
    var wkWebView: WKWebView?
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var urlField: UITextField!
    required init?(coder aDecoder: NSCoder) {
        self.wkWebView = WKWebView(frame: CGRect.zero)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(ViewController.eventRightBarButtonDidClick(_:)))
        
        wkWebView?.navigationDelegate = self
        view.insertSubview(wkWebView!, belowSubview: progressView)
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
        
        barView.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 30.0)
        
        self.leftBtn.isEnabled = false
        self.rightBtn.isEnabled = false
        
        wkWebView?.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        wkWebView?.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        barView.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: 30.0)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "loading") {
            
            
        }
        if (keyPath == "estimatedProgress") {
            progressView.isHidden = wkWebView?.estimatedProgress == 1
            progressView.setProgress(Float((wkWebView?.estimatedProgress)!), animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func back(_ sender: UIButton) {
        wkWebView?.goBack()
    }

    @IBAction func go(_ sender: UIButton) {
//        wkWebView?.goForward()
        let secondVC: SecondViewController = SecondViewController()
        navigationController?.pushViewController(secondVC, animated: true)
    }
    
    @IBAction func refreshRequest(_ sender: UIButton) {
//        let request = URLRequest(url: (wkWebView?.url)!)
//        wkWebView?.load(request)
        
        let secondVC: SecondViewController = SecondViewController()
        navigationController?.pushViewController(secondVC, animated: true)
    }
    
    func eventRightBarButtonDidClick(_ sender: UIBarButtonItem) {
        let secondVC: SecondViewController = SecondViewController()
        navigationController?.pushViewController(secondVC, animated: true)
    }
}
//
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
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: true)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let alertAct: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let alertController: UIAlertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .actionSheet)
        alertController.addAction(alertAct)
        present(alertController, animated: true, completion: nil)
    }
}
