//
//  ViewController.h
//  Runtime学习
//
//  Created by 李森 on 2017/1/6.
//  Copyright © 2017年 李森. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+ViewController_Custom.h"

@interface ViewController : UIViewController<UINavigationControllerDelegate>

@property (nonatomic, copy) NSString *property1;
@property (nonatomic, copy) NSString *property2;
@property (nonatomic, copy) NSString *property3;
@property (nonatomic, copy) NSString *property4;

- (void)testMethod;

@end

