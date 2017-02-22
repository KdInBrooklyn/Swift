//
//  BBEditMicroVideoGroupTitlesView.swift
//  BoBo
//
//  Created by alimysoyang on 16/12/19.
//  Copyright © 2016年 bobo. All rights reserved.
//

import Foundation

@objc protocol BBEditMicroVideoGroupTitlesViewDelegate
{
    func editMicroVideoGroupTitlesView(view:BBEditMicroVideoGroupTitlesView, didSelectIndex index:Int, didSelectTitle title:String);
}

//MARK: - 头部标题选择器
class BBEditMicroVideoGroupTitlesView: UIView
{
    // MARK: - properties
    weak var delegate:BBEditMicroVideoGroupTitlesViewDelegate?;
    
    var isDownloading:Bool = false;
    
    var groupTitles:[String]? {
        didSet {
            self.groupScrollView.removeAllViews();
            self.groupScrollView.addSubview(self.selectorView);
            if let titles:[String] = groupTitles
            {
                self.count = titles.count;
                self.createTitleViews(titles: titles);
                self.selectedIndex = 0;
            }
        }
    }
    
    fileprivate let kViewTag:Int = 7000;
    fileprivate var spaceWidth:CGFloat = 20.0;
    fileprivate var count:Int = 0;
    fileprivate var selectedIndex:Int = -1 {
        didSet {
            self.clearStatus();
            if let button:UIButton = self.groupScrollView.viewWithTag(self.kViewTag + selectedIndex) as? UIButton
            {
                button.isSelected = true;
                self.selectorView.frame = CGRect(x: button.frame.origin.x, y: self.frame.size.height - 2.0, width: button.frame.size.width, height: 2.0);
            }
            
        }
    }
    
    
    fileprivate lazy var groupScrollView:UIScrollView = { [unowned self] in
        let scrollView:UIScrollView = UIScrollView(frame: CGRect(origin: CGPoint.zero, size: self.frame.size));
        scrollView.showsVerticalScrollIndicator = false;
        scrollView.showsHorizontalScrollIndicator = false;
        return scrollView;
        }();
    
    fileprivate lazy var selectorView:UIView = {
        let view:UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 2));
        view.backgroundColor = BBHelper.mainColor;
        return view;
    }();
    
    // MARK: - life cycle
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.addSubview(self.groupScrollView);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    deinit {
        self.delegate = nil;
    }
    
    // MARK: - public methods
    
    // MARK: - event response
    internal func eventButtonClicked(sender:UIButton)
    {
        if (self.isDownloading)
        {
            return;
        }
        let index:Int = sender.tag - self.kViewTag;
        if (self.selectedIndex != index)
        {
            self.selectedIndex = index;
            let title:String = sender.title(for: .normal) ?? "";
            guard let _ = self.delegate?.editMicroVideoGroupTitlesView(view: self, didSelectIndex: index, didSelectTitle: title) else {
                return;
            }
        }
    }
    
    // MARK: - private methods
    fileprivate func createTitleViews(titles:[String])
    {
        var offSetX:CGFloat = 0.0;
        for (index, item) in titles.enumerated()
        {
            let width:CGFloat = self.createButton(offSetX: offSetX, index: index, title: item);
            offSetX += width;
        }
        self.groupScrollView.contentSize = CGSize(width: offSetX, height: self.frame.size.height);
    }
    
    fileprivate func createButton(offSetX:CGFloat, index:Int, title:String) -> CGFloat
    {
        let titleSize:CGSize = BBHelper.labelSize(BBHelper.p14, maxSize: CGSize(width: UIView.kScreenWidth, height: CGFloat.greatestFiniteMagnitude), text: title);
        let width:CGFloat = titleSize.width + self.spaceWidth;
        let button:UIButton = UIButton(frame: CGRect(x: offSetX , y: 0.0, width: width, height: self.frame.size.height - 2.0));
        button.titleLabel?.font = BBHelper.p14;
        button.setTitle(title, for: .normal);
        button.setTitleColor(BBHelper.darkGrayTextColor, for: .normal);
        button.setTitleColor(BBHelper.mainColor, for: .selected);
        button.isSelected = (self.selectedIndex == index);
        button.tag = self.kViewTag + index;
        button.addTarget(self, action: #selector(BBEditMicroVideoGroupTitlesView.eventButtonClicked(sender:)), for: .touchUpInside);
        self.groupScrollView.addSubview(button);
        return width;
    }
    
    fileprivate func clearStatus()
    {
        for index in 0..<self.count
        {
            if let button:UIButton = self.groupScrollView.viewWithTag(self.kViewTag + index) as? UIButton
            {
                button.isSelected = false;
            }
        }
    }
}
