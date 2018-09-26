//
//  MWLabel.h
//  MWKits
//
//  Created by 石茗伟 on 2018/9/18.
//

#import <UIKit/UIKit.h>
#import "MWTextData.h"

NS_ASSUME_NONNULL_BEGIN

@interface MWLabel : UIView

#pragma mark - 普通按照属性配置
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

#pragma mark - 使用对象配置
/** Data配置 **/
@property (nonatomic) MWTextData *data;

- (void)updateWithData:(MWTextData *)data;

@end

NS_ASSUME_NONNULL_END
