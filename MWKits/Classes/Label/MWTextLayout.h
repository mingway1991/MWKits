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

@interface MWTextLayout : NSObject

/** 绘制容器 **/
@property (nonatomic, readonly) MWTextContainer *container;
/** 绘制的行信息数组 **/
@property (nonatomic, strong, readonly) NSArray<MWTextLine *> *lines;
/** 截断行 **/
@property (nullable, nonatomic, strong, readonly) MWTextLine *truncatedLine;
/** 行数 **/
@property (nonatomic, readonly) NSUInteger rowCount;
/** 内容区域frame **/
@property (nonatomic, readonly) CGRect textBoundingRect;
/** 内容区域大小 **/
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
