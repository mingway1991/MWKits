//
//  MWLabelDemoViewController.m
//  MWKits_Example
//
//  Created by 石茗伟 on 2018/9/18.
//  Copyright © 2018年 mingway1991. All rights reserved.
//

#import "MWLabelDemoViewController.h"
@import MWKits;

@interface MWLabelDemoViewController ()

@property (nonatomic, strong) MWLabel *testLabel;

@end

@implementation MWLabelDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:@"测试文本玩儿体育热武器威尔额外温热污染特维尔同一天热污染同一天热退语音与频率来看扣了开卖了ddwecwecewcweewcwecewcewcewcce" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.f],NSForegroundColorAttributeName:[UIColor redColor]}];
    [attrText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30] range:NSMakeRange(20, 2)];
    
    MWTextData *data = [[MWTextData alloc] init];
    data.text = attrText;
    data.insets = UIEdgeInsetsMake(10, 10, 10, 10);
    data.size = CGSizeMake(100, 100000);
    
    MWLabel *testLabel = [[MWLabel alloc] initWithFrame:CGRectMake(0, 100, 100, data.textBoundingSize.height)];
    testLabel.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    testLabel.attrText = attrText;
    testLabel.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:testLabel];
    self.testLabel = testLabel;
    
    UIButton *testButton = [UIButton buttonWithType:UIButtonTypeCustom];
    testButton.frame = CGRectMake(0, 0, 100, 100);
    testButton.backgroundColor = [UIColor redColor];
    [testButton addTarget:self action:@selector(clickTestButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testButton];
    testButton.center = self.view.center;
}

- (void)clickTestButton {
    MWSetWidth(self.testLabel, 100+random()%100);
    MWSetHeight(self.testLabel, 100+random()%100);
}

@end