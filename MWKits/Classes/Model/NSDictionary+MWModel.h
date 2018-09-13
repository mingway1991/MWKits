//
//  NSDictionary+MWModel.h
//  MWKits
//
//  Created by 石茗伟 on 2018/9/12.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (MWModel)

/**
 字典转换成字典（自定义类转化为字典）
 */
- (NSDictionary *)mw_dictionaryConvertDictionary;

/**
 转换成json字符串
 */
- (NSString *)mw_convertJsonString;

@end
