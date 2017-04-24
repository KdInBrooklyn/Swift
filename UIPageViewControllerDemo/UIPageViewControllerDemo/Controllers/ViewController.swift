//
//  ViewController.swift
//  UIPageViewControllerDemo
//
//  Created by 李森 on 2017/4/23.
//  Copyright © 2017年 李森. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var currentIndex: Int = 0
    
    fileprivate lazy var headerView: LSHeaderView = {
        let view: LSHeaderView = LSHeaderView(frame: CGRect.zero)
        view.delegate = self
        return view
    }()
    
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
            make.top.equalTo(view).offset(60.0)
            make.left.right.bottom.equalTo(view)
        }
        view.addSubview(headerView)
        headerView.snp.makeConstraints { (make: ConstraintMaker) in
            make.top.left.right.equalTo(view)
            make.height.equalTo(50.0)
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
    //手动滑动时动画在该代理里面完成
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
    }
}

extension ViewController: LSHeaderViewDelegate {
    //通过点击按钮实现滑动时的动画在该方法里面实现
    func lsHeaderViewDidSeleced(_ index: Int) {
        pageViewControllerChangeAtIndex(index)
    }
}
