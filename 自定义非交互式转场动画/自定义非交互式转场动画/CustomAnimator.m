//
//  CustomAnimator.m
//  自定义非交互式转场动画
//
//  Created by BoBo on 17/2/22.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

#import "CustomAnimator.h"

@implementation CustomAnimator 

//设置转场动画时间
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 2.0;
}
//设置转场动画
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = [transitionContext containerView];
    
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    [containerView addSubview:fromView];
    [containerView addSubview:toView];
    toView.alpha = 0.0;
    
    [UIView animateWithDuration:2.0 animations:^{
        toView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:true];
    }];
    
}

@end
