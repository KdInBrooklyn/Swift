//
//  AnimationView.swift
//  支付宝加载动画
//
//  Created by BoBo on 17/3/14.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

import UIKit

class AnimationView: UIView {
    fileprivate lazy var shapeLayer: CAShapeLayer = {
        let layer: CAShapeLayer = CAShapeLayer()
        let pathCenter: CGPoint = CGPoint(x: self.frame.width / 2.0, y: self.frame.height / 2.0)
        
        let path: UIBezierPath = UIBezierPath(arcCenter: pathCenter, radius: 10.0, startAngle: 0.0, endAngle: CGFloat(M_PI) * 2.0, clockwise: true)
        layer.path = path.cgPath
        layer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        layer.fillColor = UIColor.brown.cgColor
        
        return layer
    }()
    
    fileprivate lazy var pathLayer: CAShapeLayer = {
        let layer: CAShapeLayer = CAShapeLayer()
        let pathCenter: CGPoint = CGPoint(x: self.frame.width / 2.0, y: self.frame.height / 2.0)
        layer.path = UIBezierPath(arcCenter: pathCenter, radius: 100.0, startAngle: 0.0, endAngle: CGFloat(M_PI) * 2.0, clockwise: true).cgPath
        layer.lineWidth = 2.0
        layer.strokeColor = UIColor.red.cgColor
        layer.fillColor = UIColor.white.cgColor
        
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        pathAnimation()
        
//        addAnimation()
//        self.layer.addSublayer(shapeLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func addAnimation() {
        let path: UIBezierPath = UIBezierPath(arcCenter: CGPoint.init(x: 0.0, y: 0.0), radius: 100.0, startAngle: -CGFloat(M_PI_2), endAngle: CGFloat(M_PI_2) * 3, clockwise: true)
        let pathAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.path = path.cgPath
        pathAnimation.delegate = self
        pathAnimation.duration = 2.0
        pathAnimation.repeatCount = 3
        shapeLayer.add(pathAnimation, forKey: "pathAnimation")
    }
    
    //luj
    fileprivate func pathAnimation() {
        let endAnimation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        endAnimation.fromValue = 0.0
        endAnimation.toValue = 0.85
        endAnimation.duration = 2.0
//        endAnimation.repeatCount = 10
        
        let aniamtion: CABasicAnimation = CABasicAnimation(keyPath: "strokeStart")
        aniamtion.fromValue = 0.0
        aniamtion.toValue = 0.85
        aniamtion.beginTime = 1.0
        aniamtion.duration = 2.0
//        aniamtion.repeatCount = 10
        
        let groupAnimation: CAAnimationGroup = CAAnimationGroup()
        groupAnimation.animations = [endAnimation, aniamtion]
        groupAnimation.duration = 6.0
        groupAnimation.repeatCount = 10
        
        pathLayer.add(groupAnimation, forKey: nil)
        self.layer.addSublayer(pathLayer)
    }
}

extension AnimationView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        shapeLayer.removeFromSuperlayer()
    }
}
