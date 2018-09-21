//
//  MWLabel.h
//  MWKits
//
//  Created by 石茗伟 on 2018/9/18.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MWTextVerticalAlignment) {
    MWTextVerticalAlignmentTop =    0, ///< Top alignment.
    MWTextVerticalAlignmentCenter = 1, ///< Center alignment.
    MWTextVerticalAlignmentBottom = 2, ///< Bottom alignment.
};

NS_ASSUME_NONNULL_BEGIN

@interface MWLabel : UIView

/** 普通文本 **/
@property (nonatomic, strong, setter=setText:) NSString *text;
/** 富文本 **/
@property (nonatomic, strong, setter=setAttrText:) NSAttributedString *attrText;
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
/** 是否竖排 **/
@property (nonatomic) BOOL isVertical;

@end

NS_ASSUME_NONNULL_END
