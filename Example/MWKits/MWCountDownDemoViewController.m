//
//  MWCountDownDemoViewController.m
//  MWKits_Example
//
//  Created by 石茗伟 on 2018/9/10.
//  Copyright © 2018年 mingway1991. All rights reserved.
//

#import "MWCountDownDemoViewController.h"
@import MWKits;

@interface MWCountDownDemoViewController ()

@property (nonatomic, strong) dispatch_source_t time1;
@property (nonatomic, strong) dispatch_source_t time2;

@end

@implementation MWCountDownDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //Demo1
    UILabel *time1Label = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, 100, 60)];
    time1Label.font = [UIFont systemFontOfSize:16.f];
    time1Label.textColor = [UIColor redColor];
    [self.view addSubview:time1Label];
    
//    time1Label.text = [@"111111111" mw_moneyFormat];
    
    NSTimeInterval count1 = 10;
    time1Label.text = [NSString stringWithFormat:@"%@",@(count1)];

    self.time1 = [MWCountdownUtil countDownSeconds:count1 timeInterval:0.5f updateBlock:^(NSTimeInterval timeInterval) {
        NSLog(@"%@",@(timeInterval));
        time1Label.text = [NSString stringWithFormat:@"%@",@(timeInterval)];
    } endBlock:^() {
        time1Label.text = @"结束了";
    }];

    //Demo2
    UILabel *time2Label = [[UILabel alloc] initWithFrame:CGRectMake(10, 240, 100, 60)];
    time2Label.font = [UIFont systemFontOfSize:16.f];
    time2Label.textColor = [UIColor redColor];
    [self.view addSubview:time2Label];

    NSTimeInterval count2 = 10;
    time2Label.text = [NSString stringWithFormat:@"%@",@(count2)];

    self.time2 = [MWCountdownUtil countDownOneSecondForSeconds:count2 updateBlock:^(NSTimeInterval timeInterval) {
        NSLog(@"%@",@(timeInterval));
        time2Label.text = [NSString stringWithFormat:@"%@",@(timeInterval)];
    } endBlock:^{
        time2Label.text = @"结束了";
    }];
}

- (void)dealloc {
    [MWCountdownUtil cancalTimer:_time1];
    [MWCountdownUtil cancalTimer:_time2];
}

@end
