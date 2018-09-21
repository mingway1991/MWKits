//
//  MWTextContainer.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/18.
//

#import "MWTextContainer.h"

@implementation MWTextContainer

+ (instancetype)containerWithSize:(CGSize)size {
    return [self containerWithSize:size insets:UIEdgeInsetsZero];
}

+ (instancetype)containerWithSize:(CGSize)size insets:(UIEdgeInsets)insets {
    MWTextContainer *one = [self new];
    one.size = size;
    one.insets = insets;
    return one;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    MWTextContainer *container = [[MWTextContainer alloc] init];
    container->_size = _size;
    container->_insets = _insets;
    return container;
}

@end
