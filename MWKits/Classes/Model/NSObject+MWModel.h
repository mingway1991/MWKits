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
 5.自动将字符串转成NSDate
 6.NSCoding、NSCopy自动实现(MWCodingImplementation,MWCopingImplementation)
 
 待优化：
 1.转化类型异常处理
 2.classInfo支持更新
 
 优化内容
 1.建立classInfo和propertyInfo，用于收集各个类的信息，并用缓存存放起来
 2.根据property中attribute信息，将属性类型区分（分为基础数据类型、系统类型、自定义类型 三大类）
 3.兼容容器类中自定义模型的转化
 4.不使用setValue:forKey:，改为使用objc_msgSend调用getter和setter来赋值和取值
 
 YYModel作者优化建议
 缓存Model JSON 转换过程中需要很多类的元数据，如果数据足够小，则全部缓存到内存中。
 查表当遇到多项选择的条件时，要尽量使用查表法实现，比如 switch/case，C Array，如果查表条件是对象，则可以用 NSDictionary 来实现。
 避免 KVCKey-Value Coding 使用起来非常方便，但性能上要差于直接调用 Getter/Setter，所以如果能避免 KVC 而用 Getter/Setter 代替，性能会有较大提升。
 避免 Getter/Setter 调用如果能直接访问 ivar，则尽量使用 ivar 而不要使用 Getter/Setter 这样也能节省一部分开销。
 避免多余的内存管理方法在 ARC 条件下，默认声明的对象是 strong 类型的，赋值时有可能会产生 retain/release 调用，如果一个变量在其生命周期内不会被释放，则使用 unsafe_unretained 会节省很大的开销。访问具有 weak 属性的变量时，实际上会调用 objc_loadWeak() 和 objc_storeWeak() 来完成，这也会带来很大的开销，所以要避免使用 weak 属性。创建和使用对象时，要尽量避免对象进入 autoreleasepool，以避免额外的资源开销。
 遍历容器类时，选择更高效的方法相对于 Foundation 的方法来说，CoreFoundation 的方法有更高的性能，用 CFArrayApplyFunction() 和 CFDictionaryApplyFunction() 方法来遍历容器类能带来不少性能提升，但代码写起来会非常麻烦。
 尽量用纯 C 函数、内联函数使用纯 C 函数可以避免 ObjC 的消息发送带来的开销。如果 C 函数比较小，使用 inline 可以避免一部分压栈弹栈等函数调用的开销。
 减少遍历的循环次数在 JSON 和 Model 转换前，Model 的属性个数和 JSON 的属性个数都是已知的，这时选择数量较少的那一方进行遍历，会节省很多时间。

 */

#define MWCodingImplementation \
- (id)initWithCoder:(NSCoder *)decoder \
{ \
if (self = [super init]) { \
[self mw_deCoder:decoder]; \
} \
return self; \
} \
\
- (void)encodeWithCoder:(NSCoder *)encoder \
{ \
[self mw_encodeWithCoder:encoder]; \
}

#define MWCopingImplementation \
- (id)copyWithZone:(NSZone *)zone \
{\
return [self mw_copy]; \
} \

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

#pragma mark - NSCoding
- (void)mw_encodeWithCoder:(NSCoder *)aCoder;
- (void)mw_deCoder:(NSCoder *)coder;

#pragma mark - NSCoping
- (instancetype)mw_copy;

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
