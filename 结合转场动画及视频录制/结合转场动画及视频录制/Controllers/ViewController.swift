//
//  ViewController.swift
//  结合转场动画及视频录制
//
//  Created by 李森 on 2017/2/23.
//  Copyright © 2017年 李森. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy var pushButton: UIButton = {
        let button: UIButton = UIButton(frame: CGRect.zero)
        button.setTitle("跳转", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.addTarget(self, action: #selector(ViewController.pushButtonDidClick), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.yellow
        self.view.addSubview(self.pushButton)
        self.pushButton.snp.makeConstraints { (make: ConstraintMaker) in
            make.top.equalTo(100.0)
            make.centerX.equalTo(self.view)
            make.width.equalTo(100.0)
            make.height.equalTo(30.0)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func pushButtonDidClick() {
        let videoRecordVC: VideoRecordViewController = VideoRecordViewController()
        videoRecordVC.transitioningDelegate = self;
        self.present(videoRecordVC, animated: true, completion: nil)
    }

}

extension ViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let transitionAnimator = CustomAnimator()
        return transitionAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitionAnimator = CustomAnimator()
        return transitionAnimator
    }
    
}

