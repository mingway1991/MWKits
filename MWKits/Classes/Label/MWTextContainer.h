//
//  MWTextContainer.h
//  MWKits
//
//  Created by 石茗伟 on 2018/9/18.
//

#import <Foundation/Foundation.h>

@class MWTextLine;

NS_ASSUME_NONNULL_BEGIN

@interface MWTextContainer : NSObject <NSCopying, NSCoding>

@property (nullable, copy) UIBezierPath *path;
@property (nullable, copy) NSAttributedString *truncationToken;

@property CGSize size;
@property UIEdgeInsets insets;
@property NSUInteger maximumNumberOfRows;

+ (instancetype)containerWithSize:(CGSize)size;

+ (instancetype)containerWithSize:(CGSize)size insets:(UIEdgeInsets)insets;

@end

NS_ASSUME_NONNULL_END
