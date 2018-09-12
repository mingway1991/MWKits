//
//  MWDemoModel.h
//  MWKits_Example
//
//  Created by 石茗伟 on 2018/9/11.
//  Copyright © 2018年 mingway1991. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MWKits/NSObject+MWModel.h>
#import "MWDemo2Model.h"

@interface MWDemoModel : NSObject

@property (nonatomic, assign) NSInteger t_id;
@property (nonatomic, assign) BOOL test_bool;
@property (nonatomic, assign) int int_id;
@property (nonatomic, assign) long long_id;
@property (nonatomic, assign) long long longlong_id;
@property (nonatomic, assign) float money;
@property (nonatomic, assign) double double_money;
@property (nonatomic, strong) NSArray *names;
@property (nonatomic, strong) NSMutableArray *nameArray;
@property (nonatomic, strong) NSDictionary *nameDict;
@property (nonatomic, strong) NSMutableDictionary *nameMutableDict;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *test;
@property (nonatomic, strong) MWDemo2Model *demo2;
@property (nonatomic, strong) NSArray<MWDemo2Model *> *demos;
@property (nonatomic, strong) NSDate *date;

@end
