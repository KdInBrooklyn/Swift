//
//  BBLoadEditResourceView.swift
//  BoBo
//
//  Created by alimysoyang on 16/12/14.
//  Copyright © 2016年 bobo. All rights reserved.
//

import Foundation

@objc protocol BBLoadEditResourceViewDelegate
{
    func reloadResource();
}

// <#Description#>
class BBLoadEditResourceView: UIView 
{
    // MARK: - properties
    weak var delegate:BBLoadEditResourceViewDelegate?;
    
    fileprivate var isLoading:Bool = false;
    
    fileprivate lazy var loadingResource:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray);
    
    fileprivate lazy var btnReload:UIButton = {
        let button:UIButton = UIButton(frame: CGRect.zero);
        button.titleLabel?.font = BBHelper.p14;
        button.setTitle("加载资源中...", for: .normal);
        button.setTitleColor(BBHelper.darkGrayTextColor, for: .normal);
        button.addTarget(self, action: #selector(BBLoadEditResourceView.eventButtonClicked), for: .touchUpInside);
        return button;
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
    internal func startAnimating()
    {
        self.loadingResource.startAnimating();
        self.isLoading = true;
        self.btnReload.setTitle("加载资源中...", for: .normal);
    }
    
    internal func stopAnimating()
    {
        self.loadingResource.stopAnimating();
        self.isLoading = false;
    }
    
    internal func failed()
    {
        self.btnReload.setTitle("点击重新加载", for: .normal);
    }
    // MARK: - event response
    internal func eventButtonClicked()
    {
        if (self.isLoading)
        {
            return;
        }
        guard let _ = self.delegate?.reloadResource() else {
            return;
        }
    }
    
    // MARK: - private methods
    fileprivate func initViews()
    {
        self.loadingResource.stopAnimating();
        self.addSubview(self.loadingResource);
        self.loadingResource.snp.makeConstraints { (make:ConstraintMaker) in
            make.centerX.equalTo(self).offset(-10.0);
            make.centerY.equalTo(self);
        }
        
        self.addSubview(self.btnReload);
        self.btnReload.snp.makeConstraints { (make:ConstraintMaker) in
            make.top.equalTo(self.loadingResource.snp.bottom).offset(5.0);
            make.centerX.equalTo(self);
            make.width.equalTo(200.0);
        }
    }
}
