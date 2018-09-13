//
//  NSDictionary+MWModel.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/12.
//

#import "NSDictionary+MWModel.h"
#import "NSObject+MWModel.h"
#import "NSArray+MWModel.h"
#import "MWHelper.h"

@implementation NSDictionary (MWModel)

- (NSDictionary *)mw_dictionaryConvertDictionary {
    NSDictionary *tDictionary = (NSDictionary *)self;
    NSMutableDictionary *resultDictionary = [NSMutableDictionary dictionaryWithCapacity:tDictionary.count];
    for (NSString *key in tDictionary.allKeys) {
        NSObject *obj = tDictionary[key];
        if (![MWHelper checkClassIsSystemClass:[obj class]]) {
            //自定义类
            [resultDictionary setObject:[obj mw_modelConvertDictionary] forKey:key];
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

- (NSString *)mw_convertJsonString {
    NSData *jsonData;
    @try {
        NSError *parseError = nil;
        jsonData = [NSJSONSerialization dataWithJSONObject:[self mw_dictionaryConvertDictionary] options:NSJSONWritingPrettyPrinted error:&parseError];
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
