//
//  MWGifPhotoPreviewView.h
//  MWKits
//
//  Created by 石茗伟 on 2018/12/24.
//

#import <UIKit/UIKit.h>

@import Photos;

NS_ASSUME_NONNULL_BEGIN

@interface MWGifPhotoPreviewView : UIView

- (void)updateUIWithAsset:(PHAsset *)asset;

@end

NS_ASSUME_NONNULL_END
