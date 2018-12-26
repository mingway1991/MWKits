//
//  MWGalleryViewController.m
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import "MWGalleryViewController.h"
#import "MWAssetManager.h"
#import "MWGalleryPhotoCell.h"
#import "MWDefines.h"
#import "MWPhotoObject.h"
#import "MWPhotoPreviewViewController.h"
#import "PHCachingImageManager+DefaultManager.h"
#import "UIImage+FixOrientation.h"

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

@property (nonatomic, strong) NSArray<MWAssetPhotoObject *> *assetObjects;
@property (nonatomic, strong) UICollectionView *photosCollectionView;
@property (nonatomic, strong) UIButton *doneButton;

@end

@implementation MWGalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupParams];
    [self setupUI];
    [self pvt_fetchAssetCollection];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.photosCollectionView reloadData];
    [self pvt_updateDoneNavigationBarButton];
}

- (void)dealloc {
    PHCachingImageManager *imageManager = [PHCachingImageManager defaultManager];
    [imageManager stopCachingImagesForAllAssets];
}

#pragma mark - Setup
- (void)setupParams {
    self.title = @"所有照片";
    NSInteger numInRow = 4;
    CGFloat galleryWidth = MWScreenWidth - 2*kGalleryLeftAndRightMargin;
    _itemWidth = floorf((galleryWidth - (numInRow-1)*kGalleryPhotoSpacing)/numInRow);
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self pvt_setupNavigationBarButtons];
    [self pvt_updateDoneNavigationBarButton];
    [self.view addSubview:self.photosCollectionView];
}

#pragma mark - NavigationBar
- (void)pvt_setupNavigationBarButtons {
    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.doneButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [self.doneButton setTitleColor:self.configuration.navTitleColor forState:UIControlStateNormal];
    self.doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.doneButton addTarget:self action:@selector(clickDoneButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:self.doneButton];
    self.navigationItem.rightBarButtonItems = @[doneItem];
}

- (void)pvt_updateDoneNavigationBarButton {
    NSInteger selectedPhotoCount = self.selectedAssetObjects.count;
    NSString *doneTitleString = [NSString stringWithFormat:@"(%@/%@)完成",@(selectedPhotoCount),@(self.configuration.maxSelectCount)];
    [self.doneButton setTitle:doneTitleString forState:UIControlStateNormal];
    
    CGFloat titleWidth = [doneTitleString boundingRectWithSize:CGSizeMake(100.f, 20.f) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.doneButton.titleLabel.font} context:nil].size.width + 20.f;
    
    self.doneButton.frame = CGRectMake(0, 0, MAX(MWNavigationBarHeight,titleWidth), MWNavigationBarHeight);
}

#pragma mark - Request Gallery
- (void)pvt_fetchAssetCollection {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
        // 按创建时间升序
        allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO]];
        // 获取所有照片（按创建时间升序）
        PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
        __block NSMutableArray *assetObjects = [NSMutableArray arrayWithCapacity:result.count];
        
        [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.mediaType == PHAssetMediaTypeImage) {
                if ([MWAssetManager cls_isGifWithAsset:obj]) {
                    if (self.configuration.allowSelectGif) {
                        MWAssetPhotoObject *gifObject = [[MWAssetPhotoObject alloc] init];
                        gifObject.type = MWPhotoObjectTypeAsset;
                        gifObject.assetType = MWAssetTypeGif;
                        gifObject.asset = obj;
                        [assetObjects addObject:gifObject];
                    }
                } else {
                    if (self.configuration.allowSelectImage) {
                        MWAssetPhotoObject *imageObject = [[MWAssetPhotoObject alloc] init];
                        imageObject.type = MWPhotoObjectTypeAsset;
                        imageObject.assetType = MWAssetTypeNormalImage;
                        imageObject.asset = obj;
                        [assetObjects addObject:imageObject];
                    }
                }
            } else if (obj.mediaType == PHAssetMediaTypeVideo) {
                if (self.configuration.allowSelectVideo) {
                    MWAssetPhotoObject *videoObject = [[MWAssetPhotoObject alloc] init];
                    videoObject.type = MWPhotoObjectTypeAsset;
                    videoObject.assetType = MWAssetTypeVideo;
                    videoObject.asset = obj;
                    [assetObjects addObject:videoObject];
                }
            }
        }];
        
        self.assetObjects = assetObjects;
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

