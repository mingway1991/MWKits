//
//  NSObject+MWModel.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/10.
//

#import "NSObject+MWModel.h"

@implementation NSObject (MWModel)

- (instancetype)mwModelWithData:(NSData *)data {
    if (!data || data == (id)kCFNull) return nil;
    
    return [self mwModelWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL]];
}

- (instancetype)mwModelWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    
    return nil;
}

@end
