//
//  NSArray+MWModel.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/12.
//

#import "NSArray+MWModel.h"
#import "NSObject+MWModel.h"
#import "NSDictionary+MWModel.h"

@implementation NSArray (MWModel)

/**
 数组对象调用转换自身内容
 **/
- (NSArray *)mw_arrayConvertArray {
    NSArray *tArray = (NSArray *)self;
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:tArray.count];
    for (NSObject *obj in tArray) {
        NSBundle *aBundle = [NSBundle bundleForClass:[obj class]];
        if (aBundle == [NSBundle mainBundle]) {
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

@end
