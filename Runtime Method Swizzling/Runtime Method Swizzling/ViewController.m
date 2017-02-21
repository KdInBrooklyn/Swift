//
//  ViewController.m
//  Runtime Method Swizzling
//
//  Created by BoBo on 17/2/17.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

#import "ViewController.h"
#import "SecondViewController.h"

@interface ViewController ()

@end

@implementation ViewController

//通过Method Swizzling来把系统的方法交换成我们自己的方法,从而给系统方法添加一些我们想要的功能
- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)pushButtonDidClicked:(id)sender {
    SecondViewController *secondVC = [[SecondViewController alloc] init];
    [self presentViewController:secondVC animated:true completion:nil];
}

@end
