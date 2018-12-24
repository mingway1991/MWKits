//
//  MWPhotoPreviewCell.m
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import "MWPhotoPreviewCell.h"
#import "MWPhotoManager.h"
#import "MWNormalPhotoPreviewView.h"
#import "MWGifPhotoPreviewView.h"
#import "MWVideoPreviewView.h"

@interface MWPhotoPreviewCell ()

@property (nonatomic, strong) MWNormalPhotoPreviewView *normalPhotoPreviewView;
@property (nonatomic, strong) MWGifPhotoPreviewView *gifPhotoPreviewView;
@property (nonatomic, strong) MWVideoPreviewView *videoPreviewView;

@end

@implementation MWPhotoPreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.normalPhotoPreviewView];
        [self.contentView addSubview:self.gifPhotoPreviewView];
        [self.contentView addSubview:self.videoPreviewView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.normalPhotoPreviewView.frame = self.contentView.bounds;
    self.gifPhotoPreviewView.frame = self.contentView.bounds;
    self.videoPreviewView.frame = self.contentView.bounds;
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

#pragma mark - Public
- (void)updateUIWithPhotoObject:(MWPhotoObject *)photoObject {
    self.normalPhotoPreviewView.hidden = YES;
    self.gifPhotoPreviewView.hidden = YES;
    self.videoPreviewView.hidden = YES;
    switch (photoObject.type) {
        case MWPhotoObjectTypeAsset: {
            PHAsset *asset = [(MWAssetPhotoObject *)photoObject asset];
            switch (asset.mediaType) {
                case PHAssetMediaTypeImage: {
                   BOOL isGif = [MWPhotoManager cls_isGifWithAsset:asset];
                    if (isGif) {
                        //Gif
                        self.gifPhotoPreviewView.hidden = NO;
                        [self.gifPhotoPreviewView updateUIWithAsset:asset];
                    } else {
                        //普通图片
                        self.normalPhotoPreviewView.hidden = NO;
                        [self.normalPhotoPreviewView updateUIWithAsset:asset];
                    }
                    break;
                }
                case PHAssetMediaTypeVideo: {
                    //视频处理
                    self.videoPreviewView.hidden = NO;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case MWPhotoObjectTypeImage: {
            UIImage *image = [(MWImagePhotoObject *)photoObject image];
            self.normalPhotoPreviewView.hidden = NO;
            [self.normalPhotoPreviewView updateUIWithImage:image];
            break;
        }
        case MWPhotoObjectTypeUrl: {
            NSString *url = [(MWUrlPhotoObject *)photoObject url];
            self.normalPhotoPreviewView.hidden = NO;
            [self.normalPhotoPreviewView updateUIWithUrl:url];
            break;
        }
        case MWPhotoObjectTypeUndefined: {
            break;
        }
        default: {
            break;
        }
    }
}

#pragma mark - LazyLoad
- (MWNormalPhotoPreviewView *)normalPhotoPreviewView {
    if (!_normalPhotoPreviewView) {
        self.normalPhotoPreviewView = [[MWNormalPhotoPreviewView alloc] init];
    }
    return _normalPhotoPreviewView;
}

- (MWGifPhotoPreviewView *)gifPhotoPreviewView {
    if (!_gifPhotoPreviewView) {
        self.gifPhotoPreviewView = [[MWGifPhotoPreviewView alloc] init];
    }
    return _gifPhotoPreviewView;
}

- (MWVideoPreviewView *)videoPreviewView {
    if (!_videoPreviewView) {
        self.videoPreviewView = [[MWVideoPreviewView alloc] init];
    }
    return _videoPreviewView;
}

@end
