//
//  ViewController.m
//  自定义头像
//
//  Created by BoBo on 17/2/20.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

#import "ViewController.h"
#import "CustomView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CustomView *cView = [[CustomView alloc] initWithFrame:CGRectMake(0.0, 200.0, 30.0, 30.0)];
    [self.view addSubview:cView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
