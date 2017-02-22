//
//  SecondViewController.m
//  自定义非交互式转场动画
//
//  Created by BoBo on 17/2/22.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonDidClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
