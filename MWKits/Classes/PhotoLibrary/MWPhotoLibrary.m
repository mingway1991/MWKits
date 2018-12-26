//
//  MWPhotoLibrary.m
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import "MWPhotoLibrary.h"
#import "MWGalleryViewController.h"
#import "MWPhotoPreviewViewController.h"
#import "MWCameraViewController.h"
#import "MWNoAuthorizationViewController.h"

@import AVFoundation;
@import Photos;

@implementation MWPhotoLibrary

+ (void)showPhotoLibraryWithConfiguration:(MWPhotoConfiguration *)configuration {
    
    [self cls_photoLibraryAuthorizationWithAuthorizedBlock:^{
        MWGalleryViewController *galleryViewController = [[MWGalleryViewController alloc] init];
        galleryViewController.configuration = configuration;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:galleryViewController];
        nav.navigationBar.barTintColor = configuration.navBarColor;
        nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: configuration.navTitleColor};
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
    } authoryFailBlock:^{
        MWNoAuthorizationViewController *noAuthorizationVc = [[MWNoAuthorizationViewController alloc] init];
        noAuthorizationVc.type = MWPhotoAuthorizationTypePhotoLibrary;
        noAuthorizationVc.configuration = configuration;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:noAuthorizationVc];
        nav.navigationBar.barTintColor = configuration.navBarColor;
        nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: configuration.navTitleColor};
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
    }];
}

+ (void)showCameraWithConfiguration:(MWPhotoConfiguration *)configuration {
    [self cls_cameraAuthorizationWithAuthorizedBlock:^{
        MWCameraViewController *cameraVc = [[MWCameraViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cameraVc];
        nav.navigationBar.barTintColor = configuration.navBarColor;
        nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: configuration.navTitleColor};
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
    } authoryFailBlock:^{
        MWNoAuthorizationViewController *noAuthorizationVc = [[MWNoAuthorizationViewController alloc] init];
        noAuthorizationVc.type = MWPhotoAuthorizationTypeCamera;
        noAuthorizationVc.configuration = configuration;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:noAuthorizationVc];
        nav.navigationBar.barTintColor = configuration.navBarColor;
        nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: configuration.navTitleColor};
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
    }];
}

+ (void)showPhotoPreviewForSelectWithConfiguration:(MWPhotoConfiguration *)configuration
                                      photoObjects:(NSArray<MWPhotoObject *> *)photoObjects
                                             index:(NSInteger)index {
    MWPhotoPreviewViewController *prewviewViewController = [[MWPhotoPreviewViewController alloc] init];
    prewviewViewController.photoObjects = photoObjects;
    prewviewViewController.isPush = NO;
    prewviewViewController.canSelect = YES;
    prewviewViewController.configuration = configuration;
    prewviewViewController.currentIndex = index;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:prewviewViewController];
    nav.navigationBar.barTintColor = configuration.navBarColor;
    nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: configuration.navTitleColor};
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
}

+ (void)showPhotoPreviewWithConfiguration:(MWPhotoConfiguration *)configuration
                             photoObjects:(NSArray<MWPhotoObject *> *)photoObjects
                                    index:(NSInteger)index {
    MWPhotoPreviewViewController *prewviewViewController = [[MWPhotoPreviewViewController alloc] init];
    prewviewViewController.photoObjects = photoObjects;
    prewviewViewController.isPush = NO;
    prewviewViewController.canSelect = NO;
    prewviewViewController.configuration = configuration;
    prewviewViewController.currentIndex = index;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:prewviewViewController];
    nav.navigationBar.barTintColor = configuration.navBarColor;
    nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: configuration.navTitleColor};
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
}

+ (void)cls_photoLibraryAuthorizationWithAuthorizedBlock:(void(^)(void))authorizedBlock
                                        authoryFailBlock:(void(^)(void))authoryFailBlock {
    PHAuthorizationStatus photoAuthorStatus = [PHPhotoLibrary authorizationStatus];
    if (photoAuthorStatus == PHAuthorizationStatusAuthorized) {
        NSLog(@"Authorized");
        authorizedBlock();
    } else if (photoAuthorStatus == PHAuthorizationStatusDenied) {
        NSLog(@"Denied");
        authoryFailBlock();
    } else if (photoAuthorStatus == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                NSLog(@"Authorized");
                authorizedBlock();
            } else {
                NSLog(@"Denied or Restricted");
                authoryFailBlock();
            }
        }];
        NSLog(@"not Determined");
    } else if (photoAuthorStatus == PHAuthorizationStatusRestricted){
        NSLog(@"Restricted");
        authorizedBlock();
    }
}

+ (void)cls_cameraAuthorizationWithAuthorizedBlock:(void(^)(void))authorizedBlock
                                authoryFailBlock:(void(^)(void))authoryFailBlock {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted) {
            NSLog(@"Restricted");
            authoryFailBlock();
        } else if (authStatus == AVAuthorizationStatusDenied) {
            authoryFailBlock();
        } else if (authStatus == AVAuthorizationStatusAuthorized) {
            authorizedBlock();
        } else if (authStatus == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    authorizedBlock();
                } else {
                    authoryFailBlock();
                }
            }];
        }
    } else {
        NSLog(@"No Camera");
        authoryFailBlock();
    }
}

@end
