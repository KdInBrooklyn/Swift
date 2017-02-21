//
//  NSObject+Swizzling.h
//  Runtime Method Swizzling
//
//  Created by BoBo on 17/2/17.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (Swizzling)

+ (void)methodSwizzlingWithOriginalSelector: (SEL)originalSelector bySwizzlingSelector: (SEL)swizzledSelector;

@end
