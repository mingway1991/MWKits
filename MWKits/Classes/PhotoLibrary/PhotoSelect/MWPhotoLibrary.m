//
//  MWPhotoLibrary.m
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import "MWPhotoLibrary.h"
#import "PHCachingImageManager+DefaultManager.h"

@import Photos;

@implementation MWPhotoLibrary

+ (BOOL)cls_checkCameraAuthorization {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        NSLog(@"相机无访问权限");
        return NO;
    }
    NSLog(@"相机有访问权限");
    return YES;
}

+ (BOOL)cls_checkGalleryAuthorization {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        NSLog(@"相册无访问权限");
        return NO;
    }
    NSLog(@"相册有访问权限");
    return YES;
}

+ (BOOL)cls_checkMicrophoneAuthorization {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (status == AVAuthorizationStatusRestricted ||
        status == AVAuthorizationStatusDenied) {
        NSLog(@"麦克风无访问权限");
        return NO;
    }
    NSLog(@"麦克风有访问权限");
    return YES;
}

+ (void)cls_requestCameraAuthorizationWithCompletionHandler:(void(^)(BOOL granted))completionHanlder {
    NSString *mediaType = AVMediaTypeVideo;
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHanlder(granted);
        });
    }];
}

+ (void)cls_requestGalleryAuthorizationWithCompletionHandler:(void(^)(BOOL granted))completionHanlder {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusRestricted ||
            status == PHAuthorizationStatusDenied) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHanlder(NO);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHanlder(YES);
            });
        }
    }];
}

+ (BOOL)cls_isGifWithAsset:(PHAsset *)asset {
    __block BOOL isGIFImage = NO;
    if (@available(iOS 9.0, *)) {
        NSArray *resourceList = [PHAssetResource assetResourcesForAsset:asset];
        [resourceList enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAssetResource *resource = obj;
            if ([resource.uniformTypeIdentifier isEqualToString:@"com.compuserve.gif"]) {
                isGIFImage = YES;
            }
        }];
    } else {
        
    }
    return isGIFImage;
}

+ (UIImage *)cls_screenshotPlayerItem:(AVPlayerItem *)playerItem
                              seconds:(Float64)seconds {
    if (!playerItem) {
        return nil;
    }
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:playerItem.asset];
    
    if (!generator) {
        return nil;
    }
    //防止时间出现偏差
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    CMTime time = kCMTimeZero;
    if (seconds > 0) {
        CMTimeScale timeScale = playerItem.asset.duration.timescale;
        time = CMTimeMakeWithSeconds(seconds, timeScale);
    } else {
        time = playerItem.currentTime;
    }
    
    CMTime actualTime;
    NSError *error;
    CGImageRef cgImage = [generator copyCGImageAtTime:time
                                           actualTime:&actualTime
                                                error:&error];
    if (!cgImage) {
        return nil;
    }
    
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CFRelease(cgImage);
    
    if (nil != error) {
        return nil;
    }
    
    return image;
}

+ (void)cls_requestVideoForAsset:(PHAsset *)asset
                      completion:(void (^)(AVPlayerItem *item, NSDictionary *info))completion {
    [[PHCachingImageManager defaultManager] requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        if (completion) completion(playerItem, info);
    }];
}

+ (PHImageRequestID)cls_requestImageForAsset:(PHAsset *)asset
                                        size:(CGSize)size
                                  resizeMode:(PHImageRequestOptionsResizeMode)resizeMode
                                  completion:(void (^)(UIImage *image, NSDictionary *info))completion {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    /**
     resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 true 时有效。
     */
    
    option.resizeMode = resizeMode;//控制照片尺寸
    //    option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;//控制照片质量
    option.networkAccessAllowed = YES;
    
    /*
     info字典提供请求状态信息:
     PHImageResultIsInCloudKey：图像是否必须从iCloud请求
     PHImageResultIsDegradedKey：当前UIImage是否是低质量的，这个可以实现给用户先显示一个预览图
     PHImageResultRequestIDKey和PHImageCancelledKey：请求ID以及请求是否已经被取消
     PHImageErrorKey：如果没有图像，字典内的错误信息
     */
    
    return [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey];
        //不要该判断，即如果该图片在iCloud上时候，会先显示一张模糊的预览图，待加载完毕后会显示高清图
        // && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]
        if (downloadFinined && completion) {
            completion(image, info);
        }
    }];
}

+ (void)cls_requestOriginalImageDataForAsset:(PHAsset *)asset
                                  completion:(void (^)(NSData *data, NSDictionary *info))completion {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && imageData) {
            if (completion) completion(imageData, info);
        }
    }];
}

+ (void)cls_requestOriginalImageForAsset:(PHAsset *)asset
                              completion:(void (^)(UIImage *image, NSDictionary *info))completion {
    [self cls_requestImageForAsset:asset size:CGSizeMake(asset.pixelWidth, asset.pixelHeight) resizeMode:PHImageRequestOptionsResizeModeNone completion:completion];
}

@end
