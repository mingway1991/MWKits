//
//  MWGalleryPhotoCell.m
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import "MWGalleryPhotoCell.h"
#import "MWPhotoManager.h"
#import "UIImage+FixOrientation.h"
#import "MWDefines.h"

@interface MWGalleryPhotoCell ()

@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UIButton *selectButton;

@property (nonatomic, strong) PHAsset *asset;

@end

@implementation MWGalleryPhotoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.photoImageView];
        [self.contentView addSubview:self.typeLabel];
        [self.contentView addSubview:self.selectButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.photoImageView.frame = self.bounds;
    MWSetMinY(self.typeLabel, CGRectGetHeight(self.bounds)-CGRectGetHeight(self.typeLabel.bounds));
    MWSetOrigin(self.selectButton, CGPointMake(MWGetWidth(self)-MWGetWidth(self.selectButton), 0));
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.photoImageView.image = nil;
}

#pragma mark - Public
- (void)updateUIWithAsset:(PHAsset *)asset
               imageWidth:(CGFloat)imageWidth
                 isSelect:(BOOL)isSelect {
    self.asset = asset;
    self.photoImageView.image = nil;
    switch (asset.mediaType) {
        case PHAssetMediaTypeImage: {
            BOOL isGif = [MWPhotoManager cls_isGifWithAsset:asset];
            if (isGif) {
                self.typeLabel.hidden = NO;
                self.typeLabel.text = @"Gif";
                MWSetWidth(self.typeLabel, 24.f);
            } else {
                self.typeLabel.hidden = YES;
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                __weak typeof(self) weakSelf = self;
                [MWPhotoManager cls_requestImageForAsset:asset
                                                    size:CGSizeMake(100.f, 100.f)
                                              resizeMode:PHImageRequestOptionsResizeModeFast
                                              completion:^(UIImage * _Nonnull image, NSDictionary * _Nonnull info) {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      weakSelf.photoImageView.image = image;
                                                  });
                                              }];
            });
            break;
        }
        case PHAssetMediaTypeVideo: {
            self.typeLabel.hidden = NO;
            self.typeLabel.text = @"Video";
            MWSetWidth(self.typeLabel, 40.f);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                __weak typeof(self) weakSelf = self;
                [MWPhotoManager cls_requestVideoForAsset:asset completion:^(AVPlayerItem * _Nonnull item, NSDictionary * _Nonnull info) {
                    UIImage *screenshot = [MWPhotoManager cls_screenshotPlayerItem:item seconds:0];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.photoImageView.image = screenshot;
                    });
                }];
            });
            break;
        }
        default: {
            self.photoImageView.image = nil;
            break;
        }
    }
    if (isSelect) {
        self.selectButton.backgroundColor = [UIColor greenColor];
    } else {
        self.selectButton.backgroundColor = [UIColor yellowColor];
    }
}

#pragma mark - Actions
- (void)clickSelectButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(photoCell:selectAsset:)]) {
        [self.delegate photoCell:self selectAsset:self.asset];
    }
}

#pragma mark - LazyLoad
- (UIImageView *)photoImageView {
    if (!_photoImageView) {
        self.photoImageView = [[UIImageView alloc] init];
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _photoImageView.backgroundColor = [UIColor lightGrayColor];
    }
    return _photoImageView;
}

- (UILabel *)typeLabel {
    if (!_typeLabel) {
        self.typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0.f, 14.f)];
        _typeLabel.backgroundColor = [UIColor colorWithRed:.1 green:.1 blue:.1 alpha:.8];
        _typeLabel.textColor = [UIColor whiteColor];
        _typeLabel.textAlignment = NSTextAlignmentCenter;
        _typeLabel.font = [UIFont systemFontOfSize:12.f];
        _typeLabel.hidden = YES;
    }
    return _typeLabel;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectButton.frame = CGRectMake(0, 0, 20.f, 20.f);
        _selectButton.backgroundColor = [UIColor yellowColor];
        [_selectButton addTarget:self action:@selector(clickSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

@end
