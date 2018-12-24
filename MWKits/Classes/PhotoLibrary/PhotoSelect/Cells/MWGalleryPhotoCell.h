//
//  MWGalleryPhotoCell.h
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import <UIKit/UIKit.h>
@import Photos;
@class MWGalleryPhotoCell;

NS_ASSUME_NONNULL_BEGIN

@protocol MWGalleryPhotoCellDelegate <NSObject>

- (void)photoCell:(MWGalleryPhotoCell *)photoCell selectAsset:(PHAsset *)asset;

@end

@interface MWGalleryPhotoCell : UICollectionViewCell

@property (nonatomic, weak) id<MWGalleryPhotoCellDelegate> delegate;

/**
 更新UI
 
 @param asset 图片对象
 @param imageWidth 需要显示的图片宽度
 @param isSelect 是否被选中
 */
- (void)updateUIWithAsset:(PHAsset *)asset
               imageWidth:(CGFloat)imageWidth
                 isSelect:(BOOL)isSelect;

@end

NS_ASSUME_NONNULL_END
