//
//  MWGalleryViewController.m
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import "MWGalleryViewController.h"
#import "MWPhotoLibrary.h"
#import "MWGalleryPhotoCell.h"
#import "MWDefines.h"
#import "MWPhotoObject.h"
#import "MWPhotoPreviewViewController.h"
#import "MWPhotoLibraryNavigationController.h"

@import Photos;

static CGFloat kGalleryLeftAndRightMargin = 2.f;
static CGFloat kGalleryTopMargin = 2.f;
static CGFloat kGalleryBottomMargin = 20.f;
static CGFloat kGalleryPhotoSpacing = 2.f;

@interface MWGalleryViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    CGFloat _itemWidth;
}

@property (nonatomic, strong) PHFetchResult<PHAsset *> *photos;
@property (nonatomic, strong) UICollectionView *photosCollectionView;

@end

@implementation MWGalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupParams];
    [self setupUI];
    [self pvt_checkAuthorization];
}

#pragma mark - Setup
- (void)setupParams {
    NSInteger numInRow = 4;
    CGFloat galleryWidth = MWScreenWidth - 2*kGalleryLeftAndRightMargin;
    _itemWidth = floorf((galleryWidth - (numInRow-1)*kGalleryPhotoSpacing)/numInRow);
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.photosCollectionView];
}

#pragma mark - Request Gallery
- (void)pvt_checkAuthorization {
    if (![MWPhotoLibrary cls_checkGalleryAuthorization]) {
        __weak typeof(self) weakSelf = self;
        [MWPhotoLibrary cls_requestGalleryAuthorizationWithCompletionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [weakSelf pvt_fetchAssetCollection];
                } else {
                    [weakSelf pvt_dealAuthorizationFailed];
                }
            });
        }];
    } else {
        [self pvt_fetchAssetCollection];
    }
}

- (void)pvt_dealAuthorizationFailed {
    
}

- (void)pvt_fetchAssetCollection {
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    // 按创建时间升序
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    // 获取所有照片（按创建时间升序）
    self.photos = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
    [self.photosCollectionView reloadData];
    // 获取所有智能相册
//    _smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 获取所有用户创建相册
//    _userCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    //_userCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
}

#pragma mark - UICollectionViewDataSource && UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MWGalleryPhotoCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    PHAsset *asset = [self.photos objectAtIndex:indexPath.item];
    [photoCell updateUIWithAsset:asset imageWidth:_itemWidth];
    return photoCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(_itemWidth, _itemWidth);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *photoObjects = [NSMutableArray arrayWithCapacity:self.photos.count];
    [self.photos enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MWAssetPhotoObject *photoObject = [[MWAssetPhotoObject alloc] init];
        photoObject.type = MWPhotoObjectTypeAsset;
        photoObject.asset = obj;
        [photoObjects addObject:photoObject];
    }];
    MWPhotoPreviewViewController *previewVc = [[MWPhotoPreviewViewController alloc] init];
    previewVc.currentIndex = indexPath.item;
    previewVc.photoObjects = photoObjects;
    
    MWPhotoLibraryNavigationController *navVc = [[MWPhotoLibraryNavigationController alloc] initWithRootViewController:previewVc];
    
    [self presentViewController:navVc animated:YES completion:nil];
}

#pragma mark - LazyLoad
- (UICollectionView *)photosCollectionView {
    if (!_photosCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = kGalleryPhotoSpacing;
        layout.minimumInteritemSpacing = kGalleryPhotoSpacing;
        self.photosCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _photosCollectionView.contentInset = UIEdgeInsetsMake(kGalleryTopMargin, kGalleryLeftAndRightMargin, kGalleryBottomMargin, kGalleryLeftAndRightMargin);
        _photosCollectionView.delegate = self;
        _photosCollectionView.dataSource = self;
        _photosCollectionView.alwaysBounceVertical = YES;
        [_photosCollectionView registerClass:[MWGalleryPhotoCell class] forCellWithReuseIdentifier:@"photoCell"];
        _photosCollectionView.backgroundColor = [UIColor whiteColor];
    }
    return _photosCollectionView;
}

@end
