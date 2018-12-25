//
//  MWPhotoLibrary.m
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import "MWPhotoLibrary.h"
#import "MWGalleryViewController.h"
#import "MWPhotoPreviewViewController.h"

@implementation MWPhotoLibrary

+ (void)showPhotoLibraryWithConfiguration:(MWPhotoConfiguration *)configuration {
    MWGalleryViewController *galleryViewController = [[MWGalleryViewController alloc] init];
    galleryViewController.configuration = configuration;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:galleryViewController];
    nav.navigationBar.barTintColor = configuration.navBarColor;
    nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: configuration.navTitleColor};
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:^{
        
    }];
}

+ (void)showPhotoPreviewWithPhotoObjects:(NSArray<MWPhotoObject *> *)photoObjects {
    MWPhotoConfiguration *configuration = [MWPhotoConfiguration defaultPhotoConfiguration];
    
    MWPhotoPreviewViewController *prewviewViewController = [[MWPhotoPreviewViewController alloc] init];
    prewviewViewController.photoObjects = photoObjects;
    prewviewViewController.isPush = NO;
    prewviewViewController.configuration = configuration;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:prewviewViewController];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:^{
        
    }];
}

@end
