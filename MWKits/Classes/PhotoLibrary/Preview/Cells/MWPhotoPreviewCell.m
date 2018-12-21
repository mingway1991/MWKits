//
//  MWPhotoPreviewCell.m
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import "MWPhotoPreviewCell.h"
#import "MWDefines.h"
#import "MWPhotoLibrary.h"
#import "UIImage+FixOrientation.h"

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
    self.previewImageView.image = nil;
}

#pragma mark - Public
- (void)updateUIWithPhotoObject:(MWPhotoObject *)photoObject {
    self.previewImageView.image = nil;
    self.photoObject = photoObject;
    switch (photoObject.type) {
        case MWPhotoObjectTypeAsset: {
            PHAsset *asset = [(MWAssetPhotoObject *)photoObject asset];
            switch (asset.mediaType) {
                case PHAssetMediaTypeImage: {
                    //照片处理
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        __weak typeof(self) weakSelf = self;
                        [MWPhotoLibrary cls_requestOriginalImageDataForAsset:asset
                                                                  completion:^(NSData * _Nonnull data, NSDictionary * _Nonnull info) {
                                                                      UIImage * result = [UIImage imageWithData:data];
                                                                      result = [result mw_fixOrientation];
                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                          weakSelf.previewImageView.image = result;
                                                                      });
                                                                  }];
                    });
                    break;
                }
                case PHAssetMediaTypeVideo: {
                    //视频处理
                    break;
                }
                default:
                    break;
            }
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
        default: {
            self.previewImageView.image = nil;
            break;
        }
    }
    [self.bgScrollView setZoomScale:1.0f];
    self.previewImageView.center = self.bgScrollView.center;
}

#pragma mark - Gesture
- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)tapGesture {
    [UIView animateWithDuration:.2f animations:^{
        self.previewImageView.center = self.bgScrollView.center;
        if (self.bgScrollView.zoomScale > 0.9f && self.bgScrollView.zoomScale < 1.1f) {
            [self.bgScrollView setZoomScale:2.0f];
        } else {
            [self.bgScrollView setZoomScale:1.0f];
        }
    }];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //修正图片位置
    CGRect imgViewRect = self.previewImageView.frame;
    CGSize sizeScrollView = scrollView.frame.size;
    
    //修正X轴位置
    if (imgViewRect.size.width < sizeScrollView.width) {
        imgViewRect.origin.x = (sizeScrollView.width - imgViewRect.size.width) / 2;
    } else {
        imgViewRect.origin.x = 0.f;
    }
    
    //修正Y轴位置
    if (imgViewRect.size.height < sizeScrollView.height) {
        imgViewRect.origin.y = (sizeScrollView.height - imgViewRect.size.height) / 2;
    } else {
        imgViewRect.origin.y = 0.f;
    }
    self.previewImageView.frame = imgViewRect;
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
