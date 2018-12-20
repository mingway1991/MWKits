//
//  MWPhotoLibrary.m
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import "MWPhotoLibrary.h"

@import Photos;

@implementation MWPhotoLibrary

+ (BOOL)cls_checkCameraAuthorization {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        NSLog(@"相机无访问权限");
        return NO;
    } else {
        NSLog(@"相机有访问权限");
        return YES;
    }
}

+ (BOOL)cls_checkGalleryAuthorization {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        NSLog(@"相册无访问权限");
        return NO;
    }  else {
        NSLog(@"相册有访问权限");
        return YES;
    }
}

+ (void)cls_requestCameraAuthorizationWithCompletionHandler:(void(^)(BOOL granted))completionHanlder {
    NSString *mediaType = AVMediaTypeVideo;
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        completionHanlder(granted);
    }];
}

+ (void)cls_requestGalleryAuthorizationWithCompletionHandler:(void(^)(BOOL granted))completionHanlder {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusRestricted ||
            status == PHAuthorizationStatusDenied) {
            completionHanlder(NO);
        } else {
            completionHanlder(YES);
        }
    }];
}

@end
