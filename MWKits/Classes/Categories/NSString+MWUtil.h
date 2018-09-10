//
//  NSString+MWUtil.h
//  MWKits
//
//  Created by 石茗伟 on 2018/9/10.
//

#import <Foundation/Foundation.h>

@interface NSString (MWUtil)

/**
 判断字符串是否为空
 
 @return 如果为空返回`YES`  不为空返回`NO`    若果传入这些字符(nil @"" @" "  @"   ")，结果为`YES`
 */
- (BOOL)mwCheckEmpty;

/**
 判断是否是有效的邮箱
 
 @return 如果是有效的邮箱，返回`YES`  否则返回`NO`
 */
- (BOOL)mwIsValidEmail;

/**
 判断是否是有效的身份证号码
 
 @return 如果是有效的身份证号，返回`YES`, 否则返回`NO`
 
 仅允许  数字 && 最后一位是{数字 || Xx}）
 */
- (BOOL)mwIsVaildIDCardNo;

/**
 md5加密
 
 @return 加密字串
 */
- (NSString *)mwMD5;

/**
 SHA1加密
 
 @return 加密字串
 */
- (NSString *)mwSHA1;

@end
