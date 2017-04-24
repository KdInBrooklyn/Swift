//
//  ViewController.swift
//  GCD-Demo
//
//  Created by BoBo on 2017/4/24.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let semaphore = DispatchSemaphore(value: 2)
        let queue = DispatchQueue.global()
        
        queue.async { [weak self] in
            if let strongSelf = self {
                semaphore.wait()
                strongSelf.usbTask(label: "1", cost: 2, complete: {
                    semaphore.signal()
                })
            }
        }
        
        queue.async { [weak self] in
            if let strongSelf = self {
                semaphore.wait()
                strongSelf.usbTask(label: "2", cost: 3, complete: {
                    semaphore.signal()
                })
            }
        }
        
        queue.async { [weak self] in
            if let strongSelf = self {
                semaphore.wait()
                strongSelf.usbTask(label: "3", cost: 2, complete: {
                    semaphore.signal()
                })
            }
        }
        
        /**
         最简单的死锁
         */
        DispatchQueue.main.sync {
            print("You can not see this log")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func usbTask(label: String, cost: UInt32, complete: @escaping () -> ()) {
        print("Start usb task\(label)")
        sleep(cost)
        print("End usb task\(label)")
        complete()
    }
}

