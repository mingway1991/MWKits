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

@property (nonatomic, strong) UILabel *descLabel;

@end

@implementation MWModelDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.descLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    self.descLabel.font = [UIFont systemFontOfSize:16.f];
    self.descLabel.textColor = [UIColor redColor];
    self.descLabel.numberOfLines = 0;
    [self.view addSubview:self.descLabel];
    
    MWDemoModel *demo = [[MWDemoModel alloc] mw_initWithDictionary:@{@"t_id":@(123),@"names":@[@"a",@"b",@"c"],@"type":@"book",@"test":[NSNull null],@"model":@{@"n_id":@(1),@"name":@"aaa"},@"demos":@[@{@"n_id":@(1),@"name":@"aaa",@"demos":@[@{@"n_id":@(1),@"name":@"aaa"},@{@"n_id":@(1),@"name":@"aaa"}]},@{@"n_id":@(1),@"name":@"aaa",@"demos":@[@{@"n_id":@(1),@"name":@"aaa"},@{@"n_id":@(1),@"name":@"aaa"}]},@{@"n_id":@(1),@"name":@"aaa"}],@"test_bool":@(YES),@"aaaa":@[@"1",@"2"]}];
    self.descLabel.text = [demo mw_convertJsonString];
}

@end
