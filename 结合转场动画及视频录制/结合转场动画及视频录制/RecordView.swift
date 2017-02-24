//
//  RecordView.swift
//  结合转场动画及视频录制
//
//  Created by BoBo on 17/2/24.
//  Copyright © 2017年 李森. All rights reserved.
//

import UIKit

@objc protocol RecordViewDelegate {
    func recordViewDidStart(_ recordView: RecordView)
    func recordViewDidSop(_ recordView: RecordView)
}

class RecordView: UIView {
    
    weak var delegate: RecordViewDelegate?
    fileprivate var currentTimer: TimeInterval = 0.0
    fileprivate var timer: Timer?
    
    fileprivate var smallShapeLayer: CAShapeLayer = {
        let layer: CAShapeLayer = CAShapeLayer()
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.white.cgColor
        
        return layer
    }()
    
    fileprivate var bigShapeLayer: CAShapeLayer = {
        let layer: CAShapeLayer = CAShapeLayer()
        layer.fillColor = UIColor.darkGray.cgColor
        layer.strokeColor = UIColor.darkGray.cgColor
        
        return layer
    }()
    
    fileprivate var progressLayer: CAShapeLayer = {
        let layer: CAShapeLayer = CAShapeLayer()
        layer.strokeColor = UIColor.green.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 5.0
        
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let pressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(RecordView.eventLongPressGesture(_:)))
        self.addGestureRecognizer(pressGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect);
        
        let smallCir: UIBezierPath = UIBezierPath(arcCenter: CGPoint(x: self.frame.width / 2.0, y: self.frame.height / 2.0), radius: 10.0, startAngle: 0.0, endAngle: CGFloat(M_PI) * 2.0, clockwise: true)
        let bigCir: UIBezierPath = UIBezierPath(arcCenter: CGPoint(x: self.frame.width / 2.0, y: self.frame.height / 2.0), radius: 40.0, startAngle: 0.0, endAngle: CGFloat(M_PI) * 2.0, clockwise: true)
        
        smallShapeLayer.path = smallCir.cgPath
        bigShapeLayer.path = bigCir.cgPath
        
        self.layer.addSublayer(bigShapeLayer)
        self.layer.addSublayer(smallShapeLayer)
    }
    
    deinit {
        self.delegate = nil
    }
    
    //MARK: - event response
    func eventLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
//            self.animation()
            guard let _ = self.delegate?.recordViewDidStart(self) else {
                return
            }
        case .cancelled, .ended, .possible, .failed:
//            self.timer?.invalidate()
//            self.currentTimer = 0.0
            guard let _ = self.delegate?.recordViewDidSop(self) else {
                return
            }
        }
    }
    
    func eventTimerClock() {
        self.currentTimer += 1.0
    }
    
    //MARK: - life cycle
    fileprivate func animation() {
        let startPath: UIBezierPath = UIBezierPath() //(arcCenter: CGPoint.init(x: self.frame.width / 2.0, y: self.frame.height / 2.0), radius: 35, startAngle: 0.0, endAngle: CGFloat(M_PI) * 2.0, clockwise: true)
        startPath.move(to: CGPoint(x: self.frame.width / 2.0, y: 0.0))
        
//         timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(RecordView.eventTimerClock), userInfo: nil, repeats: true)
//        RunLoop.current.add(timer!, forMode: .commonModes)
        
        let currentAngle: CGFloat = CGFloat(M_PI) * 2.0 / 10.0 * CGFloat(currentTimer)
        let endPath: UIBezierPath = UIBezierPath(arcCenter: CGPoint.init(x: self.frame.width / 2.0, y: self.frame.height / 2.0), radius: 35, startAngle: 0.0, endAngle: currentAngle, clockwise: true)
        let progressAnimation: CABasicAnimation = CABasicAnimation(keyPath: "path")
        progressAnimation.fromValue = startPath.cgPath
        progressAnimation.toValue = endPath.cgPath
        progressAnimation.fillMode = kCAFillModeRemoved
        progressAnimation.duration = 1.0
        
        progressLayer.add(progressAnimation, forKey: "")
        self.layer.addSublayer(progressLayer)
    }
}
