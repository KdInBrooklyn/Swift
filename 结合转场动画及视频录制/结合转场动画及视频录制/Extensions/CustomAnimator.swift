//
//  CustomAnimator.swift
//  结合转场动画及视频录制
//
//  Created by 李森 on 2017/2/23.
//  Copyright © 2017年 李森. All rights reserved.
//

import UIKit

class CustomAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    weak var transitionContext: UIViewControllerContextTransitioning?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2.0
    }
    
    func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        self.transitionContext?.completeTransition(!(self.transitionContext?.transitionWasCancelled)!)
        
        self.transitionContext?.viewController(forKey: .from)?.view.layer.mask = nil
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView: UIView = transitionContext.containerView
        let toView: UIView = transitionContext.view(forKey: .to)!
        let fromView: UIView = transitionContext.view(forKey: .from)!
        toView.alpha = 0.0
        fromView.alpha = 1.0
        containerView.addSubview(toView)
        
        UIView.animate(withDuration: 2.0, animations: { 
            fromView.alpha = 0.0
            toView.alpha = 1.0
        }) { (isFinished: Bool) in
            transitionContext.completeTransition(true)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
