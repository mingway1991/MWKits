//
//  UIColor+MWUtil.h
//  MWKits
//
//  Created by 石茗伟 on 2018/9/10.
//

#import <UIKit/UIKit.h>

@interface UIColor (MWUtil)

/**
 根据十六进制生成UIColor
 
 @param hexString 十六进制字符串
 @return UIColor
 */
+ (UIColor *)mw_colorWithHexString:(NSString *)hexString;

/**
 根据十六进制生成UIColor，带透明度
 
 @param hexString 十六进制字符串
 @param alpha 透明度（0-1）
 @return UIColor
 */
+ (UIColor *)mw_colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

@end
