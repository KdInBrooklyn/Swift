//
//  ViewController.m
//  Runtime-类和对象
//
//  Created by BoBo on 17/1/9.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self ex_registerClassPair];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

void testMetaClass(id self, SEL _cmd) {
    NSLog(@"This object is %p",self);
    NSLog(@"Class is %@, super class is %@",[self class], [self superclass]);
    Class currentClass = [self class];
    for (int i = 0; i < 4; i++) {
        NSLog(@"Following the isa pointer %d times gives %p", i, currentClass);
        currentClass = objc_getClass((__bridge void*)currentClass);
    }
    NSLog(@"NSObject's class is %p",[NSObject class]);
    NSLog(@"NSObject's meta class is %p",objc_getClass((__bridge void*)[NSObject class]));
}

- (void) ex_registerClassPair {
    Class newClass = objc_allocateClassPair([NSError class], "testClass", 0);
    class_addMethod(newClass, @selector(testMetaClass), (IMP)testMetaClass, "v@:");
    objc_registerClassPair(newClass);
    id instance = [[newClass alloc] initWithDomain:@"some domain" code:0 userInfo:nil];
    [instance performSelector:@selector(testMetaClass)];
}

@end
