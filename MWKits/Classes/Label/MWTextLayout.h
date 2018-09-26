//
//  MWTextLayout.h
//  MWKits
//
//  Created by 石茗伟 on 2018/9/18.
//

#import <Foundation/Foundation.h>
#import "MWTextContainer.h"
#import "MWTextLine.h"

NS_ASSUME_NONNULL_BEGIN

@interface MWTextLayout : NSObject <NSCopying, NSCoding>

@property (nonatomic, readonly) MWTextContainer *container;
@property (nonatomic, strong, readonly) NSArray<MWTextLine *> *lines;
@property (nonatomic, strong, readonly, nullable) MWTextLine *truncatedLine;
@property (nonatomic, readonly) CGSize textBoundingSize;

+ (MWTextLayout *)layoutWithContainerSize:(CGSize)size text:(NSAttributedString *)text;

+ (MWTextLayout *)layoutWithContainer:(MWTextContainer *)container text:(NSAttributedString *)text;

- (void)drawInContext:(nullable CGContextRef)context
                 size:(CGSize)size
                point:(CGPoint)point
                 view:(nullable UIView *)view
                layer:(nullable CALayer *)layer
               cancel:(nullable BOOL(^)(void))cancel;

@end

NS_ASSUME_NONNULL_END
