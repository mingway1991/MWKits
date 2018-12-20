//
//  MWPhotoLibraryDemoViewController.m
//  MWKits_Example
//
//  Created by 石茗伟 on 2018/12/20.
//  Copyright © 2018 mingway1991. All rights reserved.
//

#import "MWPhotoLibraryDemoViewController.h"

@import MWKits;

@interface MWPhotoLibraryDemoViewController ()

@end

@implementation MWPhotoLibraryDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *testButton = [UIButton buttonWithType:UIButtonTypeCustom];
    testButton.frame = CGRectMake(0, 0, 100, 60);
    [testButton setTitle:@"测试" forState:UIControlStateNormal];
    [testButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    testButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [testButton addTarget:self action:@selector(clickTestButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testButton];
    testButton.center = self.view.center;
}

- (void)clickTestButton {
    NSLog(@"点击测试按钮");
    MWGalleryViewController *vc = [[MWGalleryViewController alloc] init];
    MWPhotoLibraryNavigationController *nav = [[MWPhotoLibraryNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

@end
