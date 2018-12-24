//
//  MWNormalPhotoPreviewView.m
//  MWKits
//
//  Created by 石茗伟 on 2018/12/24.
//

#import "MWNormalPhotoPreviewView.h"
#import "MWDefines.h"
#import "MWPhotoManager.h"
#import "UIImage+FixOrientation.h"
#import "PHCachingImageManager+DefaultManager.h"

@import SDWebImage;

@interface MWNormalPhotoPreviewView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *bgScrollView;
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) UIImageView *previewImageView;

@property (nonatomic, assign) PHImageRequestID imageRequestID;

@end

@implementation MWNormalPhotoPreviewView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bgScrollView.frame = self.bounds;
    [self pvt_recoverSubviews];
}

- (void)setupUI {
    [self addSubview:self.bgScrollView];
    [self.bgScrollView addSubview:self.imageContainerView];
    [self.imageContainerView addSubview:self.previewImageView];
}

#pragma mark - Public
- (void)updateUIWithAsset:(PHAsset *)asset {
    [self.bgScrollView setZoomScale:1.0f animated:NO];
    if (self.imageRequestID >= 0) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    //照片处理
    CGFloat scale = 2;
    CGFloat width = MWScreenWidth;
    CGSize size = CGSizeMake(width*scale, width*scale*asset.pixelHeight/asset.pixelWidth);
    [self.previewImageView sd_addActivityIndicator];
    __weak typeof(self) weakSelf = self;
    self.imageRequestID = [MWPhotoManager cls_requestImageForAsset:asset
                                                              size:size
                                                        resizeMode:PHImageRequestOptionsResizeModeFast
                                                        completion:^(UIImage *image, NSDictionary *info) {
                                                            weakSelf.previewImageView.image = image;
                                                            [weakSelf pvt_resizeSubviews];
                                                            [weakSelf.previewImageView sd_removeActivityIndicator];
                                                        }];
}

- (void)updateUIWithImage:(UIImage *)image {
    [self.bgScrollView setZoomScale:1.0f animated:NO];
    self.previewImageView.image = image;
    [self pvt_resizeSubviews];
}

- (void)updateUIWithUrl:(NSString *)url {
    [self.bgScrollView setZoomScale:1.0f animated:NO];
    __weak typeof(self) weakSelf = self;
    [self.previewImageView sd_addActivityIndicator];
    [self.previewImageView sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        weakSelf.previewImageView.image = image;
        [weakSelf pvt_resizeSubviews];
        [weakSelf.previewImageView sd_removeActivityIndicator];
    }];
}

#pragma mark - Private
- (void)pvt_recoverSubviews {
    [self.bgScrollView setZoomScale:1.0 animated:NO];
    [self pvt_resizeSubviews];
}

- (void)pvt_resizeSubviews {
    MWSetOrigin(self.imageContainerView, CGPointZero);
    MWSetWidth(self.imageContainerView, MWGetWidth(self.bgScrollView));
    
    UIImage *image = self.previewImageView.image;
    if (image.size.height / image.size.width > MWGetHeight(self) / MWGetWidth(self.bgScrollView)) {
        MWSetHeight(self.imageContainerView, floor(image.size.height / (image.size.width / MWGetWidth(self.bgScrollView))));
    } else {
        CGFloat height = image.size.height / image.size.width * MWGetWidth(self.bgScrollView);
        if (height < 1 || isnan(height)) height = MWGetHeight(self.bgScrollView);
        height = floor(height);
        MWSetHeight(self.imageContainerView, height);
        MWSetCenterY(self.imageContainerView, MWGetHeight(self) / 2);
    }
    if (MWGetHeight(self.imageContainerView) > MWGetHeight(self) && MWGetHeight(self.imageContainerView) - MWGetHeight(self) <= 1) {
        MWSetHeight(self.imageContainerView, MWGetHeight(self));
    }
    CGFloat contentSizeH = MAX(MWGetHeight(self.imageContainerView), MWGetHeight(self));
    self.bgScrollView.contentSize = CGSizeMake(MWGetWidth(self.bgScrollView), contentSizeH);
    [self.bgScrollView scrollRectToVisible:self.bounds animated:NO];
    self.bgScrollView.alwaysBounceVertical = MWGetHeight(self.imageContainerView) <= MWGetHeight(self) ? NO : YES;
    self.previewImageView.frame = self.imageContainerView.bounds;
}

- (void)pvt_refreshImageContainerViewCenter {
    CGFloat offsetX = (MWGetWidth(self.bgScrollView) > self.bgScrollView.contentSize.width) ? ((MWGetWidth(self.bgScrollView) - self.bgScrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (MWGetHeight(self.bgScrollView) > self.bgScrollView.contentSize.height) ? ((MWGetHeight(self.bgScrollView) - self.bgScrollView.contentSize.height) * 0.5) : 0.0;
    self.imageContainerView.center = CGPointMake(self.bgScrollView.contentSize.width * 0.5 + offsetX, self.bgScrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - Gesture
- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)tapGesture {
    if (self.bgScrollView.zoomScale > 1.0) {
        self.bgScrollView.contentInset = UIEdgeInsetsZero;
        [self.bgScrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tapGesture locationInView:self.previewImageView];
        CGFloat newZoomScale = self.bgScrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [self.bgScrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageContainerView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self pvt_refreshImageContainerViewCenter];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self pvt_refreshImageContainerViewCenter];
}

#pragma mark - LazyLoad
- (UIScrollView *)bgScrollView {
    if (!_bgScrollView) {
        self.bgScrollView = [[UIScrollView alloc] init];
        _bgScrollView.delegate = self;
        _bgScrollView.maximumZoomScale = 3.0f;
        _bgScrollView.minimumZoomScale = 1.0f;
        _bgScrollView.multipleTouchEnabled = YES;
        _bgScrollView.showsVerticalScrollIndicator = NO;
        _bgScrollView.showsHorizontalScrollIndicator = NO;
        _bgScrollView.delaysContentTouches = NO;
        _bgScrollView.scrollsToTop = NO;
        _bgScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _bgScrollView.delaysContentTouches = NO;
        _bgScrollView.canCancelContentTouches = YES;
        _bgScrollView.alwaysBounceVertical = NO;
        if (@available(iOS 11, *)) {
            _bgScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
        tapGesture.numberOfTapsRequired = 2;
        [_bgScrollView addGestureRecognizer:tapGesture];
    }
    return _bgScrollView;
}

- (UIView *)imageContainerView {
    if (!_imageContainerView) {
        self.imageContainerView = [[UIView alloc] init];
        _imageContainerView.contentMode = UIViewContentModeScaleAspectFill;
        _imageContainerView.clipsToBounds = YES;
    }
    return _imageContainerView;
}

- (UIImageView *)previewImageView {
    if (!_previewImageView) {
        self.previewImageView = [[UIImageView alloc] init];
        _previewImageView.contentMode = UIViewContentModeScaleAspectFill;
        _previewImageView.clipsToBounds = YES;
    }
    return _previewImageView;
}

@end
