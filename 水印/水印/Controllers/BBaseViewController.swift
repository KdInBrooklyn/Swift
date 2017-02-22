//
//  BBaseViewController.swift
//  BoBo
//
//  Created by alimysoyang on 16/6/20.
//  Copyright © 2016年 bobo. All rights reserved.
//

import UIKit
import Foundation

private extension Selector
{
    static let evBaseBarButtonItemClicked = #selector(BBaseViewController.baseBarButtonItemClicked(_:))
    static let evEnterBackgroundNotification = #selector(BBaseViewController.eventEnterBackgroundNotification(_:));
    static let evEnterForegroundNotification = #selector(BBaseViewController.eventEnterForegroundNotification(_:));
}

/**
 *  UIViewController基类，用于继承，封装一些基础方法
 **/
class BBaseViewController: UIViewController
{
    // MARK: - property
    var isPresentViewController:Bool = false;
    
    var isOpenGPS:Bool = false {
        didSet {
            if (isOpenGPS)
            {
                self.startGPS();
            }
            else
            {
                self.stopGPS();
            }
        }
    }
    
    fileprivate var isNTReachable:Bool = true;  //默认网络可用
    fileprivate var coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D();
    fileprivate var locationService:BMKLocationService?;
    fileprivate var search:BMKGeoCodeSearch?;
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent;
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return false;
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation
    {
        return .fade;
    }
    
    // MARK: - life cycle
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        setHideBottomBarWhenPushed()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.edgesForExtendedLayout = UIRectEdge();
        self.view.backgroundColor = UIColor.white;
//        self.initBackItem();
//        CoreStatus.beginNotiNetwork(self);
        
        NotificationCenter.default.addObserver(self, selector: .evEnterBackgroundNotification, name: .UIApplicationDidEnterBackground, object: nil);
        NotificationCenter.default.addObserver(self, selector: .evEnterForegroundNotification, name: .UIApplicationWillEnterForeground, object: nil);
        NotificationCenter.add(self, .ntRestore, #selector(networkRestore))
        NotificationCenter.add(self, .ntDisconnect, #selector(networkDisconnect))
    }

    deinit
    {
//        CoreStatus.endNotiNetwork(self);
        if (self.isOpenGPS)
        {
            self.stopGPS();
        }
        self.stopSearch();
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil);
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil);
        NotificationCenter.remove(self,.ntRestore)
        NotificationCenter.remove(self, .ntDisconnect)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        NotificationCenter.add(self, .enableToOpenLive, #selector(enableToOpenLive))
        NotificationCenter.add(self, .repeatLogin, #selector(repeatLogin))
        NotificationCenter.add(self, .removeFromBlackList, #selector(eventRemoveFromBlacklist(_ :)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.remove(self, .enableToOpenLive)
        NotificationCenter.remove(self, .repeatLogin)
        NotificationCenter.remove(self, .removeFromBlackList)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - public methods
    /**
     网络恢复
     */
    internal func networkRestore()
    {
//        self.isNTReachable = true;
//        BBMsgManager.shardInstance.stopSocket();
//        BBMsgManager.shardInstance.startSocket();
    }
    
    /**
     网络断开
     */
    internal func networkDisconnect()
    {
//        self.isNTReachable = false;
        DispatchQueue.main.async { [weak self] in
            if let strongSelf = self
            {
                strongSelf.view.alert("世界上最遥远的距离就是没有网络", type: .kAVTNone);
            }
        }
    }
    
    // MARK: - GPS
    //GPS服务不可用
    internal func gpsServiceDisabled()
    {
        
    }
    
    internal func gpsServiceNotDetermined()
    {
        
    }
    
    internal func gpsServiceDenied()
    {
        
    }
    
    /**
     GPS定位成功后获得地址
     
     - parameter newAddress: 逆地址数据
     */
    internal func userGpsLocation(_ newAddress:String, cityName:String, coordinate:CLLocationCoordinate2D)
    {
        
    }
    
    internal func userGpsLocationFailed()
    {
        self.stopGPS();
    }
    
    internal func startGPS()
    {
        if (self.gpsServiceAuthorization())
        {
            self.openLocationManager();
        }
    }
    
    internal func stopGPS()
    {
        if let _ = self.locationService
        {
            self.locationService?.stopUserLocationService();
            self.locationService?.delegate = nil;
            self.locationService = nil;
        }
    }
    
    internal func viewControllerRepeatLoginNeedDismiss()
    {
        
    }
    
    // MARK: - event response
    internal func enableToOpenLive()
    {
        alertDialog("系统消息", message: "客服已受理您的申诉,您已可以直播啦~", completion: nil)
    }
    
    internal func repeatLogin()
    {
        if (self.isPresentViewController)
        {
            self.viewControllerRepeatLoginNeedDismiss();
        }
        
        if let app = (UIApplication.shared.delegate as? AppDelegate)
        {
            app.transitionToLoginViewController(isSameUserLogin: true);
        }
    }
    
    func eventRemoveFromBlacklist(_ noti:Notification) {
        if let message = noti.userInfo?["message"] as? String
        {
            alertDialog("系统消息", message: message, completion: nil)
        }
    }
    
    
    internal func baseBarButtonItemClicked(_ sender:UIBarButtonItem)
    {
        let _ = self.navigationController?.popViewController(animated: true);
    }
    
    internal func eventEnterBackgroundNotification(_ notification:Notification)
    {
    
    }
    
    internal func eventEnterForegroundNotification(_ notification:Notification)
    {
    }
    
    internal func resetBackItem()
    {
        var viewControllerArr:[UIViewController] = (self.navigationController?.viewControllers)!;
        let previousVCIndex = viewControllerArr.index(of: self)! - 1;
        var previousVC:UIViewController?
        if (previousVCIndex >= 0) {
            previousVC = viewControllerArr[previousVCIndex];
            previousVC?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil);
        }
    }
    
    internal func titleFadeAnimation(_ title:String)
    {
        UIView.animate(withDuration: 0.2)
        {
            self.title = title
        }
    }
    
    // MARK: - private methods
//    fileprivate func initBackItem()
//    {
//        let backItem:UIBarButtonItem = UIBarButtonItem(title: "返回", style: UIBarButtonItemStyle.Plain, target: self, action: .evBaseBarButtonItemClicked);
//        self.navigationItem.backBarButtonItem = backItem;
//    }
    fileprivate func setHideBottomBarWhenPushed()
    {
        let vc = self as Any
        switch vc
        {
        case is BoBoShowViewController,
             is BBInviteViewController,
             is BBVideoPublishViewController,
             is BBMarketViewController,
             // songhaisheng 2017-1-4
//             is BBUserViewController:
             is BBMicroCourseViewController:
            hidesBottomBarWhenPushed = false
        default:
            hidesBottomBarWhenPushed = true
        }
    }
    // MARK: - GPS相关控制
    fileprivate func gpsServiceAuthorization() -> Bool
    {
        if (!CLLocationManager.locationServicesEnabled())
        {
            self.gpsServiceDisabled();
            return false;
        }
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined)
        {
            self.openLocationManager();
            self.gpsServiceNotDetermined();
            return false;
        }
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied)
        {
            self.gpsServiceDenied();
            return false;
        }
        return true;
    }
    
