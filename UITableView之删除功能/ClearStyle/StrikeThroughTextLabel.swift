//
//  StrikeThroughTextLabel.swift
//  ClearStyle
//
//  Created by BoBo on 17/1/19.
//  Copyright © 2017年 Ray Wenderlich. All rights reserved.
//

import UIKit
//import QuartzCore

class StrikeThroughTextLabel: UILabel {
    
    let kStrikeOutThickness: CGFloat = 2.0
    
    let strikeThroughLayer: CALayer = {
        let layer: CALayer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        layer.isHidden = true
        
        return layer
    }()
    
    var isStrikeThrough: Bool = false {
        didSet {
            strikeThroughLayer.isHidden = !isStrikeThrough
            if (isStrikeThrough) {
                self.resizesStrikeThrough()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.addSublayer(strikeThroughLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.resizesStrikeThrough()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: private method
    fileprivate func resizesStrikeThrough() {
        let textSize: CGSize = (text?.size(attributes: [NSFontAttributeName: font]))!
        strikeThroughLayer.frame = CGRect(x: 0.0, y: bounds.size.height / 2.0, width: textSize.width, height: kStrikeOutThickness)
    }
}
