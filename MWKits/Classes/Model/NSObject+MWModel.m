//
//  NSObject+MWModel.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/10.
//

#import "NSObject+MWModel.h"
#import <objc/runtime.h>
#import "NSArray+MWModel.h"
#import "NSDictionary+MWModel.h"

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
    NSString *aKey = [self mw_redirectForKey:key];
    id aValue = value;
    
    //判断当前key是否为需要自己处理的字段，如为false则进入自动处理流程
    if (![self mw_customMappingPropertiesWithKey:aKey value:aValue]) {
        //判断是否有这个属性
        BOOL hasKey = NO;
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList([self class], &count);
        for(int i = 0; i < count; i++) {
            objc_property_t property = properties[i];
            NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
            if ([propertyName isEqualToString:aKey]) {
                hasKey = YES;
                break;
            }
        }
        free(properties);
        
        //如果key存在，则对value进行处理，之后赋值
        if (hasKey) {
            //处理value
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
            
            if (aValue == [NSNull null]) {
                //如果value为null，直接给字段赋值为nil
                [self setValue:nil forKey:aKey];
            } else if (aValue) {
                [self setValue:aValue forKey:aKey];
                [self mw_afterSetValueForKey:aKey];
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

- (void)mw_afterSetValueForKey:(NSString *)key {
    //子类根据需要自己实现
}

#pragma mark - Undefined Key
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"Class %@ ,UndefineKey %@", [self class],key);
}

#pragma mark - Custom
- (NSString *)mw_redirectForKey:(NSString *)key {
    return key;
}

- (BOOL)mw_customMappingPropertiesWithKey:(NSString *)key value:(id)value {
    return NO;
}

- (NSString *)mw_dateFormat {
    return @"yyyy-MM-dd HH:mm:ss";
}

#pragma mark - Helper
/**
 自定义对象调用转换自身内容
 **/
- (NSDictionary *)mw_customModelConvertDictionary {
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
                [valueArray addObject:[obj mw_customModelConvertDictionary]];
            }
        }
    }
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjects:valueArray forKeys:propertyArray];
    return dict;
}

- (NSString *)mw_convertJsonString {
//TODO:待实现
    return @"";
}

@end
