//
//  BBMultiPartProgressView.swift
//  BoBo
//
//  Created by alimysoyang on 16/10/9.
//  Copyright © 2016年 bobo. All rights reserved.
//

import Foundation

/// 多分段进度条组件视图
class BBMultiPartProgressView: UIView 
{
    // MARK: - properties
    lazy var minTagView:UIView = {
        let view:UIView = UIView();
        view.backgroundColor = UIColor.white;
        return view;
    }();
    
    lazy var progressView:UIProgressView = {
        let progressView:UIProgressView = UIProgressView(progressViewStyle: .default);
        progressView.trackTintColor = UIColor(rgb: 0x2b2938);//UIColor.lightGray;
        progressView.progressTintColor = UIColor(rgb:0xff206f);//UIColor.green;
        progressView.progress = 0.0;
        return progressView;
    }();

    lazy var lbCurrentTime:UILabel = {
        let label:UILabel = UILabel(frame: .zero);
        label.font = BBHelper.p12;
        label.textColor = UIColor.white;
        label.layer.cornerRadius = 2.0;
        label.layer.borderWidth = 1.0;
        label.layer.borderColor = UIColor(rgb: 0x5e5e5e).cgColor;
        label.text = "0.0秒";
        label.textAlignment = .center;
        return label;
    }();
    
    fileprivate var minValue:TimeInterval = 0.0;
    fileprivate var maxValue:TimeInterval = 0.0;
    fileprivate var tagValue:CGFloat = 0.0;
    
    // MARK: - life cycle
    init(frame:CGRect, minTimeValue:TimeInterval = 8.0, maxTimeValue:TimeInterval = 120.0)
    {
		super.init(frame:frame);
        self.minValue = minTimeValue;
        self.maxValue = maxTimeValue;
        self.tagValue = CGFloat(minTimeValue / maxTimeValue);
        self.initViews();
    }
	
    required init?(coder aDecoder:NSCoder)
    {
		super.init(coder:aDecoder);
    }

    deinit
    {
//        self.delegate = nil;
    }

    // MARK: - public methods
    internal func removeErrorVideoDuration(videoDuration:TimeInterval)
    {
        let value:Float = Float(videoDuration / self.maxValue);
        if (self.progressView.progress >= value)
        {
            self.progressView.progress -= value;
        }
        else
        {
            self.progressView.progress = 0.0;
        }
    }
    
    // MARK: - event response

    // MARK: - private methods
	fileprivate func initViews()
	{
        self.progressView.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: 8.0);
        self.progressView.transform = CGAffineTransform(scaleX: 1.0, y: 4.0);
        self.minTagView.frame = CGRect(x: self.tagValue * self.frame.size.width, y: 0.0, width: 2.0, height: 2.0);
        self.lbCurrentTime.frame = CGRect(x: self.frame.size.width - 64.0, y: 8.0, width: 60.0, height: self.frame.size.height - 10.0);
        self.addSubview(self.progressView);
        self.progressView.addSubview(self.minTagView);
        self.addSubview(self.lbCurrentTime);
	}
}
