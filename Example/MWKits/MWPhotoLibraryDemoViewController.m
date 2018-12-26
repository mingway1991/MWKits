//
//  MWPhotoLibraryDemoViewController.m
//  MWKits_Example
//
//  Created by 石茗伟 on 2018/12/20.
//  Copyright © 2018 mingway1991. All rights reserved.
//

#import "MWPhotoLibraryDemoViewController.h"

@import MWKits;

@interface MWPhotoLibraryDemoViewController () <UICollectionViewDataSource,
                                                UICollectionViewDelegate,
                                                UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *photosCollectionView;
@property (nonatomic, strong) NSArray<MWPhotoObject *> *photoObjects;

@end

@implementation MWPhotoLibraryDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.photosCollectionView];
    
    UIButton *photoLibraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    photoLibraryButton.frame = CGRectMake(10, 80, 100, 60);
    [photoLibraryButton setTitle:@"相册" forState:UIControlStateNormal];
    [photoLibraryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    photoLibraryButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [photoLibraryButton addTarget:self action:@selector(clickPhotoLibraryButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:photoLibraryButton];
    
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.frame = CGRectMake(120, 80, 100, 60);
    [cameraButton setTitle:@"相机" forState:UIControlStateNormal];
    [cameraButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cameraButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [cameraButton addTarget:self action:@selector(clickCameraButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraButton];
}

- (void)clickPhotoLibraryButton {
    NSLog(@"点击相册按钮");
    MWPhotoConfiguration *configuration = [MWPhotoConfiguration defaultPhotoConfiguration];
    configuration.allowSelectImage = YES;
    configuration.allowSelectVideo = YES;
    configuration.allowSelectGif = YES;
    configuration.minSelectCount = 0;
    configuration.maxSelectCount = 9;
    configuration.navBarColor = [UIColor colorWithRed:255/255.f green:106/255.f blue:106/255.f alpha:1.0];
    configuration.navTitleColor = [UIColor whiteColor];
    __weak typeof(self) weakSelf = self;
    configuration.selectCompletionBlock = ^(NSArray<MWPhotoObject *> *photoObjects, NSArray<PHAsset *> *assets, NSArray<UIImage *> *images) {
        weakSelf.photoObjects = photoObjects;
        [weakSelf.photosCollectionView reloadData];
    };
    configuration.cancelSelectCompletionBlock = ^{
        
    };
    [MWPhotoLibrary showPhotoLibraryWithConfiguration:configuration];
}

- (void)clickCameraButton {
    MWPhotoConfiguration *configuration = [MWPhotoConfiguration defaultPhotoConfiguration];
    configuration.allowSelectImage = YES;
    configuration.allowSelectVideo = YES;
    configuration.allowSelectGif = YES;
    configuration.minSelectCount = 0;
    configuration.maxSelectCount = 9;
    configuration.navBarColor = [UIColor colorWithRed:255/255.f green:106/255.f blue:106/255.f alpha:1.0];
    configuration.navTitleColor = [UIColor whiteColor];
    __weak typeof(self) weakSelf = self;
    configuration.selectCompletionBlock = ^(NSArray<MWPhotoObject *> *photoObjects, NSArray<PHAsset *> *assets, NSArray<UIImage *> *images) {
        weakSelf.photoObjects = photoObjects;
        [weakSelf.photosCollectionView reloadData];
    };
    configuration.cancelSelectCompletionBlock = ^{
        
    };
    [MWPhotoLibrary showCameraWithConfiguration:configuration];
}

#pragma mark - UICollectionViewDataSource && UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    photoCell.backgroundColor = [UIColor yellowColor];
    return photoCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(30, 30);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MWPhotoConfiguration *configuration = [MWPhotoConfiguration defaultPhotoConfiguration];
    configuration.minSelectCount = 0;
    configuration.maxSelectCount = 9;
    configuration.navBarColor = [UIColor colorWithRed:255/255.f green:106/255.f blue:106/255.f alpha:1.0];
    configuration.navTitleColor = [UIColor whiteColor];
    __weak typeof(self) weakSelf = self;
    configuration.selectCompletionBlock = ^(NSArray<MWPhotoObject *> *photoObjects, NSArray<PHAsset *> *assets, NSArray<UIImage *> *images) {
        weakSelf.photoObjects = photoObjects;
        [weakSelf.photosCollectionView reloadData];
    };
    configuration.cancelSelectCompletionBlock = ^{
        
    };
    [MWPhotoLibrary showPhotoPreviewWithConfiguration:configuration photoObjects:self.photoObjects index:indexPath.item];
//    [MWPhotoLibrary showPhotoPreviewForSelectWithConfiguration:configuration photoObjects:self.photoObjects index:indexPath.item];
}

#pragma mark - LazyLoad
- (UICollectionView *)photosCollectionView {
    if (!_photosCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 10.f;
        layout.minimumInteritemSpacing = 10.f;
        self.photosCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 250, MWScreenWidth, 300) collectionViewLayout:layout];
        _photosCollectionView.backgroundColor = [UIColor whiteColor];
        _photosCollectionView.delegate = self;
        _photosCollectionView.dataSource = self;
        [_photosCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _photosCollectionView;
}

@end
