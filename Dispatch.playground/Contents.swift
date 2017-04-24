//: Playground - noun: a place where people can play

import UIKit
import Dispatch

var str = "Hello, playground"


/**
 Dispatch会自动地根据CPU的使用情况,创建线程来执行任务,并且自动地运行到多核上,提高程序的运行效率.对于开发者来说GCD层面是没有线程的概念,只有队列(queue).任务都是以block的方式提交到队列上,然后GCD会自动的创建线程池去执行这些任务.
 */

/**使用默认配置创建的队列*/
//let queue = DispatchQueue(label: "com.demoQueue")

/**显示指明队列的其他属性*/
let label = "com.demoQueue"  //队列的标识符,方便调试
let qos = DispatchQoS.default  //队列执行的优先级
let attributes = DispatchQueue.Attributes.concurrent  //队列的属性
let autoreleaseFrequency = DispatchQueue.AutoreleaseFrequency.never //自动释放频率
let queue = DispatchQueue(label: label, qos: qos, attributes: attributes, autoreleaseFrequency: autoreleaseFrequency, target: nil)

/**
 队列的分类
 
  1. 系统创建的队列
     主队列(对应主线程)
     全局队列
  2. 用户创建的队列
 */

//获取主队列/全局队列
let mainQueue = DispatchQueue.main
let globalQueue = DispatchQueue.global()
let globalQueueWithQos = DispatchQueue.global(qos: .default)

//创建串行队列
let serialQueue = DispatchQueue(label: "com.serial.demoQueue")
//创建并行队列
let concurrentQueue = DispatchQueue(label: "com.concurrent.demoQueue", attributes: .concurrent)

/**
 async异步执行任务
 sync同步执行任务
 */

/**
 QoS
 
 QoS全称是quality of service,它是一个结构体,用来指定队列或者任务的重要性.
 一共有四个等级:
 1. User Interactive: 和用户交互相关,优先级最高
 2. User Initiated: 需要立刻的结果
 3. Utility: 可以执行很长时间,再通知用户结果.比如下载一个文件,给用户下载进度
 4. Background: 用户不可见,比如在后台存储大量数据
 */
//指定QoS有以下两种方式:
//1. 创建一个指定QoS的queue
let qosQueue = DispatchQueue(label: "com.qos.demoQueue", qos: .background)
qosQueue.async {
    
}

//2. 在提交block的时候,指定qos
let qosQueue2 = DispatchQueue(label: "com.qos2.demoQueue")
qosQueue2.async(qos: .background) {
    
}

/**
 DispatchWorkItem
 
 上面提到的方式,都是以block的形式提交任务的,DispatchWorkItem则把任务封装成了一个对象
 */

//
let item = DispatchWorkItem { 
    //任务
}
DispatchQueue.global().async(execute: item)

//在初始化时指定更多的参数
//第二个参数类型为DispatchWorkItemFlags,指定这个任务的配饰信息,DispatchWorkItemFlags的参数分为两组
//执行情况: 1.barrier; 2.detached; 3.assignCurrentContext
//Qos覆盖信息: 1.noQoS(没有QoS); 2.inheritQos(继承Queue的QoS); 3.enforceQoS(自己的QoS覆盖Queue)
let item2 = DispatchWorkItem(qos: DispatchQoS.default, flags: [.enforceQoS, .assignCurrentContext]) {
    //任务
}
DispatchQueue.global().async(execute: item2)

/**
 延迟执行
 
 GCD可以通过asyncAfter和syncAfter来提交一个延迟执行的任务
 */
let deadLine = DispatchTime.now() + 2.0 //使用DispatchTime,精度是纳秒
print("start")
DispatchQueue.global().asyncAfter(deadline: deadLine) { 
    print("end")
}

let wallTime = DispatchWallTime.now() + 2.0 //使用DispatchWallTime,精度是微秒
print("start")
DispatchQueue.global().asyncAfter(wallDeadline: wallTime) { 
    print("end")
}


/**
 DispatchGroup
 */

/**
 Semaphore
 DispatchSemaPhore是传统技术信号量的封装,用来控制资源被多任务访问的情况
 */

public func usbTask(label: String, cost: UInt32, complete: @escaping () -> ()) {
    print("Start usb task\(label))")
    sleep(cost)
    print("End usb task\(label)")
    complete()
}

//PlaygroundPage.current.needsIndefiniteExecution = true
print("DispatchGroup created")

let semaphore = DispatchSemaphore(value: 2)
queue.async {
    semaphore.wait()
    usbTask(label: "1", cost: 2, complete: { 
        semaphore.signal()
    })
}


queue.async {
    semaphore.wait()
    usbTask(label: "2", cost: 4, complete: { 
        semaphore.signal()
    })
}

queue.async {
    semaphore.wait()
    usbTask(label: "3", cost: 2, complete: { 
        semaphore.signal()
    })
}
