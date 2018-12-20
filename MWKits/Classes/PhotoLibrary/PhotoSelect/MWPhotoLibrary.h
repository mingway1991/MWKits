//
//  MWPhotoLibrary.h
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MWPhotoLibrary : NSObject

/** 判断拍照权限 */
+ (BOOL)cls_checkCameraAuthorization;

/** 判断相册权限 */
+ (BOOL)cls_checkGalleryAuthorization;

/** 请求拍照权限 */
+ (void)cls_requestCameraAuthorizationWithCompletionHandler:(void(^)(BOOL granted))completionHanlder;

/** 请求相册权限 */
+ (void)cls_requestGalleryAuthorizationWithCompletionHandler:(void(^)(BOOL granted))completionHanlder;

@end

NS_ASSUME_NONNULL_END
