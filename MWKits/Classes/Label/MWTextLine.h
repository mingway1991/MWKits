//
//  MWTextLine.h
//  MWLabel
//
//  Created by 石茗伟 on 2018/9/17.
//

#import <Foundation/Foundation.h>
@import CoreText;

NS_ASSUME_NONNULL_BEGIN

@interface MWTextLine : NSObject <NSCopying, NSCoding>

@property (nonatomic) NSUInteger index;
@property (nonatomic) NSUInteger row;

@property (nonatomic, readonly) CTLineRef CTLine;
@property (nonatomic, readonly) NSRange range;
@property (nonatomic) CGPoint position;
@property (nonatomic, readonly) CGFloat ascent;
@property (nonatomic, readonly) CGFloat descent;
@property (nonatomic, readonly) CGFloat leading;
@property (nonatomic, readonly) CGFloat lineWidth;
@property (nonatomic, readonly) CGFloat trailingWhitespaceWidth;

@property (nonatomic, readonly) CGRect bounds; 
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) CGFloat width;
@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, readonly) CGFloat top;
@property (nonatomic, readonly) CGFloat bottom;
@property (nonatomic, readonly) CGFloat left;
@property (nonatomic, readonly) CGFloat right;

+ (instancetype)lineWithCTLine:(CTLineRef)CTLine position:(CGPoint)position;

@end

NS_ASSUME_NONNULL_END
