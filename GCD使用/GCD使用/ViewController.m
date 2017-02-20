//
//  ViewController.m
//  GCD使用
//
//  Created by BoBo on 17/2/20.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ViewController

/**
 1. 和NSOperation Queue一样都是基于队列的并发编程API,它们集中管理大家协同使用的线程池
 2. 公开的5个不同队列: 运行在主线程中的main queue,3个不同优先级的后台队列(High priority Queue, Default Priortity, Low Priority Queue),以及一个优先级更低的后台队列Background Priority Queue(用于I/O)
 3. 可创建自定义队列:串行或并行队列.自定义一般放在Default Priority Queue 和 Main Queue里
 4. 操作是在多线程上还是单线程上,主要是看队列的类型和执行方法,并行队列异步执行才能在多线程,并行队列同步执行只会在主线程执行了
 
 */


#pragma mark life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark private method
- (void)creatGCDQueue {
#pragma mark 全局队列,一个并行的队列
    dispatch_queue_t globalQueue;
    globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
#pragma mark 主队列,主线程中的唯一队列,一个串行队列
    dispatch_queue_t mainQueue;
    mainQueue = dispatch_get_main_queue();
    
#pragma mark 自定义队列
//创建自己定义的队列,可以用dispatch_queue_creat函数,函数有两个参数.第一个参数是自定义队列的名称,第二个参数是队列类型,默认NULL或者DISPATCH_QUEUE_SERIAL 的是串行,参数是DISPATCH_QUEUE_CONCURRENT 为并行队列
    dispatch_queue_t customQueue;
    customQueue = dispatch_queue_create("com.concurrent", DISPATCH_QUEUE_CONCURRENT);
#pragma mark 自定义队列的优先级
    //可以通过dispatch_queue_attr_make_with_qos_class 或 dispatch_set_target_queue 方法设置队列的优先级
    dispatch_queue_t customPriQueue;
    dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_DEFAULT, -1);
    customPriQueue = dispatch_queue_create("com.custom.priority", attr);
    //通过dispatch_set_target_queue来设置优先级,第一个参数是需要设置优先级的queue,第二个参数是目标queue
    dispatch_queue_t customReferQueue = dispatch_queue_create("com.custom.refernce", NULL);
    dispatch_queue_t referQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_set_target_queue(customReferQueue, referQueue);
    
#pragma mark dispatch_once_t
    //dispatch_once_t 为全局变量,保证dispatch_once_t 只有一份实例
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"只执行一次");
    });
    
#pragma mark 在进行一些比较耗时的操作时,需要在另一个线程中处理,完成之后通知主线程更新界面
    //代码框架
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       //耗时操作
        dispatch_async(dispatch_get_main_queue(), ^{
           //会主线程更新UI
        });
    });
    
    //以下载图片的代码为例子
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:@"http://avatar.csdn.net/2/C/D/1_totogo2010.jpg"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = image;
            });
        }
    });
    
#pragma mark dispatch_after 延迟执行
    //dispatch_after只是延时提交block,不是延时立刻执行
    double delayTime = 2.0;
    //dispatch_time的函数原型
    //dispatch_time_t dispatch_time ( dispatch_time_t when, int64_t delta );
    //第一个参数为DISPATCH_TIME_NOW 表示当前,第二个参数的delta表示纳秒,一秒对应的纳秒为100000000,系统提供了一些宏来简化
    /**
     #define NSEC_PER_SEC 1000000000ull //每秒有多少纳秒
     #define USEC_PER_SEC 1000000ull    //每秒有多少毫秒
     #define NSEC_PER_USEC 1000ull      //每毫秒有多少纳秒
     */
    //这样如果想要表示一秒,则可以这样写
    /**
     dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC); dispatch_time(DISPATCH_TIME_NOW, 1000 * USEC_PER_SEC); dispatch_time(DISPATCH_TIME_NOW, USEC_PER_SEC * NSEC_PER_USEC);
     */
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delayTime * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        //需要延时执行的代码块
    });
    
    
#pragma mark dispatch_barrier_async解决多线程,并发读写同一个资源发生死锁
    //在所有先于dispatch barrier的任务都完成的情况下,这个闭包才开始执行.轮到这个闭包时,barrier会执行这个闭包,并且确保队列在此过程不会执行其他任务,闭包完成后队列恢复.需要注意的是:dispatch_barrier_async 只在自己创建的队列上有这种作用,在全局并发队列和串行队列上,效果和dispatch_sync一样
    dispatch_queue_t dataQueu = dispatch_queue_create("com.custom.barrier", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(dataQueu, ^{
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"read data 1");
    });
    
    dispatch_async(dataQueu, ^{
        NSLog(@"read data 2");
    });
    
    dispatch_barrier_async(dataQueu, ^{
        NSLog(@"write data 1");
        [NSThread sleepForTimeInterval:4.0];
    });
    
    dispatch_async(dataQueu, ^{
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"read data 3");
    });
    
    dispatch_async(dataQueu, ^{
        NSLog(@"read data 4");
    });
    
#pragma mark dispatch_apply 进行快速迭代
    //类似for循环,但是在并发队列的情况下 dispatch_apply会并发执行block任务.由于dispatch_apply可以并行执行,所以运行的更快
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(10, concurrentQueue, ^(size_t i) {
        NSLog(@"%zu",i);
    });
    //需要注意的是: dispatch_apply会阻塞主线程的,这个打印会在dispatch_apply都结束后才执行的
    NSLog(@"the end");
    
#pragma mark block组合dispatch_groups
    //dispatch groups是专门用来监视多个异步任务.当group里所有事件都完成之后,GCD API有两种方式发送通知.第一种是dispatch_group_wait,等待所有任务都完成或者等待超时,会阻塞当前线程;第二种是使用dispatch_group_notify,异步执行闭包,不会阻塞当前线程
    dispatch_queue_t oneConcurrentQueue = dispatch_queue_create("com.concurrent.group", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, oneConcurrentQueue, ^{
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"first");
    });
    
    dispatch_group_async(group, oneConcurrentQueue, ^{
        NSLog(@"second");
    });
    //1.使用dispatch_group_wait
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"group finished");
    //2.使用dispatch_group_notify
//    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//        NSLog(@"end");
//    });
//    NSLog(@"continue");
    
#pragma mark dispatch semaphore 信号量的介绍和使用
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"start");
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"semaphore + 1");
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"continue");
}


@end
