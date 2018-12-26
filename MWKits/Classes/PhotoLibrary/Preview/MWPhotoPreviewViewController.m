//
//  MWPhotoPreviewViewController.m
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import "MWPhotoPreviewViewController.h"
#import "MWPhotoPreviewCell.h"
#import "MWDefines.h"
#import "MWImageHelper.h"
#import "MWAssetManager.h"

static CGFloat kPreviewPhotoSpacing = 20.f;

@interface MWPhotoPreviewViewController () <UICollectionViewDataSource,
                                            UICollectionViewDelegate,
                                            UICollectionViewDelegateFlowLayout > {
    BOOL _hideBars;
}

@property (nonatomic, strong) UICollectionView *previewCollectionView;
@property (nonatomic, strong) UIView *selectToolBar;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation MWPhotoPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupParams];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.canSelect) {
        [self pvt_hideBarsWithAnimation:NO];
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (BOOL)prefersStatusBarHidden {
    if (self.canSelect) {
        return _hideBars;
    } else {
        return YES;
    }
}

#pragma mark - Setup
- (void)setupParams {
    [self pvt_updateTitle];
    if (self.canSelect) {
        _hideBars = YES;
    }
}

- (void)setupUI {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.previewCollectionView];
    [self.previewCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    if (self.canSelect) {
        //选择模式下
        [self pvt_setupNavigationBarButtons];
        [self.view addSubview:self.selectToolBar];
        self.selectToolBar.hidden = !self.canSelect;
        [self pvt_updateSelectButton];
        [self pvt_updateDoneNavigationBarButton];
    } else {
        //预览模式下
        [self.view addSubview:self.pageControl];
    }
}

#pragma mark - NavigationBar
- (void)pvt_setupNavigationBarButtons {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, MWNavigationBarHeight, MWNavigationBarHeight);
    backButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [backButton setTitleColor:self.configuration.navTitleColor forState:UIControlStateNormal];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.canSelect) {
        backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItems = @[backItem];
        
        self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.doneButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [self.doneButton setTitleColor:self.configuration.navTitleColor forState:UIControlStateNormal];
        [self.doneButton addTarget:self action:@selector(clickDoneButton) forControlEvents:UIControlEventTouchUpInside];
        self.doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:self.doneButton];
        self.navigationItem.rightBarButtonItems = @[doneItem];
    } else {
        backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.rightBarButtonItems = @[backItem];
    }
}

- (void)pvt_updateDoneNavigationBarButton {
    NSInteger selectedPhotoCount = self.selectedPhotoObjects.count;
    NSString *doneTitleString = [NSString stringWithFormat:@"(%@/%@)完成",@(selectedPhotoCount),@(self.configuration.maxSelectCount)];
    [self.doneButton setTitle:doneTitleString forState:UIControlStateNormal];
    
    CGFloat titleWidth = [doneTitleString boundingRectWithSize:CGSizeMake(100.f, 20.f) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.doneButton.titleLabel.font} context:nil].size.width + 20.f;
    
    self.doneButton.frame = CGRectMake(0, 0, MAX(MWNavigationBarHeight,titleWidth), MWNavigationBarHeight);
}

#pragma mark - Selected Objects
- (NSArray<MWPhotoObject *> *)selectedPhotoObjects {
    NSMutableArray *selectedObjects = [NSMutableArray array];
    for (MWPhotoObject *object in self.photoObjects) {
        if (object.isSelect) {
            [selectedObjects addObject:object];
        }
    }
    return selectedObjects;
}

