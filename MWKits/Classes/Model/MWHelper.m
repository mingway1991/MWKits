//
//  MWHelper.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/13.
//

#import "MWHelper.h"

@implementation MWHelper

+ (BOOL)checkClassIsSystemClass:(Class)cls {
    NSBundle *aBundle = [NSBundle bundleForClass:cls];
    if (aBundle == [NSBundle mainBundle]) {
        return NO;
    }
    return YES;
}

@end
