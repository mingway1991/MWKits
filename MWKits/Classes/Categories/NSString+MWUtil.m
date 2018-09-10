//
//  NSString+MWUtil.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/10.
//

#import "NSString+MWUtil.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (MWUtil)

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

@end