#pragma mark - Selected Assets
- (NSArray<MWPhotoObject *> *)selectedAssetObjects {
    NSMutableArray *selectedObjects = [NSMutableArray array];
    for (MWPhotoObject *object in self.assetObjects) {
        if (object.isSelect) {
            [selectedObjects addObject:object];
        }
    }
    return selectedObjects;
}

#pragma mark - Actions
- (void)clickDoneButton {
    NSArray *selectedAssetObjects = self.selectedAssetObjects;
    if (selectedAssetObjects.count < self.configuration.minSelectCount) {
        NSLog(@"低于最小数量限制");
        return;
    }
    if (self.configuration.selectCompletionBlock) {
        NSMutableArray *assets = [NSMutableArray arrayWithCapacity:selectedAssetObjects.count];
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:selectedAssetObjects.count];
        for (MWAssetPhotoObject *assetObject in selectedAssetObjects) {
            [assets addObject:assetObject.asset];
            [MWAssetManager cls_requestOriginalImageForAsset:assetObject.asset completion:^(UIImage * _Nonnull image, NSDictionary * _Nonnull info) {
                [images addObject:image];
            }];
        }
        self.configuration.selectCompletionBlock(selectedAssetObjects,assets,images);
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource && UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MWGalleryPhotoCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    MWAssetPhotoObject *assetObject = [self.assetObjects objectAtIndex:indexPath.item];
    [photoCell updateUIWithAssetObject:assetObject imageWidth:_itemWidth];
    photoCell.delegate = self;
    return photoCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(_itemWidth, _itemWidth);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MWPhotoPreviewViewController *previewVc = [[MWPhotoPreviewViewController alloc] init];
    previewVc.currentIndex = indexPath.item;
    previewVc.photoObjects = self.assetObjects;
    previewVc.configuration = self.configuration;
    previewVc.isPush = YES;
    previewVc.canSelect = YES;
    [self.navigationController pushViewController:previewVc animated:YES];
}

#pragma mark - UICollectionViewDataSourcePrefetching
- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    NSMutableArray *assets = [NSMutableArray array];
    for (NSIndexPath *indexPath in indexPaths) {
        MWAssetPhotoObject *assetObject = [self.assetObjects objectAtIndex:indexPath.item];
        if (assetObject.assetType == MWAssetTypeNormalImage) {
            [assets addObject:assetObject.asset];
        }
    }
    [[PHCachingImageManager defaultManager] startCachingImagesForAssets:assets
                                                             targetSize:CGSizeMake(100.f, 100.f)
                                                            contentMode:PHImageContentModeDefault options:nil];
}

- (void)collectionView:(UICollectionView *)collectionView cancelPrefetchingForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    NSMutableArray *assets = [NSMutableArray array];
    for (NSIndexPath *indexPath in indexPaths) {
        MWAssetPhotoObject *assetObject = [self.assetObjects objectAtIndex:indexPath.item];
        if (assetObject.assetType == MWAssetTypeNormalImage) {
            [assets addObject:assetObject.asset];
        }
    }
    [[PHCachingImageManager defaultManager] stopCachingImagesForAssets:assets
                                                            targetSize:CGSizeMake(100.f, 100.f)
                                                           contentMode:PHImageContentModeDefault options:nil];
}

#pragma mark - MWGalleryPhotoCellDelegate
- (void)photoCell:(MWGalleryPhotoCell *)photoCell selectAssetObject:(nonnull MWAssetPhotoObject *)assetObject isSelect:(BOOL)isSelect {
    if (isSelect) {
        if (self.selectedAssetObjects.count >= self.configuration.maxSelectCount) {
            NSLog(@"超出数量限制");
            return;
        }
        assetObject.isSelect = YES;
    } else {
        assetObject.isSelect = NO;
    }
    [self.photosCollectionView reloadData];
    [self pvt_updateDoneNavigationBarButton];
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
