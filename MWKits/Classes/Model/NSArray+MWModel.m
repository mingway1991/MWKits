//
//  NSArray+MWModel.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/12.
//

#import "NSArray+MWModel.h"
#import "NSObject+MWModel.h"
#import "NSDictionary+MWModel.h"
#import "MWHelper.h"

@implementation NSArray (MWModel)

- (NSArray *)mw_arrayConvertArray {
    NSArray *tArray = (NSArray *)self;
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:tArray.count];
    for (NSObject *obj in tArray) {
        if (![MWHelper checkClassIsSystemClass:[obj class]]) {
            //自定义类
            [resultArray addObject:[obj mw_customModelConvertDictionary]];
        } else if ([[obj class] isSubclassOfClass:[NSArray class]]) {
            //array
            [resultArray addObject:[(NSArray *)obj mw_arrayConvertArray]];
        } else if ([[obj class] isSubclassOfClass:[NSDictionary class]]) {
            //dictionary
            [resultArray addObject:[(NSDictionary *)obj mw_dictionaryConvertDictionary]];
        } else {
            //其他类型
            [resultArray addObject:obj];
        }
    }
    return resultArray;
}

- (NSString *)mw_convertJsonString {
    NSData *jsonData;
    @try {
        NSError *parseError = nil;
        jsonData = [NSJSONSerialization dataWithJSONObject:[self mw_arrayConvertArray] options:NSJSONWritingPrettyPrinted error:&parseError];
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
