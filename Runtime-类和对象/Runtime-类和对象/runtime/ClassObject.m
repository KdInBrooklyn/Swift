//
//  ClassObject.m
//  Runtime-类和对象
//
//  Created by BoBo on 17/2/17.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

#import "ClassObject.h"

@interface ClassObject ()
{
    NSInteger _instance1;
    NSString *_instance2;
}

@property (nonatomic, assign) NSUInteger integer;
- (void)methodWithArg1:(NSInteger)arg1 arg2:(NSString *)arg2;

@end

@implementation ClassObject

+ (void)classMethod1 {
    
}

- (void)method1 {
    NSLog(@"call method method1");
}

- (void)method2 {
    
}

- (void)methodWithArg1:(NSInteger)arg1 arg2:(NSString *)arg2 {
    NSLog(@"arg1: %ld, arg2:%@",arg1, arg2);
}







//类相关操作函数
//获取类名(name)
//class_getName(Class cls); //如果传入的cls为Nil,则返回一个字符串

//获取类的父类
//class_getSuperclass(Class cls);      //当cls为Nil或者cls为根类时,返回Nil

//判断给定的Class是否是一个元类
//class_isMetaClass(Class cls);        //如果是返回YES;如果cls为Nil或者不是,则返回NO;

//获取实例大小
//class_getInstanceSize(Class cls);

//关于成员变量(ivars)及属性
//在objc_class中,所有的成员变量,属性的信息是放在链表ivars中的.ivars是一个数组,数组中每个元素是指向Ivar(变量信息)的指针
//获取类中指定名称的实例成员变量的信息
//class_getInstanceVariable(Class cls, const char *name); //返回一个指向包含name指定的成员变量信息的objc_ivar结构体的指针(Ivar)

//Objective-C不支持向已存在的类中添加实例变量.如果我们通过运行时来创建一个类的话,可以使用class_addIvar.但是这个方法只能在objc_allocateClassPair函数与objc_registerClassPair函数之间调用.而且,这个类不能是元类
//class_addIvar(Class cls, const char *name, size_t size, uint8_t alignment, const char *types)

//获取整个成员变量列表


////添加方法
//BOOL class_addMethod(Class cls, SEL name, IMP imp, const char *types);
////获取实例方法
//Method class_getInstanceMethod(Class cls, SEL name);
////获取类方法
//Method class_getClassMethod(Class cls, SEL name);
////获取所有方法的数组
//Method *class_copyMethodList(Class cls, unsigned int *outCount);
////替代方法的实现
//IMP class_replaceMethod(Class cls, SEL name, IMP imp, const char *types);
////返回方法的具体实现
//IMP class_getMethodImplementation(Class cls, SEL name);
//IMP class_getMethodImplementation_stret(Class cls, SEL name);
////类实例是否响应制定的selector
//BOOL class_respondsToSelector(Class cls, SEL sel);
//
//
////添加协议
//BOOL class_addProtocol(Class cls, Protocol *protocol);
////返回类是否实现指定的协议
//BOOL class_conformsToProtocol(Class cls, Protocol *protocol);
////返回类实现的协议列表
//Protocol* class_copyProtocolList(Class cls, unsigned int *outCount);
//
////获取版本号
//int class_getVersion(Class cls);
////设置版本号
//void class_setVersion(Class cls, int version);
























@end
