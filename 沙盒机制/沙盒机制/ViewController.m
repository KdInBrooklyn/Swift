//
//  ViewController.m
//  沙盒机制
//
//  Created by BoBo on 17/2/23.
//  Copyright © 2017年 Li Sen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //获取主目录
    NSString *homeDirectory = NSHomeDirectory();
    NSLog(@"homeDirectory:  %@",homeDirectory);
    
    
    NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *documentPath = [documents objectAtIndex:0];
    NSLog(@"documentPath:  %@",documentPath);

    NSArray *cacheDirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true);
    NSString *cachePath = [cacheDirs objectAtIndex:0];
    NSLog(@"cachePath:   %@",cachePath);

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
