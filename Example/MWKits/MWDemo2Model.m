//
//  MWDemo2Model.m
//  MWKits_Example
//
//  Created by 石茗伟 on 2018/9/12.
//  Copyright © 2018年 mingway1991. All rights reserved.
//

#import "MWDemo2Model.h"

@implementation MWDemo2Model

- (NSDictionary<NSString *,Class> *)mw_modelContainerPropertyGenericClass {
    return @{@"demos":[MWDemo3Model class]};
}

@end
