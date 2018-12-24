//
//  MWNormalPhotoPreviewView.h
//  MWKits
//
//  Created by 石茗伟 on 2018/12/24.
//

#import <UIKit/UIKit.h>

@import Photos;

NS_ASSUME_NONNULL_BEGIN

@interface MWNormalPhotoPreviewView : UIView

- (void)updateUIWithAsset:(PHAsset *)asset;

- (void)updateUIWithImage:(UIImage *)image;

- (void)updateUIWithUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
