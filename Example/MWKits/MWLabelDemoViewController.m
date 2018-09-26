//
//  MWLabelDemoViewController.m
//  MWKits_Example
//
//  Created by 石茗伟 on 2018/9/18.
//  Copyright © 2018年 mingway1991. All rights reserved.
//

#import "MWLabelDemoViewController.h"
@import MWKits;

@interface MWLabelDemoViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_dataSource;
}
@property (nonatomic, strong) UITableView *demoTableView;

@end

@implementation MWLabelDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self mw_setupPresentAndDismiss];
    
    _dataSource = [NSMutableArray arrayWithCapacity:1000];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (NSInteger i = 0; i<1000; i++) {
            NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:@"测试文本玩儿体育热武器威尔额外温热污染特维尔同一天热污染同一天热退语音与频率来看扣了开卖了ddwecwecewcweewcwecewcewcewcce未拆封二二而突然\n都是扯淡差点说成多层次市场上" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.f],NSForegroundColorAttributeName:[UIColor redColor]}];
            [attrText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30] range:NSMakeRange(20, 2)];
            
            NSMutableParagraphStyle *paragh = [NSMutableParagraphStyle new];
            paragh.lineSpacing = 2;
            paragh.paragraphSpacing = 10;
            [attrText addAttribute:NSParagraphStyleAttributeName value:paragh range:NSMakeRange(0, attrText.length)];
            
            MWTextData *data = [[MWTextData alloc] init];
            data.attrText = attrText;
            data.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
            data.maxSize = CGSizeMake(MWScreenWidth, 1000);
            data.numberOfLines = 0;
            data.textAlignment = NSTextAlignmentCenter;
            [_dataSource addObject:data];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.demoTableView reloadData];
        });
    });
    
    [self.view addSubview:self.demoTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self mw_setupPushAndPop];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_dataSource[indexPath.row] textBoundingSize].height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        MWLabel *testLabel = [[MWLabel alloc] init];
        testLabel.tag = 1000;
        [cell addSubview:testLabel];
    }
    MWLabel *testLabel = [cell viewWithTag:1000];
    testLabel.frame =  CGRectMake(0, 0, [_dataSource[indexPath.row] textBoundingSize].width, [_dataSource[indexPath.row] textBoundingSize].height);
    [testLabel updateWithData:_dataSource[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Lazy Load
- (UITableView *)demoTableView {
    if (!_demoTableView) {
        self.demoTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _demoTableView.delegate = self;
        _demoTableView.dataSource = self;
    }
    return _demoTableView;
}

@end
