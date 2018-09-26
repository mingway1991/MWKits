//
//  MWTextData.h
//  MWKits
//
//  Created by 石茗伟 on 2018/9/19.
//

#import <Foundation/Foundation.h>
#import "MWTextLayout.h"

typedef NS_ENUM(NSInteger, MWTextVerticalAlignment) {
    MWTextVerticalAlignmentTop =    0, ///< Top alignment.
    MWTextVerticalAlignmentCenter = 1, ///< Center alignment.
    MWTextVerticalAlignmentBottom = 2, ///< Bottom alignment.
};

@interface MWTextData : NSObject <NSCopying, NSCoding>

#pragma mark - 自定义文本属性
/** 普通文本 **/
@property (nonatomic, strong) NSString *text;
/** 富文本 **/
@property (nonatomic, strong) NSAttributedString *attrText;
/** 普通文本字体 **/
@property (nonatomic, strong) UIFont *font;
/** 普通文本颜色 **/
@property (nonatomic, strong) UIColor *textColor;
/** 内边距 **/
@property (nonatomic) UIEdgeInsets textContainerInset;
/** 显示行数 **/
@property (nonatomic) NSUInteger numberOfLines;
/** 对齐方式 **/
@property (nonatomic) NSTextAlignment textAlignment;
/** 竖向对齐方式 **/
@property (nonatomic) MWTextVerticalAlignment textVerticalAlignment;
/** 最大占用尺寸 **/
@property (nonatomic) CGSize maxSize;

#pragma mark - MWLabel需要配置
/** 内置文本 **/
@property (nonatomic, readonly) NSMutableAttributedString *innerText;
/** container **/
@property (nonatomic, readonly) MWTextContainer *container;
/** layout **/
@property (nonatomic, readonly) MWTextLayout *layout;
/** 文本所占用尺寸 **/
@property (nonatomic, readonly) CGSize textBoundingSize;

@end
