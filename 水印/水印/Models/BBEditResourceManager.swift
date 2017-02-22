//
//  BBEditResourceManager.swift
//  BoBo
//
//  Created by alimysoyang on 16/12/13.
//  Copyright © 2016年 bobo. All rights reserved.
//

import Foundation

// 短视频编辑资源管理对象
class BBEditResourceManager: NSObject 
{
    typealias ResourceItems = [BBEditResource];
    typealias ResourceGroup = [String:ResourceItems];
    typealias ResourceGroups = [ResourceGroup];
    
    // MARK: - properties
    fileprivate var resources:[Int:ResourceGroups] = [Int:ResourceGroups]();
    
    // MARK: - life cycle
    override init()
    {
		super.init();
        
    }
	
    deinit
    {
	
    }

    // MARK: - public methods
    
    internal func parseEditResource(responseObject:JSON)
    {
        //GIF
        self.resources.removeAll();
        self.parseTypePart(responseObject: responseObject, type: .animation);
        
        //music
        self.parseTypePart(responseObject: responseObject, type: .music);
        
        self.loadResources();
    }
    
    
    /// 获取指定资源类型的所有分组名称
    ///
    /// - Parameter resourceType: 资源类型
    /// - Returns: 分组名称数组
    internal func resourceGroupNames(resourceType:BBEditMicroVideoType) -> [String]?
    {
        if let groupValues:ResourceGroups = self.resources[resourceType.rawValue]
        {
            var groupNames:[String] = [String]();
            for group in groupValues
            {
                groupNames.append(contentsOf: [String](group.keys));
            }
            if (groupNames.count == 0)
            {
                return nil;
            }
            return groupNames;
        }
        return nil;
    }
    
    /// 获取指定类型的对应分组的资源列表数据
    ///
    /// - Parameters:
    ///   - resourceType: 类型-GIF，music
    ///   - groupName: 分组名
    /// - Returns: 列表数据
    internal func resourceGroup(resourceType:BBEditMicroVideoType, groupName:String) -> [BBEditResource]?
    {
        if let groupValues:ResourceGroups = self.resources[resourceType.rawValue]
        {
            let group = groupValues.filter({ ($0[groupName] != nil); });
            if group.count > 0
            {
                if let retVal:[BBEditResource] = group[0][groupName], (retVal.count > 0)
                {
                    for item in retVal
                    {
                        item.isSelected = false;
                    }
                    return retVal;
                }
            }
        }
        return nil;
    }
    
    internal func removeDownload(entity:BBEditResource)
    {
        if (entity.isDownloaded)
        {
            String.removeFiles(entity.resourceLocalPath);
            BBLocalDBManager.sharedInstance.deleteEditLocalResource(entity);
            entity.resourceLocalPath = nil;
        }
    }

    // MARK: - event response

    // MARK: - private methods
    fileprivate func loadResources()
    {
        if let localResources:[BBEditLocalResource] = BBLocalDBManager.sharedInstance.loadEditLocalResources()
        {
            for localItem in localResources
            {
                if let groupNames:[String] = self.resourceGroupNames(resourceType: localItem.resourceType)
                {
                    for groupName in groupNames
                    {
                        if let resources:ResourceItems = self.resourceGroup(resourceType: localItem.resourceType, groupName: groupName)
                        {
                            for item in resources
                            {
                                if (item.resourceId == localItem.resourceId)
                                {
                                    item.resourceLocalPath = localItem.resourceLocalPath;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func parseTypePart(responseObject:JSON, type:BBEditMicroVideoType)
    {
        let typeKey:String = String(type.rawValue + 1);
        if (responseObject["data"][typeKey].exists())
        {
            if let groups:[JSON] = responseObject["data"][typeKey].array
            {
                var tmpGroups:ResourceGroups = ResourceGroups();
                for group in groups
                {
                    if let groupName:String = group["title"].string
                    {
                        if let items:[JSON] = group["resource_list"].array
                        {
                            var tmpItems:ResourceItems = ResourceItems();
                            for item in items
                            {
                                let resource:BBEditResource = BBEditResource(data: item, type: type);
                                tmpItems.append(resource);
                            }
                            if (tmpItems.count > 0)
                            {
                                var tmpGroup:ResourceGroup = ResourceGroup();
                                tmpGroup[groupName] = tmpItems;
                                tmpGroups.append(tmpGroup);
                            }
                        }
                    }
                }
                if (tmpGroups.count > 0)
                {
                    self.resources[type.rawValue] = tmpGroups;
                }
            }
        }
    }
}
