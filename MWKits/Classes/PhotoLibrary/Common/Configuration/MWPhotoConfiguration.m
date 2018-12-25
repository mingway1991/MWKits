//
//  MWPhotoConfiguration.m
//  MWKits
//
//  Created by 石茗伟 on 2018/12/24.
//

#import "MWPhotoConfiguration.h"

@implementation MWPhotoConfiguration

+ (instancetype)defaultPhotoConfiguration {
    MWPhotoConfiguration *configuration = [MWPhotoConfiguration new];
    configuration.minSelectCount = 0;
    configuration.maxSelectCount = 9;
    configuration.allowSelectImage = YES;
    configuration.allowSelectGif = YES;
    configuration.allowSelectVideo = YES;
    configuration.allowSelectOriginal = YES;
    configuration.allowSlideSelect = YES;
    configuration.navBarColor = [UIColor whiteColor];
    configuration.navTitleColor = [UIColor blackColor];
    return configuration;
}

@end
