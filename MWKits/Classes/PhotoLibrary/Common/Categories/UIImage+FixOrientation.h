//
//  UIImage+FixOrientation.h
//
//
//  Created by 石茗伟 on 2018/11/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (FixOrientation)

/** 解决旋转90度问题 */
- (UIImage *)mw_fixOrientation;

@end

NS_ASSUME_NONNULL_END
