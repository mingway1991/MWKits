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
    
    UIButton *photoLibraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    photoLibraryButton.frame = CGRectMake(10, 80, 100, 60);
    [photoLibraryButton setTitle:@"相册" forState:UIControlStateNormal];
    [photoLibraryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    photoLibraryButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [photoLibraryButton addTarget:self action:@selector(clickPhotoLibraryButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:photoLibraryButton];
    
    UIButton *previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previewButton.frame = CGRectMake(10, CGRectGetMaxY(photoLibraryButton.frame)+20.f, 100, 60);
    [previewButton setTitle:@"预览" forState:UIControlStateNormal];
    [previewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    previewButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [previewButton addTarget:self action:@selector(clickPreviewButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:previewButton];
}

- (void)clickPhotoLibraryButton {
    NSLog(@"点击相册按钮");
    MWPhotoConfiguration *configuration = [MWPhotoConfiguration defaultPhotoConfiguration];
    configuration.allowSelectImage = YES;
    configuration.allowSelectVideo = YES;
    configuration.allowSelectGif = YES;
    [MWPhotoLibrary showPhotoLibraryWithConfiguration:configuration];
}

- (void)clickPreviewButton {
    NSLog(@"点击预览按钮");
    MWUrlPhotoObject *obj1 = [[MWUrlPhotoObject alloc] init];
    obj1.type = MWPhotoObjectTypeUrl;
    obj1.url = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1545650618518&di=58a0048e5a03f3c5a9de97867f3c9747&imgtype=0&src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F2018-11-03%2F5bdd0f9ec29cc.jpg";
    
    MWUrlPhotoObject *obj2 = [[MWUrlPhotoObject alloc] init];
    obj2.type = MWPhotoObjectTypeUrl;
    obj2.url = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1545650618518&di=b75f3dfd73c48e97fd95f50c4dce21d8&imgtype=0&src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F2018-11-26%2F5bfb63c83c665.jpg";
    
    MWUrlPhotoObject *obj3 = [[MWUrlPhotoObject alloc] init];
    obj3.type = MWPhotoObjectTypeUrl;
    obj3.url = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1545650618518&di=354263c15f80bd561103567348d81063&imgtype=0&src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F2018-11-26%2F5bfb63c99f238.jpg";
    
    NSArray *photoObjects = @[obj1, obj2, obj3];
    
    [MWPhotoLibrary showPhotoPreviewWithPhotoObjects:photoObjects];
}

@end
