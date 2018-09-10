//
//  UIImage+MWUtil.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/10.
//

#import "UIImage+MWUtil.h"

@implementation UIImage (MWUtil)

#pragma mark - ColorToImage
+ (UIImage *)mwImageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - base64ToImage
+ (UIImage *)mwImageWithBase64String:(NSString *)base64Str {
    NSString *str = [NSString string];
    if ([base64Str hasPrefix:@"data:image/jpg;base64,"]) {
        str = base64Str;
    } else {
        str = [NSString stringWithFormat:@"%@%@", @"data:image/jpg;base64,", base64Str];
    }
    
    NSURL *url = [NSURL URLWithString:str];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    
    return [UIImage mwImageWithImgData:imageData];
}

+ (UIImage *)mwImageWithImgData:(NSData *)imgData {
    return [UIImage imageWithData:imgData scale:[UIScreen mainScreen].scale];
}

#pragma mark - ImageToBase64
+ (NSString *)mwBase64StringFromImage:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    return [UIImage mwBase64forData:imageData];
}

+ (NSString*)mwBase64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i,i2;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        for (i2=0; i2<3; i2++) {
            value <<= 8;
            if (i+i2 < length) {
                value |= (0xFF & input[i+i2]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
