//
//  MWTextContainer.h
//  MWKits
//
//  Created by 石茗伟 on 2018/9/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MWTextContainer : NSObject <NSCopying>

@property CGSize size;
@property UIEdgeInsets insets;
@property (nullable, copy) UIBezierPath *path;
@property NSUInteger maximumNumberOfRows;
@property BOOL isVertical;

+ (instancetype)containerWithSize:(CGSize)size;

+ (instancetype)containerWithSize:(CGSize)size insets:(UIEdgeInsets)insets;

@end

NS_ASSUME_NONNULL_END
