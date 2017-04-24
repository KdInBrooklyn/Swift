//
//  LSHeaderView.swift
//  UIPageViewControllerDemo
//
//  Created by 李森 on 2017/4/24.
//  Copyright © 2017年 李森. All rights reserved.
//

import UIKit

@objc protocol LSHeaderViewDelegate {
    func lsHeaderViewDidSeleced(_ index: Int)
}

class LSHeaderView: UIView {
    
    weak var delegate: LSHeaderViewDelegate?
    let kViewTag: Int = 100
    let labelWidth: CGFloat = (UIScreen.main.bounds.width - 40.0) / 3
    
    fileprivate lazy var rollView: UIView = {
        let view: UIView = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.red
        
        return view
    }()
    
    fileprivate lazy var titles: [String] = { //懒加载不能用于常量的声明，查明具体原因
       return ["首页", "关注", "我的"]
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
    }
    
    deinit {
        delegate = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - event response
    func eventTapGestureResponse(_ recognizer: UITapGestureRecognizer) {
        if  let tapView: UIView = recognizer.view {
//            if tapView.tag == self.kViewTag {
//                
//            } else if tapView.tag == self.kViewTag + 1 {
//                
//            } else if tapView.tag == self.kViewTag + 2 {
//                
//            }
            
            
            let oldFrame: CGRect = rollView.frame
            UIView.animate(withDuration: 1.0, animations: { [weak self] in
                if let strongSelf = self {
                strongSelf.rollView.frame = CGRect(x: tapView.frame.origin.x, y: oldFrame.origin.y, width: oldFrame.size.width, height: oldFrame.size.height)
                }
            })
            
            guard  let _ = delegate?.lsHeaderViewDidSeleced(tapView.tag - self.kViewTag) else {
                return
            }
        }
    }
    
    fileprivate func initViews() {
        for i in 0..<3 {
            let label: UILabel = UILabel(frame: CGRect.zero)
            label.text = titles[i]
            label.textAlignment = .center
            label.tag = self.kViewTag + i
            label.isUserInteractionEnabled = true
            let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LSHeaderView.eventTapGestureResponse(_:)))
            label.addGestureRecognizer(gesture)
            self.addSubview(label)
            label.snp.makeConstraints({ (make: ConstraintMaker) in
                make.top.equalTo(self).offset(20.0)
                make.left.equalTo(self).offset(labelWidth * CGFloat(i) + 10.0)
                make.width.equalTo(labelWidth)
                make.height.equalTo(30.0)
            })
            
            if i == 0 {
                self.addSubview(rollView)
                rollView.snp.makeConstraints({ (make: ConstraintMaker) in
                    make.top.equalTo(label.snp.bottom).offset(5.0)
                    make.left.right.equalTo(label)
                    make.height.equalTo(4.0)
                })
            }
        }
    }
}
