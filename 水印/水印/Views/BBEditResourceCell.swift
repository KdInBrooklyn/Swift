//
//  BBEditResourceCell.swift
//  BoBo
//
//  Created by alimysoyang on 16/12/19.
//  Copyright © 2016年 bobo. All rights reserved.
//

import Foundation

@objc protocol BBEditResourceCellDelegate
{
    func bbEditResourceCell(resource:BBEditResource, index:Int, didDownloadFinished success:Bool, description:String);
}

//MARK: - 资源表格Cell对象
class BBEditResourceCell:UICollectionViewCell
{
    // MARK: - properties
    weak var delegate:BBEditResourceCellDelegate?;
    
    var cellIndex:Int = -1;
    var resource:BBEditResource? {
        didSet {
            if let value:BBEditResource = resource
            {
                if (value.resourceId == -1)
                {
                    self.noneStyle(value: value);
                }
                else
                {
                    self.valueStyle(value: value);
                    
                    self.toDownloadFile(value: value);
                }
            }
        }
    }
    
    fileprivate lazy var imageView:UIImageView = {
        let imageView:UIImageView = UIImageView(frame: .zero);
        imageView.contentMode = .scaleAspectFit;
        return imageView;
    }();
    
    fileprivate lazy var lbTitle:UILabel = {
        let label:UILabel = UILabel(frame: .zero);
        label.textAlignment = .center;
        label.textColor = BBHelper.darkGrayTextColor;
        label.font = BBHelper.p12;
        return label;
    }();
    
    fileprivate lazy var ivDownloadIcon:UIImageView = {
        let imageView:UIImageView = UIImageView(frame: .zero);
        imageView.image = UIImage(named: "resource_download");
        imageView.contentMode = .scaleAspectFit;
        imageView.isHidden = true;
        return imageView;
    }();
    
    fileprivate lazy var lbSelector:UILabel = {
        let label:UILabel = UILabel(frame: .zero);
        label.layer.borderWidth = 2.0;
        label.layer.borderColor = UIColor(rgb: 0x17c7c7).cgColor;
        label.isHidden = true;
        return label;
    }();
    
    fileprivate lazy var progressBar:UIProgressView = {
        let progressView:UIProgressView = UIProgressView(progressViewStyle: UIProgressViewStyle.bar);
        progressView.progress = 0.0;
        progressView.isHidden = true;
        return progressView;
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
    
    // MARK: - private methods
    fileprivate func initViews()
    {
        var iconWidth:CGFloat = 24.0;
        if (BBAppParams.shardInstance.deviceSizeType == .kPST_3_5)
        {
            iconWidth = 12.0;
        }
        self.addSubview(self.imageView);
        self.imageView.snp.makeConstraints { (make:ConstraintMaker) in
            make.top.equalTo(self).offset(2.0);
            make.left.right.equalTo(self);
            make.bottom.equalTo(self).offset(-21.0);
        }
        
        self.imageView.addSubview(self.ivDownloadIcon);
        self.ivDownloadIcon.snp.makeConstraints { (make:ConstraintMaker) in
            make.right.bottom.equalTo(self.imageView);
            make.width.height.equalTo(iconWidth);
        }
        
        self.addSubview(self.lbTitle);
        self.lbTitle.snp.makeConstraints { (make:ConstraintMaker) in
            make.top.equalTo(self.imageView.snp.bottom);
            make.left.right.equalTo(self);
            make.height.equalTo(16.0);
        }
        
        self.addSubview(self.progressBar);
        self.progressBar.snp.makeConstraints { (make:ConstraintMaker) in
            make.bottom.equalTo(self).offset(-2.0);
            make.left.right.equalTo(self);
            make.height.equalTo(3.0);
        }
        
        self.addSubview(self.lbSelector);
        self.lbSelector.snp.makeConstraints { (make:ConstraintMaker) in
            make.edges.equalTo(self);
        }
    }
    
    fileprivate func noneStyle(value:BBEditResource)
    {
        self.lbSelector.isHidden = !value.isSelected;
        self.imageView.image = UIImage(named: "none");
        self.ivDownloadIcon.isHidden = true;
        self.lbTitle.text = "无";
    }
    
    fileprivate func valueStyle(value:BBEditResource)
    {
        self.lbSelector.isHidden = !value.isSelected;
        self.lbTitle.text = value.resourceName;
        self.ivDownloadIcon.isHidden = value.isDownloaded;
        self.progressBar.isHidden = !value.isDownLoading;
        self.progressBar.progress = 0.0;
        var placeholderImage:UIImage? = UIImage(named: "about_logo");
        if (value.resourceType == .music)
        {
            placeholderImage = UIImage(named: "music")!;
        }
        self.imageView.kf.setImage(with:URL(string: value.titleImageUrlPath), placeholder: placeholderImage, options: [.transition(ImageTransition.fade(1))], progressBlock: { (receivedSize, totalSize) in
        }, completionHandler: { (image, error, cacheType, imageURL) in
        });
    }
    
    fileprivate func toDownloadFile(value:BBEditResource)
    {
        if (value.isDownLoading)
        {
            value.resourceDownloadFile(progress: { [weak self](progressValue:CGFloat) in
                if let strongSelf = self
                {
                    strongSelf.updateProgress(progressValue: progressValue);
                }
                }, success: { [weak self] in
                    if let strongSelf = self
                    {
                        value.isDownLoading = false;
                        strongSelf.downloadSuccess(value: value);
                    }
                }, failure: { [weak self] (description:String) in
                    if let strongSelf = self
                    {
                        value.isDownLoading = false;
                        strongSelf.downloadFailed(value: value, description:description);
                    }
            })
        }
    }
    
    fileprivate func updateProgress(progressValue:CGFloat)
    {
        DispatchQueue.main.async(execute: {
            self.progressBar.progress = Float(progressValue);
        })
    }
    
    fileprivate func downloadSuccess(value: BBEditResource)
    {
        self.progressBar.isHidden = true;
        self.ivDownloadIcon.isHidden = true;
        self.lbSelector.isHidden = false;
        value.isSelected = true;
        guard let _ = self.delegate?.bbEditResourceCell(resource: value, index:self.cellIndex, didDownloadFinished: true, description: "") else {
            return;
        }
    }
    
    fileprivate func downloadFailed(value:BBEditResource, description:String)
    {
        self.progressBar.isHidden = true;
        self.ivDownloadIcon.isHidden = false;
        self.lbSelector.isHidden = true;
        guard let _ = self.delegate?.bbEditResourceCell(resource: value, index:self.cellIndex, didDownloadFinished: false, description: description) else {
            return;
        }
    }
}
