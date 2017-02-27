//
//  AddOverlayViewController.m
//  VideoEditingPart2
//
//  Created by Abdul Azeem Khan on 1/24/13.
//  Copyright (c) 2013 com.datainvent. All rights reserved.
//

#import "AddOverlayViewController.h"

@interface AddOverlayViewController ()

@end

@implementation AddOverlayViewController

- (IBAction)loadAsset:(id)sender {
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

- (IBAction)generateOutput:(id)sender {
  [self videoOutput];
}

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
    //1 - set up the overlay
    CALayer *overLayer = [CALayer layer];
    UIImage *overLayerImage = nil;
    if (_frameSelectSegment.selectedSegmentIndex == 0) {
        overLayerImage = [UIImage imageNamed:@"Frame-1.png"];
    } else if (_frameSelectSegment.selectedSegmentIndex == 1) {
        overLayerImage = [UIImage imageNamed:@"Frame-2.png"];
    } else if (_frameSelectSegment.selectedSegmentIndex == 2) {
        overLayerImage = [UIImage imageNamed:@"Frame-3.png"];
    }
    
    [overLayer setContents:(id)[overLayerImage CGImage]];
    overLayer.frame = CGRectMake(0.0, 0.0, size.width, size.height);
    [overLayer setMasksToBounds:YES];
    
    //2 - set up the parent layer
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0.0, 0.0, size.width, size.height);
    videoLayer.frame = CGRectMake(0.0, 0.0, size.width, size.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overLayer];
    
    //3 - apply magic
    composition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}

@end
