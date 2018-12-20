//
//  MWViewController.m
//  MWKits
//
//  Created by mingway1991 on 09/10/2018.
//  Copyright (c) 2018 mingway1991. All rights reserved.
//

#import "MWViewController.h"
#import "MWDemoViewController.h"
#import "MWCountDownDemoViewController.h"
#import "MWPhotoLibraryDemoViewController.h"
@import MWKits;

@interface MWViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *demoTableView;

@end

@implementation MWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.demoTableView];
    [self mw_setupPresentAndDismiss];
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
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"UINavigationViewController push pop";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"UIViewController present dismiss";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"CountDown倒计时";
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"相册库";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self.navigationController pushViewController:[[MWDemoViewController alloc] init] animated:YES];
    } else if (indexPath.row == 1) {
        [self presentViewController:[[MWDemoViewController alloc] init] animated:YES completion:^{
        }];
    } else if (indexPath.row == 2) {
        [self.navigationController pushViewController:[[MWCountDownDemoViewController alloc] init] animated:YES];
    } else if (indexPath.row == 3) {
        [self.navigationController pushViewController:[[MWPhotoLibraryDemoViewController alloc] init] animated:YES];
    }
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
