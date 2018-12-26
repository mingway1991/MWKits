//
//  MWAssetManager.h
//  MWKits
//
//  Created by 石茗伟 on 2018/12/24.
//

#import <Foundation/Foundation.h>

@import Photos;

NS_ASSUME_NONNULL_BEGIN

@interface MWAssetManager : NSObject

#pragma mark - Gif
+ (BOOL)cls_isGifWithAsset:(PHAsset *)asset;

+ (UIImage *)cls_transformToGifImageWithData:(NSData *)data;

#pragma mark - Video
/** 获取视频资源截图 */
+ (UIImage *)cls_screenshotPlayerItem:(AVPlayerItem *)playerItem
                              seconds:(Float64)seconds;

/**
 请求视频
 
 @param asset 视频资源
 @param completion 完成回调
 */
+ (void)cls_requestVideoForAsset:(PHAsset *)asset
                      completion:(void (^)(AVPlayerItem *item, NSDictionary *info))completion;

#pragma mark - Image
/**
 按照尺寸请求图片
 
 @param asset 图片资源
 @param size 需要的大小
 @param resizeMode 调整模式
 @param completion 完成回调
 */
+ (PHImageRequestID)cls_requestImageForAsset:(PHAsset *)asset
                                        size:(CGSize)size
                                  resizeMode:(PHImageRequestOptionsResizeMode)resizeMode
                                  completion:(void (^)(UIImage *image, NSDictionary *info))completion;

/**
 请求原始图片data
 
 @param asset 图片资源
 @param completion 完成回调
 */
+ (void)cls_requestOriginalImageDataForAsset:(PHAsset *)asset
                                  completion:(void (^)(NSData *data, NSDictionary *info))completion;

/**
 请求原始图片
 
 @param asset 图片资源
 @param completion 完成回调
 */
+ (void)cls_requestOriginalImageForAsset:(PHAsset *)asset
                              completion:(void (^)(UIImage *image, NSDictionary *info))completion;

@end

NS_ASSUME_NONNULL_END
