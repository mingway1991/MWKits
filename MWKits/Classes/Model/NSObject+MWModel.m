//
//  NSObject+MWModel.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/10.
//

#import "NSObject+MWModel.h"
#import "NSArray+MWModel.h"
#import "NSDictionary+MWModel.h"
#import "MWHelper.h"
#import <objc/runtime.h>

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
        [self mw_setValue:obj forKey:key];
    }];
    
    return self;
}

#pragma mark - NSCoding
//- (instancetype)mw_initWithCoder:(NSCoder *)coder {
//
//}

//- (void)mw_modelEncodeWithCoder:(NSCoder *)aCoder {
//
//}

#pragma mark - NSCoping
//- (instancetype)mw_copyWithZone(NSZone *)zone {
//    if (self == (id)kCFNull) return self;
//
//}

#pragma mark - Private Methods
- (void)mw_setValue:(id)value forKey:(NSString *)key {
    NSString *redirectKey = [self mw_redirectMapper][key];
    NSString *aKey = redirectKey ? redirectKey : key;
    id aValue = value;
    
    //判断当前key是否为需要自己处理的字段，如为NO则进入自动处理流程
    if (![self mw_customMappingPropertiesWithKey:aKey value:aValue]) {
        //判断是否有这个属性
        __block BOOL hasKey = NO;
        [self mw_enumerateProppertiesWithBlock:^(const char *name, const char *att, BOOL *stop) {
            NSString *propertyName = [NSString stringWithUTF8String:name];
            if ([propertyName isEqualToString:aKey]) {
                hasKey = YES;
                *stop = YES;
            }
        }];
        
        if (!hasKey) {
            //不存在这个key，调用undefinedkey方法后直接返回
            [self setValue:aValue forUndefinedKey:aKey];
            return;
        }
        
        if (!aValue || aValue == [NSNull null]) {
            //value为空值，直接赋值nil
            [self setValue:nil forUndefinedKey:aKey];
            return;
        }
        
        Class aKeyClass = [self mw_getAttributeClass:aKey];
        //如果key存在，则对value进行处理，之后赋值
        if (![self mw_isSystemClass:aKey]) {
            //自定义类
            if ([aValue isKindOfClass:[NSDictionary class]]) {
                //NSDitionary，初始化对应的类对象进行赋值
                aValue = [[aKeyClass alloc] mw_initWithDictionary:aValue];
            } else {
                //其他类型的对象，不具备初始化赋值的条件，将内容置为nil，打印log
                aValue = nil;
                NSLog(@"Class %@ ,Key %@ : 内容为非NSDictionary，不能初始化", [self class], aKey);
            }
        } else {
            //系统类，一些需要特殊处理的类型
            if (aKeyClass) {
                //系统对象类型
                Class aValueClass = [self mw_modelContainerPropertyGenericClass][aKey];
                if ([aKeyClass isSubclassOfClass:[NSDate class]] && [aValue isKindOfClass:[NSString class]]) {
                    //NSDate，内容为NSString，自动转换
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:[self mw_dateFormat]];
                    aValue = [dateFormatter dateFromString:aValue];
                } else if (aValueClass && [aKeyClass isSubclassOfClass:[NSArray class]] && [aValue isKindOfClass:[NSArray class]]) {
                    //NSArray
                    aValue = [aValueClass mw_initWithArray:aValue];
                } else if (aValueClass && [aKeyClass isSubclassOfClass:[NSDictionary class]] && [aValue isKindOfClass:[NSDictionary class]]) {
                    //NSDictionary
                    NSDictionary *dictValue = (NSDictionary *)aValue;
                    NSMutableDictionary *newDictValue = [NSMutableDictionary dictionaryWithCapacity:dictValue.count];
                    [dictValue enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                        if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                            [newDictValue setObject:[[aValueClass alloc] mw_initWithDictionary:obj] forKey:key];
                        }
                    }];
                    aValue = newDictValue;
                }
            }
        }
        
        //数组和字典的可变处理
        if ([aKeyClass isSubclassOfClass:[NSMutableArray class]]) {
            aValue = [NSMutableArray arrayWithArray:aValue];
        } else if ([aKeyClass isSubclassOfClass:[NSMutableDictionary class]]) {
            aValue = [NSMutableDictionary dictionaryWithDictionary:aValue];
        }
        
        //赋值
        [self setValue:aValue forKey:aKey];
        [self mw_afterSetValueForKey:aKey];
    }
}

