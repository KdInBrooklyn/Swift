//
//  AddSubtitleViewController.m
//  VideoEditingPart2
//
//  Created by Abdul Azeem Khan on 3/19/13.
//  Copyright (c) 2013 com.datainvent. All rights reserved.
//

#import "AddSubtitleViewController.h"

@interface AddSubtitleViewController ()

@end

@implementation AddSubtitleViewController

- (IBAction)loadAsset:(id)sender {
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

- (IBAction)generateOutput:(id)sender {
    [self videoOutput];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
    //1 - Set up the text layer
    CATextLayer *subtitleText = [[CATextLayer alloc] init];
    [subtitleText setFont:@"Helvetica-Bold"];
    [subtitleText setFontSize:36];
    [subtitleText setFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
    [subtitleText setString:_subTitle1.text];
    [subtitleText setAlignmentMode:kCAAlignmentCenter];
    [subtitleText setForegroundColor:[[UIColor whiteColor] CGColor]];
    
    //2 - The usual overlay
    CALayer *overlayLayer = [CALayer layer];
    [overlayLayer addSublayer:subtitleText];
    overlayLayer .frame = CGRectMake(0.0, 0.0, size.width, size.height);
    [overlayLayer setMasksToBounds:YES];
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0.0, 0.0, size.width, size.height);
    videoLayer.frame = CGRectMake(0.0, 0.0, size.width, size.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    composition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}


@end
