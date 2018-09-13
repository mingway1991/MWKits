//
//  MWDemo2Model.h
//  MWKits_Example
//
//  Created by 石茗伟 on 2018/9/12.
//  Copyright © 2018年 mingway1991. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MWKits/NSObject+MWModel.h>
#import "MWDemo3Model.h"

@interface MWDemo2Model : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) int n_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray<MWDemo3Model *> *demos;

@end
