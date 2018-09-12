//
//  NSDictionary+MWModel.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/12.
//

#import "NSDictionary+MWModel.h"
#import "NSObject+MWModel.h"
#import "NSArray+MWModel.h"

@implementation NSDictionary (MWModel)

/**
 字典对象调用转换自身内容
 **/
- (NSDictionary *)mw_dictionaryConvertDictionary {
    NSDictionary *tDictionary = (NSDictionary *)self;
    NSMutableDictionary *resultDictionary = [NSMutableDictionary dictionaryWithCapacity:tDictionary.count];
    for (NSString *key in tDictionary.allKeys) {
        NSObject *obj = tDictionary[key];
        NSBundle *aBundle = [NSBundle bundleForClass:[obj class]];
        if (aBundle == [NSBundle mainBundle]) {
            //自定义类
            [resultDictionary setObject:[obj mw_customModelConvertDictionary] forKey:key];
        } else if ([[obj class] isSubclassOfClass:[NSArray class]]) {
            //array
            [resultDictionary setObject:[(NSArray *)obj mw_arrayConvertArray] forKey:key];
        } else if ([[obj class] isSubclassOfClass:[NSDictionary class]]) {
            //dictionary
            [resultDictionary setObject:[(NSDictionary *)obj mw_dictionaryConvertDictionary] forKey:key];
        } else {
            //其他类型
            [resultDictionary setObject:obj forKey:key];
        }
    }
    return resultDictionary;
}

@end
