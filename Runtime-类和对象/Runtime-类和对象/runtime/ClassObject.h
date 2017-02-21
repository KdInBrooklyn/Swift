//
//  ClassObject.h
//  Runtime-类和对象
//
//  Created by BoBo on 17/2/17.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface ClassObject : NSObject<NSCopying, NSCoding>

@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) NSString *string;

+ (void)classMethod1;

- (void)method1;
- (void)method2;

@end
