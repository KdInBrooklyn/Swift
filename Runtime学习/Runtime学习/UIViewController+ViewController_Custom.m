//
//  UIViewController+ViewController_Custom.m
//  Runtime学习
//
//  Created by 李森 on 2017/1/7.
//  Copyright © 2017年 李森. All rights reserved.
//

#import "UIViewController+ViewController_Custom.h"
#import <objc/runtime.h>

@implementation UIViewController (ViewController_Custom)
//load方法会在类第一次加载的时候被调用，调用的时间比较靠前，适合在这个方法里做方法交换
+ (void)load {
    //方法交换应该被保证，在程序中只会执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //获得viewController的生命周期方法的selector
        SEL systemSEL = @selector(viewWillAppear:);
        //自己实现的将要被交换的方法的selector
        SEL customSEL = @selector(custom_viewWillAppear:);
        //两个方法的method
        Method systemMethod = class_getInstanceMethod([self class], systemSEL);
        Method customMethod = class_getInstanceMethod([self class], customSEL);
        //首先动态添加方法，实现是被交换的方法，返回值表示添加成功还是失败
        BOOL isAdd = class_addMethod(self, systemSEL, method_getImplementation(customMethod), method_getTypeEncoding(customMethod));
        if(isAdd) {
            //如果交换成功，说明类中不存在这个方法的实现
            //将被交换方法的实现替换到这个并不存在的实现
            class_replaceMethod(self, customSEL, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
        } else { //否则，交换两个方法的实现
            method_exchangeImplementations(systemMethod, customMethod);
        }
    });
}

- (void)custom_viewWillAppear:(BOOL) animated {
    //这个时候调用自己，看起来像是死循环，但是其实自己的实现已经被替换了
    [self custom_viewWillAppear:animated];
    NSLog(@"替换成功");
}

@end
