//
//  CustomView.m
//  自定义头像
//
//  Created by BoBo on 17/2/20.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

#import "CustomView.h"
#import <CoreGraphics/CoreGraphics.h>

// 自定义圆角头像
@interface  CustomView()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, assign) CGFloat viewCornerRadius;

@end

@implementation CustomView

#pragma mark override super method
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateUI];
}

#pragma mark private method
- (void)initViews {
    self.viewCornerRadius = self.frame.size.width / 2.0;
    self.backgroundColor = [UIColor redColor];
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.layer.mask = self.maskLayer;
    
    [self addSubview:self.imageView];
}

- (void)updateUI {
    self.maskLayer.frame = self.bounds;
    self.maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.viewCornerRadius].CGPath;
    self.layer.cornerRadius = self.viewCornerRadius;
    self.imageView.frame = self.maskLayer.frame;
}

@end
