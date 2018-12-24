//
//  MWGalleryViewController.m
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import "MWGalleryViewController.h"
#import "MWPhotoManager.h"
#import "MWGalleryPhotoCell.h"
#import "MWDefines.h"
#import "MWPhotoObject.h"
#import "MWPhotoPreviewViewController.h"
#import "MWPhotoNavigationController.h"
#import "PHCachingImageManager+DefaultManager.h"

@import Photos;

static CGFloat kGalleryLeftAndRightMargin = 2.f;
static CGFloat kGalleryTopMargin = 2.f;
static CGFloat kGalleryBottomMargin = 20.f;
static CGFloat kGalleryPhotoSpacing = 2.f;

@interface MWGalleryViewController () <UICollectionViewDataSource,
                                        UICollectionViewDelegate,
                                        UICollectionViewDelegateFlowLayout,
                                        UICollectionViewDataSourcePrefetching,
                                        MWGalleryPhotoCellDelegate> {
    CGFloat _itemWidth;
}

@property (nonatomic, strong) NSArray<PHAsset *> *assets;
@property (nonatomic, strong) UICollectionView *photosCollectionView;
@property (nonatomic, strong) NSMutableArray *selectedAssets;

@end

@implementation MWGalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupParams];
    [self setupUI];
    [self pvt_checkAuthorization];
}

- (void)dealloc {
    PHCachingImageManager *imageManager = [PHCachingImageManager defaultManager];
    [imageManager stopCachingImagesForAllAssets];
}

#pragma mark - Setup
- (void)setupParams {
    NSInteger numInRow = 4;
    CGFloat galleryWidth = MWScreenWidth - 2*kGalleryLeftAndRightMargin;
    _itemWidth = floorf((galleryWidth - (numInRow-1)*kGalleryPhotoSpacing)/numInRow);
    self.selectedAssets = [NSMutableArray array];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self pvt_setupNavigationBarButtons];
    [self.view addSubview:self.photosCollectionView];
}

#pragma mark - NavigationBar
- (void)pvt_setupNavigationBarButtons {
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(clickDoneButton)];
    self.navigationItem.rightBarButtonItems = @[doneItem];
}

#pragma mark - Actions
- (void)clickDoneButton {
    if (self.selectedAssets.count < self.configuration.minSelectCount) {
        NSLog(@"低于最小数量限制");
        return;
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Request Gallery
- (void)pvt_checkAuthorization {
    if (![MWPhotoManager cls_checkGalleryAuthorization]) {
        __weak typeof(self) weakSelf = self;
        [MWPhotoManager cls_requestGalleryAuthorizationWithCompletionHandler:^(BOOL granted) {
            if (granted) {
                [weakSelf pvt_fetchAssetCollection];
            } else {
                [weakSelf pvt_dealAuthorizationFailed];
            }
        }];
    } else {
        [self pvt_fetchAssetCollection];
    }
}

- (void)pvt_dealAuthorizationFailed {
    
}

- (void)pvt_fetchAssetCollection {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
        // 按创建时间升序
        allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO]];
        // 获取所有照片（按创建时间升序）
        PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
        __block NSMutableArray *assets = [NSMutableArray arrayWithCapacity:result.count];
        
        [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.mediaType == PHAssetMediaTypeImage) {
                if ([MWPhotoManager cls_isGifWithAsset:obj]) {
                    if (self.configuration.allowSelectGif) {
                        [assets addObject:obj];
                    }
                } else {
                    if (self.configuration.allowSelectImage) {
                        [assets addObject:obj];
                    }
                }
            } else if (obj.mediaType == PHAssetMediaTypeVideo) {
                if (self.configuration.allowSelectVideo) {
                    [assets addObject:obj];
                }
            }
        }];
        
        self.assets = assets;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.photosCollectionView reloadData];
        });
    });
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
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MWGalleryPhotoCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    PHAsset *asset = [self.assets objectAtIndex:indexPath.item];
    [photoCell updateUIWithAsset:asset imageWidth:_itemWidth isSelect:[self.selectedAssets containsObject:asset]];
    photoCell.delegate = self;
    return photoCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(_itemWidth, _itemWidth);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *photoObjects = [NSMutableArray arrayWithCapacity:self.assets.count];
    [self.assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MWAssetPhotoObject *photoObject = [[MWAssetPhotoObject alloc] init];
        photoObject.type = MWPhotoObjectTypeAsset;
        photoObject.asset = obj;
        [photoObjects addObject:photoObject];
    }];
    MWPhotoPreviewViewController *previewVc = [[MWPhotoPreviewViewController alloc] init];
    previewVc.currentIndex = indexPath.item;
    previewVc.photoObjects = photoObjects;
    
    MWPhotoNavigationController *navVc = [[MWPhotoNavigationController alloc] initWithRootViewController:previewVc];
    
    [self presentViewController:navVc animated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSourcePrefetching
- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    NSMutableArray *assets = [NSMutableArray array];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = [self.assets objectAtIndex:indexPath.item];
        if (asset && asset.mediaType == PHAssetMediaTypeImage) {
            [assets addObject:asset];
        }
    }
    [[PHCachingImageManager defaultManager] startCachingImagesForAssets:assets
                                                             targetSize:CGSizeMake(100.f, 100.f)
                                                            contentMode:PHImageContentModeDefault options:nil];
}

- (void)collectionView:(UICollectionView *)collectionView cancelPrefetchingForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    NSMutableArray *assets = [NSMutableArray array];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = [self.assets objectAtIndex:indexPath.item];
        if (asset && asset.mediaType == PHAssetMediaTypeImage) {
            [assets addObject:asset];
        }
    }
    [[PHCachingImageManager defaultManager] stopCachingImagesForAssets:assets
                                                            targetSize:CGSizeMake(100.f, 100.f)
                                                           contentMode:PHImageContentModeDefault options:nil];
}

#pragma mark - MWGalleryPhotoCellDelegate
- (void)photoCell:(MWGalleryPhotoCell *)photoCell selectAsset:(PHAsset *)asset {
    if (self.selectedAssets.count >= self.configuration.maxSelectCount) {
        NSLog(@"超出数量限制");
        return;
    }
    if ([self.selectedAssets containsObject:asset]) {
        [self.selectedAssets removeObject:asset];
    } else {
        [self.selectedAssets addObject:asset];
    }
    [self.photosCollectionView reloadData];
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
        if (@available(iOS 10.0, *)) {
            _photosCollectionView.prefetchingEnabled = YES;
            _photosCollectionView.prefetchDataSource = self;
        } else {
            // Fallback on earlier versions
        }
    }
    return _photosCollectionView;
}

@end
