//
//  NSObject+MWModel.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/10.
//

#import "NSObject+MWModel.h"
#import <objc/runtime.h>

@implementation NSObject (MWModel)

#pragma mark - Init
+ (NSArray *)mw_initWithArray:(NSArray *)array {
    if (!array || array == (id)kCFNull) return nil;
    if (![array isKindOfClass:[NSArray class]]) return nil;
    
    NSMutableArray *datas = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary *dict in array) {
        id obj = [[self alloc] mw_initWithDictionary:dict];
        [datas addObject:obj];
    }
    
    return datas;
}

- (instancetype)mw_initWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self mw_setValue:obj forKey:key];
    }];
    
    return self;
}

#pragma mark - Private Methods
- (void)mw_setValue:(id)value forKey:(NSString *)key {
    __block NSString *aKey = key;
    id aValue = value;
    
    //查找映射数组，是否存在需要替换的key
    NSArray *propertyNames = [self mw_customMappingPropertyArray];
    if (propertyNames && [propertyNames count] > 0) {
        [propertyNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *tmpPropertyArray = obj;
            if (tmpPropertyArray && [tmpPropertyArray isKindOfClass:[NSArray class]] && [tmpPropertyArray count] >= 2) {
                if (tmpPropertyArray[0] == key) {
                    aKey = tmpPropertyArray[1];
                    *stop = YES;
                }
            }
        }];
    }
    
    if (![self mw_customMappingPropertiesWithKey:aKey value:aValue]) {
        //判断当前key为不需要自己处理的字段
        
        if (value == [NSNull null]) {
            //如果value为null，直接给字段赋值为nil
            [self setValue:nil forKey:aKey];
            return;
        }
        
        BOOL hasKey = NO;
        
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList([self class], &count);
        for(int i = 0; i < count; i++) {
            objc_property_t property = properties[i];
            NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
            if ([propertyName isEqualToString:aKey]) {
                //判断是否有这个属性
                hasKey = YES;
                if (![self mw_isSystemClass:aKey]) {
                    //自定义类，需初始化
                    Class aClass = [self mw_getAttributeClass:aKey];
                    aValue = [[aClass alloc] mw_initWithDictionary:aValue];
                } else {
                    //系统类，一些需要特殊处理的类型
                    Class aClass = [self mw_getAttributeClass:aKey];
                    if ([aClass isSubclassOfClass:[NSDate class]]) {
                        //日期类型，内容为NSString，转换为NSDate
                        if ([aValue isKindOfClass:[NSString class]]) {
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:[self mw_dateFormat]];
                            aValue = [dateFormatter dateFromString:aValue];
                        }
                    }
                }
                break;
            }
        }
        free(properties);
        
        if (hasKey) {
            if (aValue) {
                [self setValue:aValue forKey:aKey];
            } else {
                NSLog(@"赋值失败 --> key:%@ value:%@",aKey,value);
            }
        } else {
            [self setValue:aValue forUndefinedKey:aKey];
        }
    }
}

/** 判断key是否是系统的类 **/
- (BOOL)mw_isSystemClass:(NSString *)key {
    Class aClass = [self mw_getAttributeClass:key];
    
    if (aClass) {
        // 判断key的类型是否是系统类
        NSBundle *aBundle = [NSBundle bundleForClass:aClass];
        if (aBundle == [NSBundle mainBundle]) {
            // 自定义的类
            return NO;
        } else {
            // 系统类
            return YES;
        }
    } else {
        // 基本类型
        return YES;
    }
}

/** 获取属性的类 **/
- (Class)mw_getAttributeClass:(NSString *)key {
    Class aClass;
    unsigned int count;
    NSRange objRange;
    NSRange dotRange;
    NSString *aClassStr;
    NSMutableString *aAttribute;
    const char *att = "";
    
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (int i = 0 ; i < count; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        NSString *tStr = [NSString stringWithUTF8String:propertyName];
        if([key isEqualToString:tStr]){
            att = property_getAttributes(propertyList[i]);
            break;
        }
    }
    free(propertyList);
    
    aAttribute  = [[NSMutableString alloc] initWithUTF8String:att];
    objRange = [aAttribute rangeOfString:@"@"];
    if (objRange.location != NSNotFound) {
        // key是对象，不是基本类型
        dotRange = [aAttribute rangeOfString:@","];
        aClassStr = [aAttribute substringWithRange:NSMakeRange(3, dotRange.location-1-3)];
        aClass = NSClassFromString(aClassStr);
    } else {
        return nil;
    }
    
    return aClass;
}

#pragma mark - Undefined Key
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"Class %@ ,UndefineKey %@", [self class],key);
}

#pragma mark - Custom
- (NSArray *)mw_customMappingPropertyArray {
    return @[];
}

- (BOOL)mw_customMappingPropertiesWithKey:(NSString *)key value:(id)value {
    return NO;
}

- (NSString *)mw_dateFormat {
    return @"yyyy-MM-dd HH:mm:ss";
}

#pragma mark - Helper
- (NSString *)mw_convertJsonString {
    return @"";
}

@end
