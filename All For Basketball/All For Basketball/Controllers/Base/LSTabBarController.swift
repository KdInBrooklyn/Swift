//
//  LSTabBarController.swift
//  All For Basketball
//
//  Created by 李森 on 2017/3/28.
//  Copyright © 2017年 李森. All rights reserved.
//

import UIKit

class LSTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initControllers()
        initTabBars()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - private method
    fileprivate func initControllers() {
        var tabs: [LSNavigationController] = []
        let controllers: [UIViewController] = [LSLivesViewController(), LSNewsViewController(), LSTrainningViewController()]
        for i in 0..<3 {
            let lsTabBarItem: UITabBarItem = UITabBarItem(title: "", image: UIImage(named: "tab_normal_\(i)"), selectedImage: UIImage(named: "tab_highlight_\(i)"))
            let navigation: LSNavigationController = LSNavigationController(rootViewController: controllers[i])
            navigation.tabBarItem = lsTabBarItem
            tabs.append(navigation)
        }
        
        setViewControllers(tabs, animated: true)
    }
    
    fileprivate func initTabBars() {
        
    }
}
