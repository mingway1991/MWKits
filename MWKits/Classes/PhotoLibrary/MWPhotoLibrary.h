//
//  MWPhotoLibrary.h
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import <Foundation/Foundation.h>
#import "MWPhotoConfiguration.h"
#import "MWPhotoObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface MWPhotoLibrary : NSObject

/** 选择相册库 */
+ (void)showPhotoLibraryWithConfiguration:(MWPhotoConfiguration *)configuration;

/** 选择相机 */
+ (void)showCameraWithConfiguration:(MWPhotoConfiguration *)configuration;

/** 选择预览 */
+ (void)showPhotoPreviewForSelectWithConfiguration:(MWPhotoConfiguration *)configuration
                                      photoObjects:(NSArray<MWPhotoObject *> *)photoObjects
                                             index:(NSInteger)index;

/** 普通预览 */
+ (void)showPhotoPreviewWithConfiguration:(MWPhotoConfiguration *)configuration
                             photoObjects:(NSArray<MWPhotoObject *> *)photoObjects
                                    index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
