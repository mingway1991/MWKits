//
//  NSObject+MWModel.h
//  MWKits
//
//  Created by 石茗伟 on 2018/9/10.
//

/*
 
 支持功能：
 1.可以调整重新指定映射的字段mw_redirectMapper()
 2.可以根据关键字自定义映射mw_customMappingPropertiesWithKey:value:
 3.NSArray，NSDictionary，配置泛型方法mw_modelContainerPropertyGenericClass()，自动转换model
 4.支持赋值后回调mw_afterSetValueForKey:key
 5.调整日期格式mw_dateFormat()，自动将字符串转成NSDate
 6.自动生成可变数组、可变字典
 
 待支持：
 1.NSCoding、NSCopy自动实现
 2.转json字符串，过滤掉不可转换类型

 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MWModel)

#pragma mark - Init
/**
 类方法：通过数据解析出model的数组
 */
+ (NSArray *)mw_initWithArray:(NSArray *)array;

/**
 类方法：解析dictionary
 */
+ (instancetype)mw_initWithDictionary:(NSDictionary *)dictionary;

/**
 实例方法：解析dictionary
 */
- (instancetype)mw_initWithDictionary:(NSDictionary *)dictionary;

#pragma mark - Custom
/**
 重新指定映射表
 @return NSDictionary @{@"待映射字段":@"需要映射到的字段"}
 */
- (NSDictionary<NSString *, NSString *> *)mw_redirectMapper;

/**
 针对数组和字典，如为自定义对象，为对象指定具体的类型
 @return NSDictionary @{@"属性名":[CustomClass class]}
 */
- (NSDictionary<NSString *, Class> *)mw_modelContainerPropertyGenericClass;

/**
 如果需要则重写该方法，自定义映射
 @param key 字段名
 @param value 字段内容
 @return BOOL YES表示自己定义，则不会自动处理该key。NO表示自动处理该key
 */
- (BOOL)mw_customMappingPropertiesWithKey:(NSString *)key value:(id)value;

/**
 如果需要则重写该方法，处理某个字段赋值之后的操作
 @param key 针对该key赋值之后的处理，类似于其他自定义字段需要在该字段处理后赋值
 */
- (void)mw_afterSetValueForKey:(NSString *)key;

/**
 自定义日期格式
 如需要转成NSDate，根据json中日期字符串格式设置
 @return 新的日期格式，默认"yyyy-MM-dd HH:mm:ss"
 */
- (NSString *)mw_dateFormat;

#pragma mark - Helper
/**
 自定义对象转换成字典
 @return NSDictionary 根据对象转换的字典
 */
- (NSDictionary *)mw_modelConvertDictionary;

/**
 转换成json字符串
 注：一些类型不可以转换成json字符串，如NSDate
 @return NSString 根据对象转成的json字符串
 */
- (NSString *)mw_convertJsonString;

@end

NS_ASSUME_NONNULL_END
