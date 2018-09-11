//
//  UIImage+MWUtil.h
//  MWKits
//
//  Created by 石茗伟 on 2018/9/10.
//

#import <UIKit/UIKit.h>

@interface UIImage (MWUtil)

/**
 生成特定大小、特定颜色的图片
 
 @param color 需要生成的颜色
 @param size 需要生成的图片大小
 @return UIImage
 */
+ (UIImage *)mw_imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 根据base64字符串生成图片
 
 @param base64Str base64字符串
 @return UIImage
 */
+ (UIImage *)mw_imageWithBase64String:(NSString *)base64Str;

/**
 图片生成base64字符串
 
 @param UIImage 需要转化的图片
 @return NSString base64字符串
 */
+ (NSString *)mw_base64StringFromImage:(UIImage *)image;

@end
