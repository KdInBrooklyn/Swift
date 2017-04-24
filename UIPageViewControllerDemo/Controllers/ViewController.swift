//
//  ViewController.swift
//  UIPageViewControllerDemo
//
//  Created by 李森 on 2017/4/23.
//  Copyright © 2017年 李森. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
//    let pageViewController: UIPageViewController? = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: nil)
    
    var currentIndex: Int = 0
    
    fileprivate lazy var pageViewController: UIPageViewController = { [unowned self] in
        let pageVC: UIPageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: nil)
        pageVC.delegate = self
        pageVC.dataSource = self
        
        return pageVC
    }()
    
    let contentVC = [FirstViewController(), SecondViewController(), ThirdViewController()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - private method
    fileprivate func initViews() {
        view.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { (make: ConstraintMaker) in
            make.edges.equalTo(view)
        }
        
        self.addChildViewController(pageViewController)
        pageViewControllerChangeAtIndex(0)
    }
    
    //根据位置坐标返回具体的视图控制器
    fileprivate func viewControllerAtIndex(_ index: Int) -> UIViewController? {
        if (contentVC.count == 0 || index >= contentVC.count) {
            return nil
        }
        return contentVC[index] as UIViewController
    }
    
    //根据视图控制器返回具体的坐标位置
    fileprivate func indexOfViewController(_ vc: UIViewController) -> Int {
        return (contentVC as NSArray).index(of: vc)
    }
    
    //设置初始时的视图
    fileprivate func pageViewControllerChangeAtIndex(_ index: Int) {
        if let vc = viewControllerAtIndex(index) {
            pageViewController.setViewControllers([vc], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        }
    }
}

//MARK: - UIPageViewControllerDataSource
extension ViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        currentIndex = indexOfViewController(viewController)
        if (currentIndex == NSNotFound || currentIndex == 0) {
            return nil
        }
        
        currentIndex -= 1
        return viewControllerAtIndex(currentIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        currentIndex = indexOfViewController(viewController)
        if (currentIndex == NSNotFound) {
            return nil
        }
        
        currentIndex += 1
        
        if (currentIndex == contentVC.count) {
            return nil
        }
        
        return viewControllerAtIndex(currentIndex)
    }
}

//MARK: - UIPageViewControllerDelegate
extension ViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
    }
}
