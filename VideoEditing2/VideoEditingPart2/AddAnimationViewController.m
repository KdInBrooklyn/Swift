//
//  AddAnimationViewController.m
//  VideoEditingPart2
//
//  Created by Abdul Azeem Khan on 1/24/13.
//  Copyright (c) 2013 com.datainvent. All rights reserved.
//

#import "AddAnimationViewController.h"

@interface AddAnimationViewController ()

@end

@implementation AddAnimationViewController

- (IBAction)loadAsset:(id)sender {
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

- (IBAction)generateOutput:(id)sender {
  [self videoOutput];
}

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
    UIImage *animationImage = [UIImage imageNamed:@"star.png"];
    CALayer *overlayLayer = [CALayer layer];
    [overlayLayer setContents:(id)[animationImage CGImage]];
    overlayLayer.frame = CGRectMake(size.width / 2.0 - 64, size.height / 2.0 - 200, 128, 128);
    [overlayLayer setMasksToBounds:YES];
}

@end
