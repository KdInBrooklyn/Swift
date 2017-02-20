//
//  UIViewController+Swizzling.m
//  Runtime Method Swizzling
//
//  Created by BoBo on 17/2/17.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

#import "UIViewController+Swizzling.h"
#import "NSObject+Swizzling.h"

@implementation UIViewController (Swizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    _dispatch_once(&onceToken, ^{
        [self methodSwizzlingWithOriginalSelector:@selector(viewWillAppear:) bySwizzlingSelector:@selector(sure_viewWillAppear:)];
    });
}

- (void)sure_viewWillAppear: (BOOL)animated {
    [self sure_viewWillAppear:animated];
    
    NSLog(@"方法交换成功");
}

@end
