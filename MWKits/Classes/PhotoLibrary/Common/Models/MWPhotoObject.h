//
//  MWPhotoObject.h
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import <Foundation/Foundation.h>

@import Photos;

typedef enum : NSUInteger {
    MWPhotoObjectTypeUndefined = 0,
    MWPhotoObjectTypeAsset,
    MWPhotoObjectTypeImage,
    MWPhotoObjectTypeUrl
} MWPhotoObjectType;

typedef enum : NSUInteger {
    MWAssetTypeNormalImage = 0,
    MWAssetTypeGif,
    MWAssetTypeVideo,
} MWAssetType;

NS_ASSUME_NONNULL_BEGIN

@interface MWPhotoObject : NSObject

@property (nonatomic, assign) MWPhotoObjectType type;

@end

@interface MWAssetPhotoObject : MWPhotoObject

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) MWAssetType assetType;
@property (nonatomic, assign) BOOL isSelect;

@end

@interface MWImagePhotoObject : MWPhotoObject

@property (nonatomic, strong) UIImage *image;

@end

@interface MWUrlPhotoObject : MWPhotoObject

@property (nonatomic, strong) NSString *url;

@end

NS_ASSUME_NONNULL_END
