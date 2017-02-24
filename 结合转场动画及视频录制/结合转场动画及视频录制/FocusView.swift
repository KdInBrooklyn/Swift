//
//  FocusView.swift
//  结合转场动画及视频录制
//
//  Created by BoBo on 17/2/24.
//  Copyright © 2017年 李森. All rights reserved.
//

import UIKit

class FocusView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let shapeLayer: CAShapeLayer = CAShapeLayer()
        let shapePath: UIBezierPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 0.0);
        shapeLayer.path = shapePath.cgPath
        shapeLayer.strokeColor = UIColor.yellow.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(shapeLayer)
    }
}
