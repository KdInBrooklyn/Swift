//
//  ViewController.m
//  自定义非交互式转场动画
//
//  Created by BoBo on 17/2/22.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

#import "ViewController.h"
#import "SecondViewController.h"
#import "CustomAnimator.h"

@interface ViewController ()

//@property (nonatomic, strong) SecondViewController *secondVC;
@property (nonatomic, strong) CustomAnimator *customAniamtor;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.customAniamtor = [[CustomAnimator alloc] init];
//    self.secondVC = [[SecondViewController alloc] init];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)fistButtonDidClick:(UIButton *)sender {
    
//    SecondViewController *secondVC = [[SecondViewController alloc] init];
    SecondViewController *secondVC = [[SecondViewController alloc] initWithNibName:@"SecondViewController" bundle:nil];
    secondVC.transitioningDelegate = self;
    [self presentViewController:secondVC animated:true completion:nil];
    
}

- (IBAction)secondButtonDidClick:(UIButton *)sender {
}

#pragma mark UIViewControllerTransitionDelegate
- (nullable id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.customAniamtor;
}

- (nullable id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.customAniamtor;
}

@end
