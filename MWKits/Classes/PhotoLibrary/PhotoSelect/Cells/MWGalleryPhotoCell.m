//
//  MWGalleryPhotoCell.m
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import "MWGalleryPhotoCell.h"

@interface MWGalleryPhotoCell ()

@property (nonatomic, strong) UIImageView *photoImageView;

@end

@implementation MWGalleryPhotoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.photoImageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.photoImageView.frame = self.bounds;
}

#pragma mark - Public
- (void)updateUIWithAsset:(PHAsset *)asset
               imageWidth:(CGFloat)imageWidth {
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(imageWidth, imageWidth)
                                              contentMode:PHImageContentModeDefault
                                                  options:nil
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        self.photoImageView.image = result;
    }];
}

#pragma mark - LazyLoad
- (UIImageView *)photoImageView {
    if (!_photoImageView) {
        self.photoImageView = [[UIImageView alloc] init];
    }
    return _photoImageView;
}

@end
