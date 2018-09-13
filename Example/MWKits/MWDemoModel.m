//
//  MWDemoModel.m
//  MWKits_Example
//
//  Created by 石茗伟 on 2018/9/11.
//  Copyright © 2018年 mingway1991. All rights reserved.
//

#import "MWDemoModel.h"

@implementation MWDemoModel

MWCodingImplementation
MWCopingImplementation

- (NSDictionary *)mw_redirectMapper {
    return @{@"model":@"demo2"};
}

- (NSDictionary<NSString *,Class> *)mw_modelContainerPropertyGenericClass {
    return @{@"demos":[MWDemo2Model class],
             @"dict":[MWDemo2Model class]
             };
}

@end
