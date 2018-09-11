//
//  MWModelDemoViewController.m
//  MWKits_Example
//
//  Created by 石茗伟 on 2018/9/11.
//  Copyright © 2018年 mingway1991. All rights reserved.
//

#import "MWModelDemoViewController.h"
#import "MWDemoModel.h"
@import MWKits;

@interface MWModelDemoViewController ()

@end

@implementation MWModelDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    MWDemoModel *demo = [[MWDemoModel alloc] mw_initWithDictionary:@{@"t_id":@(123),@"names":@[@"a",@"b",@"c"],@"type":@"book",@"test":[NSNull null],@"model":@{@"n_id":@(1),@"name":@"aaa"},@"demos":@[@{@"n_id":@(1),@"name":@"aaa"},@{@"n_id":@(1),@"name":@"aaa"},@{@"n_id":@(1),@"name":@"aaa"}],@"test_bool":@(YES),@"date":@"2018-07-31 00:00:00"}];
}

@end