/** 判断key是否是系统的类 **/
- (BOOL)mw_isSystemClass:(NSString *)key {
    Class aClass = [self mw_getAttributeClass:key];
    if (aClass) {
        if ([MWHelper checkClassIsSystemClass:aClass]) {
            // 系统类
            return YES;
        } else {
            // 自定义的类
            return NO;
        }
    } else {
        // 基本类型
        return YES;
    }
}

- (void)mw_enumerateProppertiesWithBlock:(void(^)(const char *name, const char *att, BOOL *stop))block {
    BOOL stop = NO;
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for(int i = 0; i < count; i++) {
        if (stop) {
            break;
        }
        objc_property_t property = properties[i];
        block(property_getName(property), property_getAttributes(property), &stop);
    }
    free(properties);
}

/** 获取属性的类 **/
- (Class)mw_getAttributeClass:(NSString *)key {
    __block Class aClass;
    [self mw_enumerateProppertiesWithBlock:^(const char *name, const char *att, BOOL *stop) {
        if ([key isEqualToString:[NSString stringWithUTF8String:name]]) {
            NSRange objRange;
            NSRange dotRange;
            NSString *aClassStr;
            NSMutableString *aAttribute;
            
            aAttribute  = [[NSMutableString alloc] initWithUTF8String:att];
            objRange = [aAttribute rangeOfString:@"@"];
            if (objRange.location != NSNotFound) {
                // key是对象，不是基本类型
                dotRange = [aAttribute rangeOfString:@","];
                aClassStr = [aAttribute substringWithRange:NSMakeRange(3, dotRange.location-1-3)];
                aClass = NSClassFromString(aClassStr);
            }
            *stop = YES;
        }
    }];
    return aClass;
}

#pragma mark - Undefined Key
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"Class %@ ,UndefineKey %@", [self class],key);
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

- (NSString *)mw_dateFormat {
    return @"yyyy-MM-dd HH:mm:ss";
}

#pragma mark - Helper
/**
 自定义对象调用转换自身内容
 **/
- (NSDictionary *)mw_modelConvertDictionary {
    u_int count = 0;
    objc_property_t* properties = class_copyPropertyList([self class], &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray* typeArray = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i=0; i<count; i++) {
        objc_property_t property = properties[i];
        const char* propertyName = property_getName(property);
        NSString* propertyNameString = [NSString stringWithUTF8String:propertyName];
        [propertyArray addObject:propertyNameString];
        NSString* typecode = [NSString stringWithUTF8String:property_getAttributes(property)];
        NSArray* attributesArray = [typecode componentsSeparatedByString:@","];
        if(attributesArray.count == 4) {
            NSString* type = [attributesArray[0] substringWithRange:NSMakeRange(3, [(NSString*)attributesArray[0] length]-4)];
            [typeArray addObject:type];
        } else {
            NSString* type = [attributesArray[0] substringWithRange:NSMakeRange(1, 1)];
            [typeArray addObject:type];
        }
    }
    
    count = (u_int)propertyArray.count;
    NSMutableArray* valueArray = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i=0; i<count; i++) {
        if ([[typeArray objectAtIndex:i] isEqualToString:@"c"]) {
            NSNumber* number = [self valueForKey:propertyArray[i]];
            [valueArray addObject:number];
        } else {
            NSString *propertyName = propertyArray[i];
            NSObject* obj = [self valueForKey:propertyName];
            if (obj == nil) {
                [valueArray addObject:[NSNull null]];
            } else if ([self mw_isSystemClass:propertyName]) {
                Class cls = [self mw_getAttributeClass:propertyName];
                if ([cls isSubclassOfClass:[NSArray class]]) {
                    //array
                    [valueArray addObject:[(NSArray *)obj mw_arrayConvertArray]];
                } else if ([cls isSubclassOfClass:[NSDictionary class]]) {
                    //dictionary
                    [valueArray addObject:[(NSDictionary *)obj mw_dictionaryConvertDictionary]];
                } else {
                    //其他类型
                    [valueArray addObject:obj];
                }
            } else {
                //自定义类
                [valueArray addObject:[obj mw_modelConvertDictionary]];
            }
        }
    }
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjects:valueArray forKeys:propertyArray];
    return dict;
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
