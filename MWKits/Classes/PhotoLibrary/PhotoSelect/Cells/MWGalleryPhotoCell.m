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
#import "MWImageHelper.h"

@interface MWGalleryPhotoCell ()

@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UIView *selectedCoverView;
@property (nonatomic, strong) UIButton *selectButton;

@property (nonatomic, strong) MWAssetPhotoObject *assetObject;
@property (nonatomic, assign) PHImageRequestID imageRequestID;

@end

@implementation MWGalleryPhotoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.photoImageView];
        [self.contentView addSubview:self.typeLabel];
        [self.contentView addSubview:self.selectedCoverView];
        [self.contentView addSubview:self.selectButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.photoImageView.frame = self.bounds;
    self.selectedCoverView.frame = self.bounds;
    MWSetMinY(self.typeLabel, CGRectGetHeight(self.bounds)-CGRectGetHeight(self.typeLabel.bounds));
    MWSetOrigin(self.selectButton, CGPointMake(MWGetWidth(self)-MWGetWidth(self.selectButton), 0.f));
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.photoImageView.image = nil;
}

#pragma mark - Public
- (void)updateUIWithAssetObject:(MWAssetPhotoObject *)assetObject
                     imageWidth:(CGFloat)imageWidth
                       isSelect:(BOOL)isSelect {
    self.assetObject = assetObject;
    switch (assetObject.assetType) {
        case MWAssetTypeNormalImage:
        case MWAssetTypeGif: {
            if (assetObject.assetType == MWAssetTypeNormalImage) {
                self.typeLabel.hidden = YES;
            } else {
                self.typeLabel.hidden = NO;
                self.typeLabel.text = @"Gif";
                MWSetWidth(self.typeLabel, 24.f);
            }
            __weak typeof(self) weakSelf = self;
            [MWPhotoManager cls_requestImageForAsset:assetObject.asset
                                                size:CGSizeMake(100.f, 100.f)
                                          resizeMode:PHImageRequestOptionsResizeModeNone
                                          completion:^(UIImage * _Nonnull image, NSDictionary * _Nonnull info) {
                                              weakSelf.photoImageView.image = image;
                                          }];
            break;
        }
        case MWAssetTypeVideo: {
            self.typeLabel.hidden = NO;
            self.typeLabel.text = @"Video";
            MWSetWidth(self.typeLabel, 40.f);
            break;
        }
        default:
            break;
    }
    [self.selectButton setSelected:self.assetObject.isSelect];
    self.selectedCoverView.hidden = !self.assetObject.isSelect;
}

#pragma mark - Actions
- (void)clickSelectButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(photoCell:selectAssetObject:isSelect:)]) {
        [self.delegate photoCell:self selectAssetObject:self.assetObject isSelect:!self.assetObject.isSelect];
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

- (UIView *)selectedCoverView {
    if (!_selectedCoverView) {
        self.selectedCoverView = [[UIView alloc] init];
        _selectedCoverView.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:.5];
        _selectedCoverView.hidden = YES;
    }
    return _selectedCoverView;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectButton.frame = CGRectMake(0, 0, 40.f, 40.f);
        _selectButton.imageEdgeInsets = UIEdgeInsetsMake(-10.f, 0.f, 0.f, -10.f);
        [_selectButton setImage:[MWImageHelper loadImageWithName:@"mw_btn_unselected"] forState:UIControlStateNormal];
        [_selectButton setImage:[MWImageHelper loadImageWithName:@"mw_btn_selected"] forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(clickSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

@end
