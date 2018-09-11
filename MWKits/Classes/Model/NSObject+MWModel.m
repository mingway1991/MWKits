//
//  NSObject+MWModel.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/10.
//

#import "NSObject+MWModel.h"

@implementation NSObject (MWModel)

- (instancetype)mw_modelWithData:(NSData *)data {
    if (!data || data == (id)kCFNull) return nil;
    
    return [self mw_modelWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL]];
}

- (instancetype)mw_modelWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    
    return nil;
}

@end
