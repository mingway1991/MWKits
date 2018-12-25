//
//  MWGifPhotoPreviewView.m
//  MWKits
//
//  Created by 石茗伟 on 2018/12/24.
//

#import "MWGifPhotoPreviewView.h"
#import "MWDefines.h"
#import "MWPhotoManager.h"

@import SDWebImage;

@interface MWGifPhotoPreviewView ()

@property (nonatomic, strong) UIImageView *gifImageView;

@property (nonatomic, strong) PHAsset *asset;

@end

@implementation MWGifPhotoPreviewView

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
    self.gifImageView.frame = self.bounds;
}

- (void)setupUI {
    [self addSubview:self.gifImageView];
}

#pragma mark - Public
- (void)updateUIWithAsset:(PHAsset *)asset {
    self.asset = asset;
    CGFloat scale = 2;
    CGFloat kViewWidth = MWScreenWidth;
    CGFloat width = kViewWidth;
    CGSize size = CGSizeMake(width*scale, width*scale*asset.pixelHeight/asset.pixelWidth);
    [self.gifImageView sd_addActivityIndicator];
    __weak typeof(self) weakSelf = self;
    [MWPhotoManager cls_requestImageForAsset:asset
                                        size:size
                                  resizeMode:PHImageRequestOptionsResizeModeNone
                                  completion:^(UIImage *image, NSDictionary *info) {
                                      weakSelf.gifImageView.image = image;
                                      [weakSelf.gifImageView sd_removeActivityIndicator];
                                  }];
}

#pragma mark - Private
- (void)pvt_loadGif {
    [self.gifImageView sd_addActivityIndicator];
    __weak typeof(self) weakSelf = self;
    [MWPhotoManager cls_requestOriginalImageDataForAsset:self.asset completion:^(NSData * _Nonnull data, NSDictionary * _Nonnull info) {
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            UIImage *gifImage = [MWPhotoManager cls_transformToGifImageWithData:data];
            weakSelf.gifImageView.image = gifImage;
        }
        [weakSelf.gifImageView sd_removeActivityIndicator];
    }];
}

#pragma mark - LazyLoad
- (UIImageView *)gifImageView {
    if (!_gifImageView) {
        self.gifImageView = [[UIImageView alloc] init];
        _gifImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _gifImageView;
}

@end
