//
//  NSObject+MWModel.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/10.
//

#import "NSObject+MWModel.h"
#import "MWDefines.h"
#import "MWClassInfo.h"
#import <objc/runtime.h>
#import <objc/message.h>

#pragma mark - Convert
static force_inline NSDateFormatter *MWISODateFormatter() {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    return formatter;
}

/**
 将id类型转化成NSNumber
 取自于MWModel
 */
static force_inline NSNumber *mw_NSNumberCreateFromID(__unsafe_unretained id value) {
    static NSCharacterSet *dot;
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        dic = @{@"TRUE" :   @(YES),
                @"True" :   @(YES),
                @"true" :   @(YES),
                @"FALSE" :  @(NO),
                @"False" :  @(NO),
                @"false" :  @(NO),
                @"YES" :    @(YES),
                @"Yes" :    @(YES),
                @"yes" :    @(YES),
                @"NO" :     @(NO),
                @"No" :     @(NO),
                @"no" :     @(NO),
                @"NIL" :    (id)kCFNull,
                @"Nil" :    (id)kCFNull,
                @"nil" :    (id)kCFNull,
                @"NULL" :   (id)kCFNull,
                @"Null" :   (id)kCFNull,
                @"null" :   (id)kCFNull,
                @"(NULL)" : (id)kCFNull,
                @"(Null)" : (id)kCFNull,
                @"(null)" : (id)kCFNull,
                @"<NULL>" : (id)kCFNull,
                @"<Null>" : (id)kCFNull,
                @"<null>" : (id)kCFNull};
    });
    
    if (!value || value == (id)kCFNull) return nil;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) {
        NSNumber *num = dic[value];
        if (num) {
            if (num == (id)kCFNull) return nil;
            return num;
        }
        if ([(NSString *)value rangeOfCharacterFromSet:dot].location != NSNotFound) {
            const char *cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            double num = atof(cstring);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        } else {
            const char *cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            return @(atoll(cstring));
        }
    }
    return nil;
}

/**
 将字符串转化成NSDate
 取自于MWModel
 */
