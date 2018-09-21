//
//  MWClassInfo.h
//  MWKits
//
//  Created by 石茗伟 on 2018/9/14.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

/** 属性类型 **/
typedef NS_ENUM (NSUInteger, MWPropertyType) {
    MWPropertyTypeUnknown    = 0, //未知类型，包含自定义类型
    
    //基础类型
    MWPropertyTypeVoid       = 1, ///< void
    MWPropertyTypeBool       = 2, ///< bool
    MWPropertyTypeInt8       = 3, ///< char / BOOL
    MWPropertyTypeUInt8      = 4, ///< unsigned char
    MWPropertyTypeInt16      = 5, ///< short
    MWPropertyTypeUInt16     = 6, ///< unsigned short
    MWPropertyTypeInt32      = 7, ///< int
    MWPropertyTypeUInt32     = 8, ///< unsigned int
    MWPropertyTypeInt64      = 9, ///< long long
    MWPropertyTypeUInt64     = 10, ///< unsigned long long
    MWPropertyTypeFloat      = 11, ///< float
    MWPropertyTypeDouble     = 12, ///< double
    MWPropertyTypeLongDouble = 13, ///< long double
    MWPropertyTypeClass      = 14, ///< Class
    MWPropertyTypeSEL        = 15, ///< SEL
    MWPropertyTypeBlock      = 16, ///< block
    MWPropertyTypePointer    = 17, ///< void*
    MWPropertyTypeStruct     = 18, ///< struct
    MWPropertyTypeUnion      = 19, ///< union
    MWPropertyTypeCString    = 20, ///< char*
    MWPropertyTypeCArray     = 21, ///< char[10] (for example)
    
    //对象类型
    MWPropertyTypeNSString              = 22,
    MWPropertyTypeNSMutableString       = 23,
    MWPropertyTypeNSValue               = 24,
    MWPropertyTypeNSNumber              = 25,
    MWPropertyTypeNSDecimalNumber       = 26,
    MWPropertyTypeNSData                = 27,
    MWPropertyTypeNSMutableData         = 28,
    MWPropertyTypeNSDate                = 29,
    MWPropertyTypeNSURL                 = 30,
    MWPropertyTypeNSArray               = 31,
    MWPropertyTypeNSMutableArray        = 32,
    MWPropertyTypeNSDictionary          = 33,
    MWPropertyTypeNSMutableDictionary   = 34,
    MWPropertyTypeNSSet                 = 35,
    MWPropertyTypeNSMutableSet          = 36,
};

@interface MWPropertyInfo : NSObject <NSCopying>

//原始数据
@property (nonatomic, readonly) objc_property_t property;
@property (nonatomic, copy, readonly) NSString *propertyName;
@property (nonatomic, copy, readonly) NSString *attrType; //property的objc_property_attribute_t记录的type字符串
@property (nonatomic, readonly) SEL getter;
@property (nonatomic, readonly) SEL setter;
//自己转化的
@property (nonatomic, readonly, nullable) Class cls;
@property (nonatomic, readonly) MWPropertyType type;//通过attrType转化的枚举类型
@property (nonatomic, readonly) BOOL isNumber;//是否是基本数据类型
@property (nonatomic, readonly) BOOL isFromFoundation;//是否是系统类型

- (instancetype)initWithProperty:(objc_property_t)property;

@end


@interface MWClassInfo : NSObject <NSCopying>

@property (nonatomic, assign, readonly) Class cls;
@property (nonatomic, copy, readonly) NSString *className;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, MWPropertyInfo *> *propertyDict;

+ (instancetype)classInfoWithClass:(Class)cls;

@end

NS_ASSUME_NONNULL_END
