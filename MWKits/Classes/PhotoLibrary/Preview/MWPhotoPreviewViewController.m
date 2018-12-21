//
//  MWPhotoPreviewViewController.m
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import "MWPhotoPreviewViewController.h"
#import "MWPhotoPreviewCell.h"
#import "MWDefines.h"

static CGFloat kPreviewPhotoSpacing = 20.f;

@interface MWPhotoPreviewViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *previewCollectionView;

@end

@implementation MWPhotoPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupParams];
    [self setupUI];
}

#pragma mark - Setup
- (void)setupParams {
    [self pvt_updateTitle];
}

- (void)setupUI {
    [self pvt_setupNavigationBarButtons];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.previewCollectionView];
    
    [self.previewCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

#pragma mark - NavigationBar
- (void)pvt_setupNavigationBarButtons {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(clickBackButton)];
    self.navigationItem.leftBarButtonItems = @[backItem];
}

#pragma mark - Actions
- (void)clickBackButton {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private
- (void)pvt_updateTitle {
    self.title = [NSString stringWithFormat:@"%@/%@",@(self.currentIndex+1),@(self.photoObjects.count)];
}

#pragma mark - UICollectionViewDataSource && UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MWPhotoPreviewCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    [photoCell updateUIWithPhotoObject:self.photoObjects[indexPath.item]];
    return photoCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.bounds.size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGFloat x = targetContentOffset->x;
    CGFloat pageWidth = CGRectGetWidth(self.view.bounds) + kPreviewPhotoSpacing;
    CGFloat movedX = x - pageWidth*self.currentIndex;
    if (movedX < -pageWidth * 0.5) {
        self.currentIndex--;
    } else if (movedX > pageWidth * 0.5) {
        self.currentIndex++;
    }

    if (ABS(velocity.x) >= 2){
        targetContentOffset->x = pageWidth*self.currentIndex;
    } else {
        targetContentOffset->x = scrollView.contentOffset.x;
        [scrollView setContentOffset:CGPointMake(pageWidth*self.currentIndex, scrollView.contentOffset.y) animated:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self pvt_updateTitle];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self pvt_updateTitle];
}

#pragma mark - LazyLoad
- (UICollectionView *)previewCollectionView {
    if (!_previewCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = kPreviewPhotoSpacing;
        self.previewCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _previewCollectionView.delegate = self;
        _previewCollectionView.dataSource = self;
        _previewCollectionView.alwaysBounceHorizontal = YES;
        [_previewCollectionView registerClass:[MWPhotoPreviewCell class] forCellWithReuseIdentifier:@"photoCell"];
        _previewCollectionView.backgroundColor = [UIColor blackColor];
    }
    return _previewCollectionView;
}

@end
