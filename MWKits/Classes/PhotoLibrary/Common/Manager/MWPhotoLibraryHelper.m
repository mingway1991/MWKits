//
//  MWPhotoLibraryHelper.m
//  MWKits
//
//  Created by 石茗伟 on 2018/12/25.
//

#import "MWPhotoLibraryHelper.h"

@implementation MWPhotoLibraryHelper

+ (NSArray<MWPhotoObject *> *)cls_selectedObjectsWithPhotoObjects:(NSArray<MWPhotoObject *> *)photoObjects {
    NSMutableArray *selectedObjects = [NSMutableArray array];
    for (MWPhotoObject *object in photoObjects) {
        if (object.isSelect) {
            [selectedObjects addObject:object];
        }
    }
    return selectedObjects;
}

@end
