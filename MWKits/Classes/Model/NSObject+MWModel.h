//
//  NSObject+MWModel.h
//  MWKits
//
//  Created by 石茗伟 on 2018/9/10.
//

/*
 
 1.可以调整重新指定映射的字段
 2.可以根据关键字自定义映射
 3.调整日期格式

 */

#import <Foundation/Foundation.h>

@interface NSObject (MWModel)

#pragma mark - Init
/**
 通过数据解析出model的数组
 */
+ (NSArray *)mw_initWithArray:(NSArray *)array;

/**
 解析dictionary
 */
- (instancetype)mw_initWithDictionary:(NSDictionary *)dictionary;

#pragma mark - Custom
/**
 将原key指向其他字段，默认返回原始值
 */
- (NSString *)mw_redirectForKey:(NSString *)key;

/**
 如果需要则重写该方法，自定义映射
 @param key 字段名
 @param value 字段内容
 @return YES表示自己定义，则不会自动处理该key。NO表示自动处理该key
 */
- (BOOL)mw_customMappingPropertiesWithKey:(NSString *)key value:(id)value;

/**
 如果需要则重写该方法，处理某个字段赋值之后的操作
 */
- (void)mw_afterSetValueForKey:(NSString *)key;

/**
 重写，自定义日期格式，默认yyyy-MM-dd HH:mm:ss
 */
- (NSString *)mw_dateFormat;

#pragma mark - Helper
/**
 转换成json字符串
 */
- (NSString *)mw_convertJsonString;

@end
