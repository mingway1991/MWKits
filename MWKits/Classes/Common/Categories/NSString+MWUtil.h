//
//  NSString+MWUtil.h
//  MWKits
//
//  Created by 石茗伟 on 2018/9/10.
//

#import <Foundation/Foundation.h>

@interface NSString (MWUtil)

#pragma mark - 校验
/**
 判断字符串是否为空
 
 @return 如果为空返回`YES`  不为空返回`NO`    若果传入这些字符(nil @"" @" "  @"   ")，结果为`YES`
 */
- (BOOL)mw_checkEmpty;

/**
 判断是否是有效的邮箱
 
 @return 如果是有效的邮箱，返回`YES`  否则返回`NO`
 */
- (BOOL)mw_isValidEmail;

/**
 判断是否是有效的身份证号码
 
 @return 如果是有效的身份证号，返回`YES`, 否则返回`NO`
 
 仅允许  数字 && 最后一位是{数字 || Xx}）
 */
- (BOOL)mw_isVaildIDCardNo;

#pragma mark - 加密
/**
 md5加密
 
 @return 加密字串
 */
- (NSString *)mw_MD5;

/**
 SHA1加密
 
 @return 加密字串
 */
- (NSString *)mw_SHA1;

#pragma mark - 格式化
/**
 金额类的字符串格式化,例
 0 --> 0.00
 123 --> 123.00
 123.456 --> 123.46
 102000 --> 102,000.00
 10204500 --> 10,204,500.00
 */
- (NSString *)mw_moneyFormat;

@end
