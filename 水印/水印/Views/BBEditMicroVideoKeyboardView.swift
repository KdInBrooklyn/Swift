//
//  BBEditMicroVideoKeyboardView.swift
//  BoBo
//
//  Created by alimysoyang on 16/12/13.
//  Copyright © 2016年 bobo. All rights reserved.
//

import Foundation

struct BBCurrentResources
{
    fileprivate var itemAnimation:BBItemSelectedResource = BBItemSelectedResource(index: -1, groupName: "", resourceLocalFilePath:"");
    fileprivate var itemMusic:BBItemSelectedResource = BBItemSelectedResource(index: -1, groupName: "", resourceLocalFilePath:"");
    
    func resource(type:BBEditMicroVideoType) -> BBItemSelectedResource
    {
        if (type == .animation)
        {
            return self.itemAnimation;
        }
        return self.itemMusic;
    }
    
    mutating func change(type:BBEditMicroVideoType, newGroupName:String, newIndex:Int, localFilePath:String)
    {
        if (type == .animation)
        {
            self.itemAnimation.groupName = newGroupName;
            self.itemAnimation.index = newIndex;
            self.itemAnimation.resourceLocalFilePath = localFilePath;
        }
        else if (type == .music)
        {
            self.itemMusic.groupName = newGroupName;
            self.itemMusic.index = newIndex;
            self.itemMusic.resourceLocalFilePath = localFilePath;
        }
    }
    
    mutating func toEmpty(type:BBEditMicroVideoType)
    {
        if (type == .animation)
        {
            self.itemAnimation.empty();
        }
        else if (type == .music)
        {
            self.itemMusic.empty();
        }
    }
}

struct BBItemSelectedResource
{
    var index:Int = -1;
    var groupName:String = "";
    var resourceLocalFilePath:String = "";
    
    var isEmpty:Bool
    {
        get {
            return (self.index == -1);
        }
    }
    
    mutating func empty()
    {
        self.index = -1;
        self.groupName = "";
        self.resourceLocalFilePath = "";
    }
    
    func selectedIndex(count:Int, findGroup:String) -> Int
    {
        let realIndex:Int = self.index - 1;
        if (realIndex >= 0 && realIndex < count && self.groupName == findGroup)
        {
            return realIndex;
        }
        return -1;
    }
}

//MARK: - 短视频资源编辑键盘弹出式界面
class BBEditMicroVideoKeyboardView: UIView 
{
    // MARK: - properties
    var editMicroVideoResourceDownloading:emptyClosure?;
    var editMicroVideoResourceDownloadFailed:descriptionClosure?;
    var editMicroVideoResourceEmpty:countClosure?;
    var editMicroVideoResourceShow:showVideoResourceClosure?;
    var editMicroVideoResourceChangeToAudio:deviceSettingFinished?;
    
    var resourceManager:BBEditResourceManager? {
        didSet {
            self.changeGroup(type: .animation);
        }
    }
    
    var titleViewHeight:CGFloat{
        get {
            if (BBAppParams.shardInstance.deviceSizeType == .kPST_3_5)
            {
                return 28.0;
            }
            return 44.0;
        }
    };
    
    fileprivate var cellItemWidth:CGFloat {
        get {
            return self.frame.size.height - self.titleViewHeight * 2.0 - 2.0;
        }
    }
    
    fileprivate var oldIndex:Int = 0;
    
