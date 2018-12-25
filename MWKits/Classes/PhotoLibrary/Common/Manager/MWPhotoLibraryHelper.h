//
//  MWPhotoLibraryHelper.h
//  MWKits
//
//  Created by 石茗伟 on 2018/12/25.
//

#import <Foundation/Foundation.h>
#import "MWPhotoObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface MWPhotoLibraryHelper : NSObject

/** 获取对象数组中选中的对象数组 */
+ (NSArray<MWPhotoObject *> *)cls_selectedObjectsWithPhotoObjects:(NSArray<MWPhotoObject *> *)photoObjects;

@end

NS_ASSUME_NONNULL_END
