//
//  PHCachingImageManager+DefaultManager.m
//  MWKits
//
//  Created by 石茗伟 on 2018/12/21.
//

#import "PHCachingImageManager+DefaultManager.h"

@implementation PHCachingImageManager (DefaultManager)

+ (instancetype)defaultManager {
    static PHCachingImageManager *manager =nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PHCachingImageManager alloc] init];
        
    });
    return manager;
}

@end
