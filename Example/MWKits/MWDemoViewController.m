//
//  MWDemoViewController.m
//  MWAnimationKit_Example
//
//  Created by 石茗伟 on 2018/9/4.
//  Copyright © 2018年 mingway1991. All rights reserved.
//

#import "MWDemoViewController.h"
@import MWKits;

@interface MWDemoViewController ()

@end

@implementation MWDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPresentAndDismiss];

//      设置页面不可以滑动返回
//    [(MWBaseNavigationController *)self.navigationController setCanDragBack:NO];
    
    self.view.backgroundColor = [UIColor yellowColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 100, 100);
    button.center = self.view.center;
    [button setTitle:@"Dismiss" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(clickDismissButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupPushAndPop];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)clickDismissButton {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
