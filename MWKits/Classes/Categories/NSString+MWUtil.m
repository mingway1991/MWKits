//
//  NSString+MWUtil.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/10.
//

#import "NSString+MWUtil.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (MWUtil)

#pragma mark - 校验
- (BOOL)mwCheckEmpty {
    if (self == nil) return self == nil;
    NSString *newStr = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [newStr isEqualToString:@""];
}

- (BOOL)mwIsValidEmail {
    if ([self mwCheckEmpty]) return NO;
    
    NSString *emailRegex = @"^(([a-zA-Z0-9_-]+)|([a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)))@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)+$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

- (BOOL)mwIsVaildIDCardNo {
    if ([self mwCheckEmpty]) return NO;
    
    NSString *regxStr = @"^[1-9][0-9]{5}[1-9][0-9]{3}((0[0-9])|(1[0-2]))(([0|1|2][0-9])|3[0-1])[0-9]{3}([0-9]|X|x)$";
    
    NSPredicate *idcardTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regxStr];
    return [idcardTest evaluateWithObject:self];
}

#pragma mark - 加密
- (NSString *)mwMD5 {
    const char *orgin_cstr = [self UTF8String];
    unsigned char result_cstr[CC_MD5_DIGEST_LENGTH];
    CC_MD5(orgin_cstr, (CC_LONG)strlen(orgin_cstr), result_cstr);
    NSMutableString *result_str = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result_str appendFormat:@"%02X", result_cstr[i]];
    }
    return [result_str lowercaseString];
}

- (NSString *)mwSHA1 {
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

#pragma mark - 格式化
- (NSString *)mwMoneyFormat {
    if ([self mwCheckEmpty]) return self;
    
    BOOL hasPoint = NO;
    if ([self rangeOfString:@"."].length > 0) {
        hasPoint = YES;
    }
    
    NSMutableString *pointMoney = [NSMutableString stringWithString:self];
    if (hasPoint == NO) {
        [pointMoney appendString:@".00"];
    }
    
    NSArray *moneys = [pointMoney componentsSeparatedByString:@"."];
    if (moneys.count > 2) {
        return pointMoney;
    } else if (moneys.count == 1) {
        return [NSString stringWithFormat:@"%@.00", moneys[0]];
    } else {
        // 整数部分每隔 3 位插入一个逗号
        NSString *frontMoney = [self mwStringFormatToThreeBit:moneys[0]];
        if ([frontMoney isEqualToString:@""]) {
            frontMoney = @"0";
        }
        // 拼接整数和小数两部分
        NSString *backMoney = moneys[1];
        if ([backMoney length] == 1) {
            return [NSString stringWithFormat:@"%@.%@0", frontMoney, backMoney];
        } else if ([backMoney length] > 2) {
            return [NSString stringWithFormat:@"%@.%@", frontMoney, [backMoney substringToIndex:2]];
        } else {
            return [NSString stringWithFormat:@"%@.%@", frontMoney, backMoney];
        }
    }
}

- (NSString *)mwStringFormatToThreeBit:(NSString *)string {
    NSString *tempString = [string stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSMutableString *mutableString = [NSMutableString stringWithString:tempString];
    NSInteger n = 2;
    for (NSInteger i = tempString.length - 3; i > 0; i--) {
        n++;
        if (n == 3) {
            [mutableString insertString:@"," atIndex:i];
            n = 0;
        }
    }
    return mutableString;
}

@end