    fileprivate lazy var typeTitlesView:BBEditMicroVideoGroupTitlesView = { [unowned self] in
        let view:BBEditMicroVideoGroupTitlesView = BBEditMicroVideoGroupTitlesView(frame: CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.titleViewHeight));
        view.tag = 10;
        view.delegate = self;
        return view;
    }();
    
    fileprivate lazy var groupTitlesView:BBEditMicroVideoGroupTitlesView = { [unowned self] in
        let view:BBEditMicroVideoGroupTitlesView = BBEditMicroVideoGroupTitlesView(frame: CGRect(x: 0.0, y: self.frame.size.height - self.titleViewHeight, width: self.frame.size.width, height: self.titleViewHeight));
        view.tag = 11;
        view.delegate = self;
        return view;
    }();
    
    fileprivate lazy var topSeperatorView:UIView = { [unowned self] in
        let view:UIView = UIView(frame: CGRect(x: 0.0, y: self.titleViewHeight, width: self.frame.size.width, height:1.0));
        view.backgroundColor = UIColor(rgb: 0xE7E7E7);
        return view;
    }();
    
    fileprivate lazy var bottomSeperatorView:UIView = { [unowned self] in
        let view:UIView = UIView(frame: CGRect(x: 0.0, y: self.frame.size.height - self.titleViewHeight - 1.0, width: self.frame.size.width, height:1.0));
        view.backgroundColor = UIColor(rgb: 0xE7E7E7);
        return view;
    }();
    
    fileprivate lazy var resourceCollectionView:UICollectionView = { [unowned self] in
        let flowLayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout();
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal;
        flowLayout.itemSize = CGSize(width: self.cellItemWidth, height: self.cellItemWidth);
        flowLayout.minimumLineSpacing = 1.0;
        flowLayout.minimumInteritemSpacing = 1.0;
        
        let collectionView:UICollectionView = UICollectionView(frame: CGRect(x: 0.0, y: self.titleViewHeight + 1.0, width: self.frame.size.width, height: self.cellItemWidth), collectionViewLayout: flowLayout);
        collectionView.register(BBEditResourceCell.classForKeyedArchiver(), forCellWithReuseIdentifier: "BBEditResourceCell");
        collectionView.backgroundColor = UIColor.clear;
        collectionView.showsVerticalScrollIndicator = false;
        collectionView.showsHorizontalScrollIndicator = false;
//        collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        return collectionView;
    }();
    
    fileprivate var resources:[BBEditResource] = [BBEditResource]();
    fileprivate var currentType:BBEditMicroVideoType = .animation;
    fileprivate var currentGroupName:String = "";
    fileprivate var currentResources:BBCurrentResources = BBCurrentResources();
    fileprivate var isDownload:Bool = false;
    
    // MARK: - life cycle
    override init(frame:CGRect)
    {
		super.init(frame:frame);
        
        self.addSubview(self.typeTitlesView);
        self.addSubview(self.topSeperatorView);
        self.addSubview(self.bottomSeperatorView);
        self.addSubview(self.resourceCollectionView);
        self.addSubview(self.groupTitlesView);
        self.typeTitlesView.groupTitles = ["  动图  ", "  音乐  "];
    }
	
    required init?(coder aDecoder:NSCoder)
    {
		super.init(coder:aDecoder);
    }

    deinit
    {
        UIApplication.dLog("release");
    }

    // MARK: - public methods
    internal func resourceMetas() -> BBMicroVideoResourceMetas
    {
        var retVal:BBMicroVideoResourceMetas = BBMicroVideoResourceMetas();
        if (!self.currentResources.itemAnimation.isEmpty)
        {
            retVal.gifPath = self.currentResources.itemAnimation.resourceLocalFilePath;
        }
        if (!self.currentResources.itemMusic.isEmpty)
        {
            retVal.musicPath = self.currentResources.itemMusic.resourceLocalFilePath;
        }
        return retVal;
    }
    
    // MARK: - event response

    // MARK: - private methods
    fileprivate func changeGroup(type:BBEditMicroVideoType, groupName:String = "")
    {
        if let manager:BBEditResourceManager = self.resourceManager
        {
            let selectedResource:BBItemSelectedResource = self.currentResources.resource(type: type);
            self.currentType = type;
            var findGroup:String = groupName;
            if (findGroup.trim().isEmpty)
            {
                if let groupNames:[String] = manager.resourceGroupNames(resourceType: type)
                {
                    self.groupTitlesView.groupTitles = groupNames;
                    findGroup = groupNames[0];
                }
            }
            self.resources.removeAll();
            let emptyResource:BBEditResource = BBEditResource();
            emptyResource.resourceType = type;
            emptyResource.isSelected = selectedResource.isEmpty;
            self.resources.append(emptyResource);
            if let values:[BBEditResource] = manager.resourceGroup(resourceType: type, groupName: findGroup)
            {
                self.resources.append(contentsOf: values);
                let index:Int = selectedResource.selectedIndex(count: values.count, findGroup: findGroup);
                if (index != -1)
                {
                    self.oldIndex = index + 1;
                    values[index].isSelected = true;
                }
                else
                {
                    self.oldIndex = 0;
                }
            }
            self.currentGroupName = findGroup;
            self.resourceCollectionView.reloadData();
        }
    }
    
    fileprivate func clearAllSelector()
    {
        for item in self.resources
        {
            item.isSelected = false;
        }
    }
    
    fileprivate func changeCellSelector(index:Int)
    {
        if (index < 0 || index > self.resources.count)
        {
            return;
        }
        let oldValue:Bool = self.resources[index].isSelected;
        if (oldValue)
        {
            return;
        }
        self.clearAllSelector();
        self.resources[index].isSelected = !oldValue;
    }
}

