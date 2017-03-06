//
//  AddBorderViewController.m
//  VideoEditingPart2
//
//  Created by Abdul Azeem Khan on 1/24/13.
//  Copyright (c) 2013 com.datainvent. All rights reserved.
//

#import "AddBorderViewController.h"

@interface AddBorderViewController ()

@end

@implementation AddBorderViewController

#pragma mark event response
// 加载视频按钮的点击事件
- (IBAction)loadAsset:(id)sender {
    // 从相册里面获取视频文件
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

// 生成视频按钮的点击事件
- (IBAction)generateOutput:(id)sender {
  [self videoOutput];
}

// 将合成的效果应用到视频上
- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
    UIImage *borderImage = nil;
    
    if (_colorSegment.selectedSegmentIndex == 0) {
        borderImage = [self imageWithColor:[UIColor blueColor] rectSize:CGRectMake(0.0, 0.0, size.width, size.height)];
    } else if (_colorSegment.selectedSegmentIndex == 1) {
        borderImage = [self imageWithColor:[UIColor redColor] rectSize:CGRectMake(0.0, 0.0, size.width, size.height)];
    } else if (_colorSegment.selectedSegmentIndex == 2) {
        borderImage = [self imageWithColor:[UIColor greenColor] rectSize:CGRectMake(0.0, 0.0, size.width, size.height)];
    } else if (_colorSegment.selectedSegmentIndex == 3) {
        borderImage = [self imageWithColor:[UIColor whiteColor] rectSize:CGRectMake(0.0, 0.0, size.width, size.height)];
    }
    
    CALayer *backgroundLayer = [CALayer layer];
    [backgroundLayer setContents:(id)[borderImage CGImage]];
    backgroundLayer.frame = CGRectMake(0.0, 0.0, size.width, size.height);
    [backgroundLayer setMasksToBounds:YES];
    
    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = CGRectMake(_widthBar.value, _widthBar.value, size.width - (_widthBar.value * 2), size.height - (_widthBar.value * 2));
    
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0.0, 0.0, size.width, size.height);
    [parentLayer addSublayer:backgroundLayer];
    [parentLayer addSublayer:videoLayer];
    
    composition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}

#pragma mark 添加的私有方法
// 根据颜色来生成图片
- (UIImage *)imageWithColor: (UIColor *)color rectSize: (CGRect)imageSize {
    CGRect rect = imageSize;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    [color setFill];
    UIRectFill(rect); //Fill with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
