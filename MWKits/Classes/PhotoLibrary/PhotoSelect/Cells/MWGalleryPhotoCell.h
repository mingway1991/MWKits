//
//  MWGalleryPhotoCell.h
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import <UIKit/UIKit.h>
#import "MWPhotoObject.h"

@import Photos;
@class MWGalleryPhotoCell;

NS_ASSUME_NONNULL_BEGIN

@protocol MWGalleryPhotoCellDelegate <NSObject>

- (void)photoCell:(MWGalleryPhotoCell *)photoCell selectAssetObject:(MWAssetPhotoObject *)assetObject isSelect:(BOOL)isSelect;

@end

@interface MWGalleryPhotoCell : UICollectionViewCell

@property (nonatomic, weak) id<MWGalleryPhotoCellDelegate> delegate;

/**
 更新UI
 
 @param assetObject 图片对象
 @param imageWidth 需要显示的图片宽度
 */
- (void)updateUIWithAssetObject:(MWAssetPhotoObject *)assetObject
                     imageWidth:(CGFloat)imageWidth;

@end

NS_ASSUME_NONNULL_END
