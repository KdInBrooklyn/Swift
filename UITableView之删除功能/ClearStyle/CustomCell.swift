//
//  CustomCell.swift
//  ClearStyle
//
//  Created by BoBo on 17/1/19.
//  Copyright © 2017年 Ray Wenderlich. All rights reserved.
//

import UIKit
import QuartzCore

@objc protocol CustomCellDelegate {
    func toDoItemDeleted(_ toDoItem: ToDoItem)
}

class CustomCell: UITableViewCell {
    
    let kLableLeftMargin: CGFloat = 15.0
    var delegate: CustomCellDelegate?
    var toDoItem: ToDoItem? {
        didSet {
            label.text = toDoItem?.text
            label.isStrikeThrough = (toDoItem?.completed)!
            itemCompleteLayer.isHidden = !label.isStrikeThrough
        }
    }
    
    let gradientLayer: CAGradientLayer = CAGradientLayer()
    var originalCenter: CGPoint = CGPoint()
    var isDeleteOnDragRelease: Bool = false
    var isCompleteOnDragRelease: Bool = false
    
    let label: StrikeThroughTextLabel = {
        let label: StrikeThroughTextLabel = StrikeThroughTextLabel(frame: CGRect.zero)
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16)
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    var itemCompleteLayer: CALayer = CALayer()
    
    let kUICuesMargin: CGFloat = 10.0
    let kUICuesWidth: CGFloat = 50.0
    var tickLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero)
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 32.0)
        label.backgroundColor = UIColor.clear
        label.text = "\u{2713}"
        label.textAlignment = .center
        return label
    }()
    var crossLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero)
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 32.0)
        label.backgroundColor = UIColor.clear
        label.text = "\u{2717}"
        label.textAlignment = .left
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(label)
        self.selectionStyle = .none
        
        self.addSubview(tickLabel)
        self.addSubview(crossLabel)
        
        gradientLayer.frame = bounds
        let color1 = UIColor(white: 1.0, alpha: 0.2).cgColor
        let color2 = UIColor(white: 1.0, alpha: 0.1).cgColor
        let color3 = UIColor.clear.cgColor
        let color4 = UIColor(white: 0.0, alpha: 0.1).cgColor
        
        gradientLayer.colors = [color1, color2, color3, color4]
        gradientLayer.locations = [0.0, 0.01, 0.95, 1.0]
        layer.insertSublayer(gradientLayer, at: 0)
        
        itemCompleteLayer = CALayer(layer: layer)
        itemCompleteLayer.backgroundColor = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0).cgColor
        itemCompleteLayer.isHidden = true
        self.layer.insertSublayer(itemCompleteLayer, at: 0)
        
        //添加手势
        var recognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(CustomCell.handlePan(_:)))
        recognizer.delegate = self
        self.addGestureRecognizer(recognizer)
    }
    
    //确保gradientLayer的frame属性被正确地设置
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        
        itemCompleteLayer.frame = bounds
        label.frame = CGRect(x: kLableLeftMargin, y: 0.0, width: bounds.width - kLableLeftMargin, height: bounds.height)
        
        tickLabel.frame = CGRect(x: -kUICuesWidth - kUICuesMargin, y: 0.0, width: kUICuesWidth, height: bounds.size.height)
        crossLabel.frame = CGRect(x: bounds.size.width + kUICuesMargin, y: 0.0, width: kUICuesWidth, height: bounds.size.height)
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - event response
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        if (recognizer.state == .began) {
            originalCenter = center
        }
        if (recognizer.state == .changed) {
            let translation = recognizer.translation(in: self)
            center = CGPoint(x: originalCenter.x +  translation.x, y: originalCenter.y)
            
            isDeleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
            isCompleteOnDragRelease = frame.origin.x > frame.size.width / 2.0
            
            let cueAlpha = fabs(frame.origin.x) / (frame.size.width / 2.0)
            tickLabel.alpha = cueAlpha
            crossLabel.alpha = cueAlpha
            
            tickLabel.textColor = isCompleteOnDragRelease ? UIColor.green : UIColor.white
            crossLabel.textColor = isDeleteOnDragRelease ? UIColor.red : UIColor.white
        }
        
        if (recognizer.state == .ended) {
            let originalFrame: CGRect = CGRect(x: 0.0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
            
            if (isDeleteOnDragRelease) {
                if let _ = delegate, let item = toDoItem {
                    delegate?.toDoItemDeleted(item)
                }
            } else if (isCompleteOnDragRelease) {
                if toDoItem != nil {
                    toDoItem?.completed = true
                }
                label.isStrikeThrough = true
                itemCompleteLayer.isHidden = false
                UIView.animate(withDuration: 1.0, animations: {
                    self.frame = originalFrame
                })
            } else {
                UIView.animate(withDuration: 1.0, animations: {
                    self.frame = originalFrame
                })
            }
        }
    }
    
    //MARK: - private method
    func createCueLabel() -> UILabel {
        let label: UILabel = UILabel(frame: CGRect.zero)
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 32.0)
        label.backgroundColor = UIColor.clear
        return label
    }
}