    fileprivate func openLocationManager()
    {
        if (self.locationService == nil)
        {
            self.locationService = BMKLocationService();
            self.locationService?.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            self.locationService?.delegate = self;
            self.locationService?.startUserLocationService();
        }
    }
    
    fileprivate func startSearch()
    {
        self.stopSearch();
        self.search = BMKGeoCodeSearch();
        self.search?.delegate = self;
        let adder:BMKReverseGeoCodeOption = BMKReverseGeoCodeOption();
        adder.reverseGeoPoint = self.coordinate;
        self.search?.reverseGeoCode(adder);
    }
    
    fileprivate func stopSearch()
    {
        if let _ = self.search
        {
            self.search?.delegate = nil;
            self.search = nil;
        }
    }
}

// MARK: - 网络状态监听
//extension BBaseViewController : CoreStatusProtocol
//{
//    func coreNetworkChangeNoti(_ noti: Notification!) {
//        if (CoreStatus.isNetworkEnable())
//        {
//            if (!self.isNTReachable)
//            {
//                self.networkRestore();
//            }
//        }
//        else
//        {
//            if (self.isNTReachable)
//            {
//                self.networkDisconnect();
//            }
//        }
//    }
//}

// MARK: - BMKLocationServiceDelegate(定位回调)
extension BBaseViewController : BMKLocationServiceDelegate
{
    //用户位置更新后,调用
    func didUpdate(_ userLocation: BMKUserLocation!) {
        self.coordinate = userLocation.location.coordinate;
        self.startSearch();
        self.stopGPS();
    }
    
    func didFailToLocateUserWithError(_ error: Error?) {
        self.userGpsLocationFailed();
    }
}

// MARK: - BMKGeoCodeSearchDelegate(逆地址查询回调)
extension BBaseViewController : BMKGeoCodeSearchDelegate
{
    func onGetReverseGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        if (error == BMK_SEARCH_NO_ERROR)
        {
            let cityName:String = String.optionalToLet(value: result.addressDetail.city, isTrim: true);
            let districtName:String = String.optionalToLet(value: result.addressDetail.district, isTrim: true);
            let addressStr:String = "\(cityName) \(districtName)";
            BBLoginManager.shardInstance.updateUserLocation(addressStr, latitude: self.coordinate.latitude, longitude: self.coordinate.longitude);
            self.userGpsLocation(addressStr, cityName: cityName, coordinate: self.coordinate);
        }
        else if (error == BMK_SEARCH_NETWOKR_ERROR || error == BMK_SEARCH_NETWOKR_TIMEOUT)
        {
            self.userGpsLocationFailed();
        }
        
        self.stopSearch();
    }
}