static force_inline NSDate *mw_NSDateFromString(__unsafe_unretained NSString *string) {
    typedef NSDate* (^MWNSDateParseBlock)(NSString *string);
#define kParserNum 34
    static MWNSDateParseBlock blocks[kParserNum + 1] = {0};
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
            /*
             2014-01-20  // Google
             */
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter.dateFormat = @"MWMW-MM-dd";
            blocks[10] = ^(NSString *string) { return [formatter dateFromString:string]; };
        }
        
        {
            /*
             2014-01-20 12:24:48
             2014-01-20T12:24:48   // Google
             2014-01-20 12:24:48.000
             2014-01-20T12:24:48.000
             */
            NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
            formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter1.dateFormat = @"MWMW-MM-dd'T'HH:mm:ss";
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter2.dateFormat = @"MWMW-MM-dd HH:mm:ss";
            
            NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
            formatter3.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter3.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter3.dateFormat = @"MWMW-MM-dd'T'HH:mm:ss.SSS";
            
            NSDateFormatter *formatter4 = [[NSDateFormatter alloc] init];
            formatter4.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter4.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter4.dateFormat = @"MWMW-MM-dd HH:mm:ss.SSS";
            
            blocks[19] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter1 dateFromString:string];
                } else {
                    return [formatter2 dateFromString:string];
                }
            };
            
            blocks[23] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter3 dateFromString:string];
                } else {
                    return [formatter4 dateFromString:string];
                }
            };
        }
        
        {
            /*
             2014-01-20T12:24:48Z        // Github, Apple
             2014-01-20T12:24:48+0800    // Facebook
             2014-01-20T12:24:48+12:00   // Google
             2014-01-20T12:24:48.000Z
             2014-01-20T12:24:48.000+0800
             2014-01-20T12:24:48.000+12:00
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"MWMW-MM-dd'T'HH:mm:ssZ";
            
            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"MWMW-MM-dd'T'HH:mm:ss.SSSZ";
            
            blocks[20] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[24] = ^(NSString *string) { return [formatter dateFromString:string]?: [formatter2 dateFromString:string]; };
            blocks[25] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[28] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
            blocks[29] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }
        
        {
            /*
             Fri Sep 04 00:12:21 +0800 2015 // Weibo, Twitter
             Fri Sep 04 00:12:21.000 +0800 2015
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z MWMW";
            
            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"EEE MMM dd HH:mm:ss.SSS Z MWMW";
            
            blocks[30] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[34] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }
    });
    if (!string) return nil;
    if (string.length > kParserNum) return nil;
    MWNSDateParseBlock parser = blocks[string.length];
    if (!parser) return nil;
    return parser(string);
#undef kParserNum
}

@implementation NSObject (MWModel)

#pragma mark - Init
+ (NSArray *)mw_initWithArray:(NSArray *)array {
    if (!array || array == (id)kCFNull) return nil;
    if (![array isKindOfClass:[NSArray class]]) return nil;
    
    NSMutableArray *datas = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary *dict in array) {
        id obj = [[self alloc] mw_initWithDictionary:dict];
        if (obj) {
            [datas addObject:obj];
        }
    }
    
    return datas;
}

+ (instancetype)mw_initWithDictionary:(NSDictionary *)dictionary {
    return [[self alloc] mw_initWithDictionary:dictionary];
}

- (instancetype)mw_initWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self mw_setPropertyValue:obj forKey:key];
    }];
    
    return self;
}

#pragma mark - NSCoding
- (void)mw_deCoder:(NSCoder *)coder {
    MWClassInfo *info = [self mw_getClassInfo];
    [info.propertyDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MWPropertyInfo * _Nonnull obj, BOOL * _Nonnull stop) {
        id value = [coder decodeObjectForKey:key];
        if (value == nil) return;
        [self mw_setValue:obj forKey:key];
    }];
}

- (void)mw_encodeWithCoder:(NSCoder *)aCoder {
    MWClassInfo *info = [self mw_getClassInfo];
    [info.propertyDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MWPropertyInfo * _Nonnull obj, BOOL * _Nonnull stop) {
        id value = [self mw_valueWithProperty:obj];
        if (value == nil) return;
        [aCoder encodeObject:value forKey:key];
    }];
}

#pragma mark - NSCoping
- (instancetype)mw_copy {
    MWClassInfo *info = [self mw_getClassInfo];
    id obj = [[[self class] alloc] init];
    [info.propertyDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MWPropertyInfo * _Nonnull obj, BOOL * _Nonnull stop) {
        id value = [self mw_valueWithProperty:obj];
        if (value == nil) return;
        [obj mw_setValue:[value copy] forKey:key];
    }];
    return obj;
}

#pragma mark - Private Methods
- (void)mw_setPropertyValue:(id)value forKey:(NSString *)key {
    NSString *redirectKey = [self mw_redirectMapper][key];
    NSString *aKey = redirectKey ? redirectKey : key;
    id aValue = value;
    
    //判断当前key是否为需要自己处理的字段，如为NO则进入自动处理流程
    if (![self mw_customMappingPropertiesWithKey:aKey value:aValue]) {
        //判断是否有这个属性
        BOOL hasKey = NO;
        
        MWClassInfo *info = [self mw_getClassInfo];
        hasKey = [info.propertyDict.allKeys containsObject:aKey] ? YES : NO;
        
        if (!hasKey) {
            //不存在这个key，调用undefinedkey方法后直接返回
            [self setValue:aValue forUndefinedKey:aKey];
            return;
        }
        
        if (!aValue || aValue == [NSNull null]) {
            //value为空值，直接赋值nil
            [self mw_setValue:nil forKey:aKey];
            return;
        }
        
        MWPropertyInfo *propertyInfo = info.propertyDict[aKey];
        
        if (propertyInfo.isNumber) {
            NSNumber *num = mw_NSNumberCreateFromID(aValue);
            [self mw_setValue:num forKey:aKey];
        } else {
            if (propertyInfo.isFromFoundation) {
                //系统类型对象
                switch (propertyInfo.type) {
                    case MWPropertyTypeNSArray:
                    case MWPropertyTypeNSMutableArray: {
                        Class contentClass = [self mw_modelContainerPropertyGenericClass][propertyInfo.propertyName];
                        if (contentClass && [aValue isKindOfClass:[NSArray class]]) {
                            NSMutableArray *objectArr = [NSMutableArray new];
                            for (id aValueObj in aValue) {
                                if ([aValueObj isKindOfClass:[NSDictionary class]]) {
                                    [objectArr addObject:[[contentClass alloc] mw_initWithDictionary:aValueObj]];
                                }
                            }
                            aValue = objectArr;
                        }
                        break;
                    }
                    case MWPropertyTypeNSDictionary:
                    case MWPropertyTypeNSMutableDictionary: {
                        Class contentClass = [self mw_modelContainerPropertyGenericClass][propertyInfo.propertyName];
                        if (contentClass && [aValue isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *tmpDictValue = (NSDictionary *)aValue;
                            NSMutableDictionary *objectDict = [NSMutableDictionary new];
                            for (NSString *aValueKey in tmpDictValue.allKeys) {
                                id aValueObj = tmpDictValue[aValueKey];
                                if ([aValueObj isKindOfClass:[NSDictionary class]]) {
                                    [objectDict setObject:[[contentClass alloc] mw_initWithDictionary:aValueObj] forKey:aValueKey];
                                }
                            }
                            aValue = objectDict;
                        }
                        break;
                    }
                    case MWPropertyTypeNSDate: {
                        if ([aValue isKindOfClass:[NSString class]]) {
                            aValue = mw_NSDateFromString(aValue);
                        }
                        break;
                    }
                    default:
                        break;
                }
                [self mw_setValue:aValue forKey:aKey];
            } else {
                //自定义对象
                if ([aValue isKindOfClass:[NSDictionary class]]) {
                    aValue = [[propertyInfo.cls alloc] mw_initWithDictionary:aValue];
                }
            }
        }
        
        //赋值完成后回调
        [self mw_afterSetValueForKey:aKey];
    }
}

- (MWClassInfo *)mw_getClassInfo {
    MWClassInfo *classInfo = [MWClassCache classInfoForKey:NSStringFromClass([self class])];
    if (!classInfo) {
        [MWClassCache saveClassInfo:[[MWClassInfo alloc] initWithClass:[self class]] forKey:NSStringFromClass([self class])];
    }
    return classInfo;
}

#pragma mark - Set/Get value for key
- (void)mw_setValue:(id)value forKey:(NSString *)key {
    MWClassInfo *classInfo = [MWClassCache classInfoForKey:NSStringFromClass([self class])];
    MWPropertyInfo *propertyInfo = classInfo.propertyDict[key];
    if (!propertyInfo) return;
    
    [self mw_setValueWithProperty:propertyInfo value:value];
}

- (void)mw_setValueWithProperty:(MWPropertyInfo *)propertyInfo value:(id)value {
    if (propertyInfo.setter) {
        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)self, propertyInfo.setter, value);
    } else {
        [self setValue:value forKey:propertyInfo.propertyName];
    }
}

- (id)mw_valueforKey:(NSString *)key {
    MWClassInfo *classInfo = [MWClassCache classInfoForKey:NSStringFromClass([self class])];
    MWPropertyInfo *propertyInfo = classInfo.propertyDict[key];
    if (!propertyInfo) return nil;
    
    return [self mw_valueWithProperty:propertyInfo];
}

- (id)mw_valueWithProperty:(MWPropertyInfo *)propertyInfo {
    if (propertyInfo.getter) {
        if ([propertyInfo isNumber]) {
            id value;
            switch (propertyInfo.type) {
                case MWPropertyTypeBool: {
                    bool result = ((bool (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyInfo.getter);
                    value = [NSNumber numberWithBool:result];
                    break;
                }
                case MWPropertyTypeInt8:
                case MWPropertyTypeUInt8:
                case MWPropertyTypeInt16:
                case MWPropertyTypeUInt16:
                case MWPropertyTypeInt32:
                case MWPropertyTypeUInt32:
                case MWPropertyTypeInt64:
                case MWPropertyTypeUInt64: {
                    int result = ((int (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyInfo.getter);
                    value = [NSNumber numberWithInt:result];
                    break;
                }
                case MWPropertyTypeFloat: {
                    float result = ((float (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyInfo.getter);
                    value = [NSNumber numberWithFloat:result];
                    break;
                }
                case MWPropertyTypeDouble: {
                    double result = ((double (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyInfo.getter);
                    value = [NSNumber numberWithDouble:result];
                    break;
                }
                default:
                    break;
            }
            return value;
        }
        return ((id (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyInfo.getter);
    }
    return [self valueForKey:propertyInfo.propertyName];
}

#pragma mark - Undefined Key
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
//    NSLog(@"Class %@ ,UndefineKey %@", [self class],key);
}

#pragma mark - Custom
- (NSDictionary<NSString *, NSString *> *)mw_redirectMapper {
    return @{};
}

- (NSDictionary<NSString *, Class> *)mw_modelContainerPropertyGenericClass {
    return @{};
}

- (BOOL)mw_customMappingPropertiesWithKey:(NSString *)key value:(id)value {
    return NO;
}

- (void)mw_afterSetValueForKey:(NSString *)key {
    //子类根据需要自己实现
}

#pragma mark - Helper
/**
 自定义对象调用转换自身内容
 **/
- (NSDictionary *)mw_modelConvertDictionary {
    NSMutableDictionary *toDict = [NSMutableDictionary dictionary];
    MWClassInfo *classInfo = [self mw_getClassInfo];
    for (NSString *key in classInfo.propertyDict.allKeys) {
        MWPropertyInfo *propertyInfo = classInfo.propertyDict[key];
        if (propertyInfo.isNumber) {
            id num = [self mw_valueWithProperty:propertyInfo];
            if (!num) {
                num = [NSNull null];
            }
            [toDict setObject:num forKey:key];
        } else {
            if (propertyInfo.isFromFoundation) {
                id obj = [self mw_valueWithProperty:propertyInfo];
                switch (propertyInfo.type) {
                    case MWPropertyTypeNSArray:
                    case MWPropertyTypeNSMutableArray: {
                        Class contentClass = [self mw_modelContainerPropertyGenericClass][propertyInfo.propertyName];
                        if (contentClass) {
                            NSArray *tmpObjArray = (NSArray *)obj;
                            NSMutableArray *newObjArray = [NSMutableArray arrayWithCapacity:tmpObjArray.count];
                            for (id arrayValue in tmpObjArray) {
                                [newObjArray addObject:[arrayValue mw_modelConvertDictionary]];
                            }
                            obj = newObjArray;
                        }
                        break;
                    }
                    case MWPropertyTypeNSDictionary:
                    case MWPropertyTypeNSMutableDictionary: {
                        Class contentClass = [self mw_modelContainerPropertyGenericClass][propertyInfo.propertyName];
                        if (contentClass) {
                            NSDictionary *tmpObjDict = (NSDictionary *)obj;
                            NSMutableDictionary *newObjDict = [NSMutableDictionary dictionaryWithCapacity:tmpObjDict.count];
                            for (NSString *dictKey in tmpObjDict.allKeys) {
                                id dictValue = tmpObjDict[dictKey];
                                [newObjDict setObject:[dictValue mw_modelConvertDictionary] forKey:dictKey];
                            }
                            obj = newObjDict;
                        }
                        break;
                    }
                    case MWPropertyTypeNSDate: {
                        if ([obj isKindOfClass:[NSDate class]]) {
                            obj = [MWISODateFormatter() stringFromDate:obj];
                        }
                        break;
                    }
                    default:
                        break;
                }
                if (obj) {
                    if (!obj) {
                        obj = [NSNull null];
                    }
                    [toDict setObject:obj forKey:key];
                }
            } else {
                id obj = [self mw_valueWithProperty:propertyInfo];
                if (!obj) {
                    obj = [NSNull null];
                }
                [toDict setObject:[obj mw_modelConvertDictionary] forKey:key];
            }
        }
    }
    return toDict;
}

- (NSString *)mw_convertJsonString {
    NSData *jsonData;
    @try {
        NSError *parseError = nil;
        jsonData = [NSJSONSerialization dataWithJSONObject:[self mw_modelConvertDictionary] options:NSJSONWritingPrettyPrinted error:&parseError];
    } @catch (NSException *exception) {
        NSLog(@"covert json error:%@",exception.debugDescription);
    } @finally {
        if (jsonData) {
            return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        } else {
            return @"";
        }
    }
}

@end