#pragma mark - Actions
- (void)clickBackButton {
    if (self.isPush) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)clickDoneButton {
    NSArray *selectedAssetObjects = self.selectedPhotoObjects;
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

- (void)clickSelectButton:(UIButton *)sender {
    if (sender.isSelected) {
        MWPhotoObject *photoObject = self.photoObjects[self.currentIndex];
        if ([photoObject isKindOfClass:[MWAssetPhotoObject class]]) {
            MWAssetPhotoObject *assetObject = (MWAssetPhotoObject *)photoObject;
            assetObject.isSelect = NO;
            [self pvt_updateSelectButton];
            [self pvt_updateDoneNavigationBarButton];
        }
    } else {
        if (self.selectedPhotoObjects.count >= self.configuration.maxSelectCount) {
            NSLog(@"超出数量限制");
            return;
        }
        MWPhotoObject *photoObject = self.photoObjects[self.currentIndex];
        if ([photoObject isKindOfClass:[MWAssetPhotoObject class]]) {
            MWAssetPhotoObject *assetObject = (MWAssetPhotoObject *)photoObject;
            assetObject.isSelect = YES;
            [self pvt_updateSelectButton];
            [self pvt_updateDoneNavigationBarButton];
        }
    }
    [self pvt_updateDoneNavigationBarButton];
}

#pragma mark - Gestures
- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    NSLog(@"单击");
    if (self.canSelect) {
        if (_hideBars) {
            [self pvt_showBarsWithAnimation:YES];
        } else {
            [self pvt_hideBarsWithAnimation:YES];
        }
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)tapGesture {
    NSLog(@"双击");
}

#pragma mark - Private
- (void)pvt_updateTitle {
    self.title = [NSString stringWithFormat:@"%@/%@",@(self.currentIndex+1),@(self.photoObjects.count)];
}

- (void)pvt_updateSelectButton {
    MWPhotoObject *photoObject = self.photoObjects[self.currentIndex];
    if ([photoObject isKindOfClass:[MWAssetPhotoObject class]]) {
        [self.selectButton setSelected:[(MWAssetPhotoObject *)photoObject isSelect]];
    }
}

- (void)pvt_updatePageControl {
    self.pageControl.currentPage = self.currentIndex;
}

- (void)pvt_hideBarsWithAnimation:(BOOL)animation {
    _hideBars = YES;
    [self.navigationController setNavigationBarHidden:YES animated:animation];
    if (animation) {
        [UIView animateWithDuration:0.2f animations:^{
            MWSetMinY(self.selectToolBar, MWGetHeight(self.view));
        } completion:^(BOOL finished) {
            if (finished) {
                self.selectToolBar.hidden = YES;
            }
        }];
    } else {
        self.selectToolBar.hidden = YES;
    }
}

- (void)pvt_showBarsWithAnimation:(BOOL)animation {
    _hideBars = NO;
    [self.navigationController setNavigationBarHidden:NO animated:animation];
    if (animation) {
        self.selectToolBar.hidden = NO;
        [UIView animateWithDuration:0.2f animations:^{
            MWSetMinY(self.selectToolBar, MWGetHeight(self.view)-MWGetHeight(self.selectToolBar));
        }];
    } else {
        self.selectToolBar.hidden = NO;
    }
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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
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
    if (self.canSelect) {
        [self pvt_updateTitle];
        [self pvt_updateSelectButton];
    } else {
        [self pvt_updatePageControl];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.canSelect) {
        [self pvt_updateTitle];
        [self pvt_updateSelectButton];
    } else {
        [self pvt_updatePageControl];
    }
}

#pragma mark - LazyLoad
- (UICollectionView *)previewCollectionView {
    if (!_previewCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = kPreviewPhotoSpacing;
        self.previewCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, MWGetWidth(self.view), MWGetHeight(self.view)) collectionViewLayout:layout];
        _previewCollectionView.delegate = self;
        _previewCollectionView.dataSource = self;
        _previewCollectionView.alwaysBounceHorizontal = YES;
        [_previewCollectionView registerClass:[MWPhotoPreviewCell class] forCellWithReuseIdentifier:@"photoCell"];
        _previewCollectionView.backgroundColor = [UIColor blackColor];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.numberOfTapsRequired = 1;
        [_previewCollectionView addGestureRecognizer:tapGesture];
        
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [_previewCollectionView addGestureRecognizer:doubleTapGesture];
        
        [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
    }
    return _previewCollectionView;
}

- (UIView *)selectToolBar {
    if (!_selectToolBar) {
        CGFloat selectToolBarHeight = 50.f;
        self.selectToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, MWGetHeight(self.view)-selectToolBarHeight, MWGetWidth(self.view), selectToolBarHeight)];
        _selectToolBar.backgroundColor = self.configuration.navBarColor;
        
        CGFloat selectButtonHeight = 40.f;
        self.selectButton.frame = CGRectMake(MWGetWidth(_selectToolBar)-selectButtonHeight-10.f, (selectToolBarHeight-selectButtonHeight)/2.f, selectButtonHeight, selectButtonHeight);
        [_selectToolBar addSubview:self.selectButton];
    }
    return _selectToolBar;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
        _selectButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_selectButton setImage:[MWImageHelper loadImageWithName:@"mw_btn_unselected"] forState:UIControlStateNormal];
        [_selectButton setImage:[MWImageHelper loadImageWithName:@"mw_btn_selected"] forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(clickSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(10.f, MWGetHeight(self.view)-50.f, MWScreenWidth-20.f, 30.f)];
        _pageControl.numberOfPages = self.photoObjects.count;
        _pageControl.currentPage = self.currentIndex;
        _pageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    }
    return _pageControl;
}

@end
