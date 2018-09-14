//
//  MWModelDemoViewController.m
//  MWKits_Example
//
//  Created by 石茗伟 on 2018/9/11.
//  Copyright © 2018年 mingway1991. All rights reserved.
//

#import "MWModelDemoViewController.h"
#import "MWWeiboModel.h"
@import MWKits;

@interface MWModelDemoViewController ()

@property (nonatomic, strong) UILabel *descLabel;

@end

@implementation MWModelDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
//    self.descLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
//    self.descLabel.font = [UIFont systemFontOfSize:16.f];
//    self.descLabel.textColor = [UIColor redColor];
//    self.descLabel.numberOfLines = 0;
//    [self.view addSubview:self.descLabel];
    
    int count = 1000;
    NSTimeInterval begin, end;
    NSMutableArray *holder = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        [holder addObject:[NSData new]];
    }
    [holder removeAllObjects];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"weibo" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            MWWeiboStatus *feed = [MWWeiboStatus mw_initWithDictionary:json];
            [holder addObject:feed];
            NSLog(@"%@",[feed mw_convertJsonString]);
        }
    }
    end = CACurrentMediaTime();
    printf("MWModel:     %8.2f   ", (end - begin) * 1000);
}

@end
