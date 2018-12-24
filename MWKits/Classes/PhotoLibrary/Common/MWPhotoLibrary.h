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

+ (void)showPhotoLibraryWithConfiguration:(MWPhotoConfiguration *)configuration;

+ (void)showPhotoPreviewWithPhotoObjects:(NSArray<MWPhotoObject *> *)photoObjects;

@end

NS_ASSUME_NONNULL_END
