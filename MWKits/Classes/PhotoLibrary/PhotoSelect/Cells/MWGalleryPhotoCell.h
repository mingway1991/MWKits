//
//  MWGalleryPhotoCell.h
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import <UIKit/UIKit.h>
@import Photos;

NS_ASSUME_NONNULL_BEGIN

@interface MWGalleryPhotoCell : UICollectionViewCell

/**
 更新UI
 
 @param asset 图片对象
 @param imageWidth 需要显示的图片宽度
 */
- (void)updateUIWithAsset:(PHAsset *)asset
               imageWidth:(CGFloat)imageWidth;

@end

NS_ASSUME_NONNULL_END
