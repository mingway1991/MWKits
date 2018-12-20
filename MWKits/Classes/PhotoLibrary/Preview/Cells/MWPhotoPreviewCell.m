//
//  MWPhotoPreviewCell.m
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import "MWPhotoPreviewCell.h"
#import "MWDefines.h"

@interface MWPhotoPreviewCell () <UIScrollViewDelegate>

@property (nonatomic, strong) MWPhotoObject *photoObject;
@property (nonatomic, strong) UIScrollView *bgScrollView;
@property (nonatomic, strong) UIImageView *previewImageView;

@end

@implementation MWPhotoPreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.bgScrollView];
        [self.bgScrollView addSubview:self.previewImageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bgScrollView.frame = self.contentView.bounds;
    self.previewImageView.frame = self.bgScrollView.bounds;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.bgScrollView.zoomScale = 1.0f;
}

#pragma mark - Public
- (void)updateUIWithPhotoObject:(MWPhotoObject *)photoObject {
    self.photoObject = photoObject;
    switch (photoObject.type) {
        case MWPhotoObjectTypeAsset: {
            [[PHImageManager defaultManager] requestImageForAsset:[(MWAssetPhotoObject *)photoObject asset] targetSize:CGSizeMake(MWScreenWidth, MWScreenHeight)
                                                      contentMode:PHImageContentModeDefault
                                                          options:nil
                                                    resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                        self.previewImageView.image = result;
                                                    }];
            break;
        }
        case MWPhotoObjectTypeImage: {
            self.previewImageView.image = [(MWImagePhotoObject *)photoObject image];
            break;
        }
        case MWPhotoObjectTypeUrl: {
            break;
        }
        case MWPhotoObjectTypeUndefined: {
            self.previewImageView.image = nil;
            break;
        }
        default:
            break;
    }
}

#pragma mark - Gesture
- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)tapGesture {
    self.bgScrollView.zoomScale = 1.0f;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.previewImageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (self.bgScrollView.zoomScale > 1) {
        self.previewImageView.center = CGPointMake(self.bgScrollView.contentSize.width / 2.f, self.bgScrollView.contentSize.height / 2.f);
    } else {
        self.previewImageView.center = self.bgScrollView.center;
    }
}

#pragma mark - LazyLoad
- (UIScrollView *)bgScrollView {
    if (!_bgScrollView) {
        self.bgScrollView = [[UIScrollView alloc] init];
        _bgScrollView.delegate = self;
        _bgScrollView.minimumZoomScale = 0.5f;
        _bgScrollView.maximumZoomScale = 5.0f;
        _bgScrollView.zoomScale = 1.0f;
        _bgScrollView.bouncesZoom = NO;
        _bgScrollView.showsVerticalScrollIndicator = NO;
        _bgScrollView.showsHorizontalScrollIndicator = NO;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
        tapGesture.numberOfTapsRequired = 2;
        [_bgScrollView addGestureRecognizer:tapGesture];
    }
    return _bgScrollView;
}

- (UIImageView *)previewImageView {
    if (!_previewImageView) {
        self.previewImageView = [[UIImageView alloc] init];
        _previewImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _previewImageView;
}

@end