// MARK: - UICollectionViewDataSource()
extension BBEditMicroVideoKeyboardView : UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.resources.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let CellIdentifer:String = "BBEditResourceCell";
        let cell:BBEditResourceCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifer, for: indexPath) as! BBEditResourceCell;
        
        cell.resource = self.resources[indexPath.row];
        cell.cellIndex = indexPath.row;
        cell.delegate = self;
        return cell;
    }
}

// MARK: - UICollectionViewDelegate
extension BBEditMicroVideoKeyboardView : UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let resource:BBEditResource = self.resources[indexPath.row];
        if (resource.isSelected || self.isDownload)
        {
            return;
        }
        
         self.clearAllSelector();
        if (resource.resourceId == -1)
        {
            self.oldIndex = indexPath.row;
            resource.isSelected = true;
            self.currentResources.toEmpty(type: resource.resourceType);
            if let closure = self.editMicroVideoResourceEmpty
            {
                closure(self.currentType.rawValue);
            }
        }
        else
        {
            if (resource.isDownloaded)
            {
                self.oldIndex = indexPath.row;
                resource.isSelected = true;
                self.currentResources.change(type: resource.resourceType, newGroupName:self.currentGroupName, newIndex: indexPath.row, localFilePath: resource.fullocalPath);
                if let closure = self.editMicroVideoResourceShow
                {
                    closure(resource);
                }
            }
            else
            {
                self.isDownload = true;
                self.groupTitlesView.isDownloading = true;
                self.typeTitlesView.isDownloading = true;
                resource.isDownLoading = true;
            }
        }
        //collectionView.reloadItems(at: [indexPath]);
        collectionView.reloadData();
    }
}


// MARK: - BBEditResourceCellDelegate(Cell回调)
extension BBEditMicroVideoKeyboardView : BBEditResourceCellDelegate
{
    func bbEditResourceCell(resource: BBEditResource, index:Int, didDownloadFinished success: Bool, description: String) {
        self.isDownload = false;
        self.groupTitlesView.isDownloading = false;
        self.typeTitlesView.isDownloading = false;
        var indexPath:IndexPath = IndexPath(item: index, section: 0);
        if (success)
        {
            self.oldIndex = index;
            self.currentResources.change(type: resource.resourceType, newGroupName:self.currentGroupName, newIndex: index, localFilePath: resource.fullocalPath);
            if let closure = self.editMicroVideoResourceShow
            {
                closure(resource);
            }
        }
        else
        {
            let oldValue:BBEditResource = self.resources[self.oldIndex];
            oldValue.isSelected = true;
            indexPath = IndexPath(item: self.oldIndex, section: 0);
            if let closure = self.editMicroVideoResourceDownloadFailed
            {
                closure(description);
            }
        }
        self.resourceCollectionView.reloadItems(at: [indexPath]);
    }
}

// MARK: - BBEditMicroVideoGroupTitlesViewDelegate(标题组件点击回调)
extension BBEditMicroVideoKeyboardView : BBEditMicroVideoGroupTitlesViewDelegate
{
    internal func editMicroVideoGroupTitlesView(view: BBEditMicroVideoGroupTitlesView, didSelectIndex index: Int, didSelectTitle title: String) {
//        if (self.isDownload)
//        {
//            if let closure = self.editMicroVideoResourceDownloading
//            {
//                closure();
//            }
//            return;
//        }
        
        if (view.tag == 10)
        {
            if let type:BBEditMicroVideoType = BBEditMicroVideoType(rawValue: index)
            {
                self.changeGroup(type: type);
                
                if let closure = self.editMicroVideoResourceChangeToAudio
                {
                    closure(type == .music);
                }
            }
        }
        else
        {
            self.changeGroup(type: self.currentType, groupName: title);
        }
    }
}

