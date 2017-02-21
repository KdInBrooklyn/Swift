//
//  main.m
//  Runtime-类和对象
//
//  Created by BoBo on 17/1/9.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ClassObject.h"
#import <objc/runtime.h>

int main(int argc, char * argv[]) {
    @autoreleasepool {
        
        
        ClassObject *myClass = [[ClassObject alloc] init];
        unsigned int outCount = 0;
        Class cls = myClass.class;
        //类名
        NSLog(@"class name: %s",class_getName(cls));
        NSLog(@"===============================================");
        //父类
        NSLog(@"super class name:%@",class_getSuperclass(cls));
        NSLog(@"===============================================");
        //是否是元类
        NSLog(@"MyClass is %@ a meta-class",(class_isMetaClass(cls) ? @"" : @"not"));
        NSLog(@"===============================================");
        Class meta_class = objc_getMetaClass(class_getName(cls));
        NSLog(@"%s's meta_class is %s",class_getName(cls),class_getName(meta_class));
        NSLog(@"===============================================");
        //实例大小
        NSLog(@"instance size %zu", class_getInstanceSize(cls));
        NSLog(@"===============================================");
        //成员变量
        Ivar *ivars = class_copyIvarList(cls, &outCount);
        for (int i = 0; i < outCount; i++) {
            Ivar ivar = ivars[i];
            NSLog(@"===============================================");
        }
        free(ivars);
        
        Ivar string = class_getInstanceVariable(cls, "_string");
        if (string != NULL) {
            NSLog(@"instance variable %s", ivar_getName(string));
        }
        NSLog(@"===============================================");
        //属性操作
        objc_property_t *properties = class_copyPropertyList(cls, &outCount);
        for (int i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            NSLog(@"property's name: %s",property_getName(property));
        }
        free(properties);
        
        objc_property_t array = class_getProperty(cls, "array");
        if (array != NULL) {
            NSLog(@"property:%s",property_getName(array));
        }
        NSLog(@"===============================================");
        
        //方法操作
        
        
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
