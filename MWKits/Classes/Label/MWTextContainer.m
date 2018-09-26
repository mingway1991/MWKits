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
    one.maximumNumberOfRows = 0;
    return one;
}

#pragma mark - Copying
- (instancetype)copyWithZone:(NSZone *)zone {
    MWTextContainer *container = [[MWTextContainer alloc] init];
    container->_size = _size;
    container->_insets = _insets;
    container->_maximumNumberOfRows = _maximumNumberOfRows;
    container->_path = _path;
    container->_truncationToken = _truncationToken;
    return container;
}

#pragma mark - NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _size = [[aDecoder decodeObjectForKey:@"size"] CGSizeValue];
        _insets = [[aDecoder decodeObjectForKey:@"insets"] UIEdgeInsetsValue];
        _maximumNumberOfRows = [aDecoder decodeIntegerForKey:@"maximumNumberOfRows"];
        _path = [aDecoder decodeObjectForKey:@"path"];
        _truncationToken = [aDecoder decodeObjectForKey:@"truncationToken"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(_size) forKey:@"size"];
    [aCoder encodeObject:[NSValue valueWithUIEdgeInsets:_insets] forKey:@"insets"];
    [aCoder encodeInteger:_maximumNumberOfRows forKey:@"maximumNumberOfRows"];
    [aCoder encodeObject:_path forKey:@"path"];
    [aCoder encodeObject:_truncationToken forKey:@"truncationToken"];
}

@end
