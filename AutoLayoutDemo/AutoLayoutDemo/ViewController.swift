//
//  ViewController.swift
//  AutoLayoutDemo
//
//  Created by BoBo on 2017/4/21.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    /**
     Three choices:
      1. Use Layout Anchors
      2. Use NSLayoutAnchor Class
      3. Use the Visual Format Language
     */
    
    fileprivate lazy var firstView: UIView = {
        let view: UIView = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.brown
        return view
    }()
    
    fileprivate lazy var secondView: UIView = {
        let view: UIView = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.red
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoLayoutViews()
        
        /**
         接受用户截屏的通知
         */
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.eventUserDidTakeScreenShot), name: NSNotification.Name.UIApplicationUserDidTakeScreenshot, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func eventUserDidTakeScreenShot()
    {
    }
    
    fileprivate func autoLayoutViews() {
        /**
         Using Layout Anchors
         */
        view.addSubview(firstView)
        firstView.translatesAutoresizingMaskIntoConstraints = false
        let margins = view.layoutMarginsGuide
        let topConstraint = firstView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 64.0)
        let leftConstarint = firstView.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 10.0)
        let rightConstraint = firstView.widthAnchor.constraint(equalToConstant: 200.0)
        let bottomConstarint = firstView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -100.0)
        view.addConstraints([topConstraint, leftConstarint, rightConstraint, bottomConstarint])
        
        /**
         Using LayoutConstraint
         */
        
        view.addSubview(secondView)
        secondView.translatesAutoresizingMaskIntoConstraints = false
        let topCons = NSLayoutConstraint(item: secondView, attribute: .top, relatedBy: .equal, toItem: firstView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let leftCons = NSLayoutConstraint(item: secondView, attribute: .left, relatedBy: .equal, toItem: firstView, attribute: .right, multiplier: 1.0, constant: 10.0)
        let rightCons = NSLayoutConstraint(item: secondView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: -10.0)
        let bottomCons = NSLayoutConstraint(item: secondView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -10.0)
        view.addConstraints([topCons, leftCons, rightCons, bottomCons])
    }
}

