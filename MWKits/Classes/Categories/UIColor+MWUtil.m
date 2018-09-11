//
//  UIColor+MWUtil.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/10.
//

#import "UIColor+MWUtil.h"

@implementation UIColor (MWUtil)

#pragma mark - HexColor
+ (UIColor *)mw_colorWithHexString:(NSString *)hexString {
    return [self mw_colorWithHexString:hexString alpha:1.0f];
}

+ (UIColor *)mw_colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha {
    
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString length] < 6)
        return nil;
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return nil;
    
    NSString *rString = [cString substringWithRange:NSMakeRange(0, 2)];
    NSString *gString = [cString substringWithRange:NSMakeRange(2, 2)];
    NSString *bString = [cString substringWithRange:NSMakeRange(4, 2)];
    
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    UIColor *hexColor = [UIColor colorWithRed:((float) r / 255.0f)
                                        green:((float) g / 255.0f)
                                         blue:((float) b / 255.0f)
                                        alpha:alpha];
    return hexColor;
}


@end
