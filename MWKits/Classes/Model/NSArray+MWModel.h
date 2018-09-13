//
//  NSArray+MWModel.h
//  MWKits
//
//  Created by 石茗伟 on 2018/9/12.
//

#import <Foundation/Foundation.h>

@interface NSArray (MWModel)

/**
 数组转换成数组（自定义类转化为字典）
 */
- (NSArray *)mw_arrayConvertArray;

/**
 转换成json字符串
 */
- (NSString *)mw_convertJsonString;

@end
