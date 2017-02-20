//
//  ViewController.m
//  仿QQ侧滑视图
//
//  Created by BoBo on 17/2/7.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIPanGestureRecognizer *rightPanGes;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor yellowColor];
    self.rightPanGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(UIPanGestureDidMoved)];
    [self.view addGestureRecognizer:self.rightPanGes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma event response
- (void)UIPanGestureDidMoved {
    NSLog(@"........");
}


@end
