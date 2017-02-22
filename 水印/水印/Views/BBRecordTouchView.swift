//
//  BBRecordTouchView.swift
//  BoBo
//
//  Created by alimysoyang on 16/10/10.
//  Copyright © 2016年 bobo. All rights reserved.
//

import Foundation

@objc protocol BBRecordTouchViewDelegate
{
    func bbRecordTouchViewDidStartRecord(view:BBRecordTouchView);
    func bbRecordTouchViewDidStopRecord(view:BBRecordTouchView);
}

class BBRecordTouchView: UIView
{
    // MARK: - properties
    weak var delegate:BBRecordTouchViewDelegate?;
    
    fileprivate var bgView:UIImageView = {
        let view:UIImageView = UIImageView(frame: .zero);
        view.isUserInteractionEnabled = true;
        view.image = UIImage(named:"record_start");
        return view;
    }();
    
    // MARK: - life cycle
    override init(frame:CGRect)
    {
		super.init(frame:frame);
        self.initViews();
    }
	
    required init?(coder aDecoder:NSCoder)
    {
		super.init(coder:aDecoder);
    }

    deinit
    {
        self.delegate = nil;
    }

    // MARK: - public methods

    // MARK: - event response
    internal func eventLongPressGestureRecognizer(sender:UIGestureRecognizer)
    {
        switch sender.state {
        case .began, .changed:
            guard let _ = self.delegate?.bbRecordTouchViewDidStartRecord(view: self) else {
                return;
            }
        case .cancelled, .ended, .failed, .possible:
            guard let _ = self.delegate?.bbRecordTouchViewDidStopRecord(view: self) else {
                return;
            }
        }
    }
    
    // MARK: - private methods
    fileprivate func initViews()
    {
        self.addSubview(self.bgView);
        self.bgView.snp.makeConstraints { (make:ConstraintMaker) in
            make.edges.equalTo(self);
        }
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(BBRecordTouchView.eventLongPressGestureRecognizer(sender:)));
        self.addGestureRecognizer(longPress);
    }
}
