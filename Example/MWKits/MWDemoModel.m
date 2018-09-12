//
//  MWDemoModel.m
//  MWKits_Example
//
//  Created by 石茗伟 on 2018/9/11.
//  Copyright © 2018年 mingway1991. All rights reserved.
//

#import "MWDemoModel.h"

@implementation MWDemoModel

- (NSString *)mw_redirectForKey:(NSString *)key {
    if ([key isEqualToString:@"model"]) {
        return @"demo2";
    }
    return [super mw_redirectForKey:key];
}

- (BOOL)mw_customMappingPropertiesWithKey:(NSString *)key value:(id)value {
    if ([key isEqualToString:@"demos"]) {
        self.demos = [MWDemo2Model mw_initWithArray:value];
        return YES;
    }
    return [super mw_customMappingPropertiesWithKey:key value:value];
}

@end
