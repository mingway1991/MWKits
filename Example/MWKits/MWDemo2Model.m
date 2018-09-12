//
//  MWDemo2Model.m
//  MWKits_Example
//
//  Created by 石茗伟 on 2018/9/12.
//  Copyright © 2018年 mingway1991. All rights reserved.
//

#import "MWDemo2Model.h"

@implementation MWDemo2Model

- (BOOL)mw_customMappingPropertiesWithKey:(NSString *)key value:(id)value {
    if ([key isEqualToString:@"demos"]) {
        self.demos = [MWDemo3Model mw_initWithArray:value];
        return YES;
    }
    return [super mw_customMappingPropertiesWithKey:key value:value];
}

@end
