//
//  MWPhotoPreviewCell.h
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import <UIKit/UIKit.h>
#import "MWPhotoObject.h"

@import Photos;

NS_ASSUME_NONNULL_BEGIN

@interface MWPhotoPreviewCell : UICollectionViewCell

/**
 更新UI
 
 @param photoObject 图片对象
 */
- (void)updateUIWithPhotoObject:(MWPhotoObject *)photoObject;

@end

NS_ASSUME_NONNULL_END
