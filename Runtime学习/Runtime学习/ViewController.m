//
//  ViewController.m
//  Runtime学习
//
//  Created by 李森 on 2017/1/6.
//  Copyright © 2017年 李森. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController ()<UINavigationBarDelegate>
{
@private NSUInteger countTest;
}

@property (nonatomic, copy) NSString *property5;
@property (nonatomic, copy) NSString *property6;
@property (nonatomic, copy) NSString *property7;
@property (nonatomic, copy) NSString *property8;

@end

@implementation ViewController

#pragma mark life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getproerties];
}

//检测方法替换是否成功
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark private method
- (void)getproerties {
    unsigned int count;
    //获取属性列表
    NSLog(@"--------获取属性------------");
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (unsigned int i = 0 ; i < count; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        NSLog(@"property--------------%s",propertyName);
    }
    
    //获取方法列表
    NSLog(@"-------获取方法列表-----------");
    Method *methodList = class_copyMethodList([self class], &count);
    for (unsigned int i = 0 ; i < count; i++) {
        Method method = methodList[i];
        NSString *methodName = NSStringFromSelector(method_getName(method));
        NSLog(@"method-----------------%@",methodName);
    }
    
    //获取成员变量列表
    NSLog(@"-------获取成员变量列表------------");
    Ivar *ivarList = class_copyIvarList([self class], &count);
    for (unsigned int i = 0; i < count; i++) {
        const char *ivarName = ivar_getName(ivarList[i]);
        NSLog(@"ivarList----------------%s",ivarName);
    }
    
    //获取协议列表
    NSLog(@"-------------获取协议列表");
    __unsafe_unretained Protocol **protocolList = class_copyProtocolList([self class], &count);
    for (unsigned int i = 0; i < count; i++) {
        Protocol *protocal = protocolList[i];
        const char *protocolName = protocol_getName(protocal);
        NSLog(@"protocol---------------%s",protocolName);
        
    }
    
}

- (void)testMethod {
    
}

@end
