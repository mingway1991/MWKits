//
//  MWHelper.h
//  MWKits
//
//  Created by 石茗伟 on 2018/9/13.
//

#import <Foundation/Foundation.h>

@interface MWHelper : NSObject

/**
 判断一个类是否是系统类型
 @param cls 待判定类
 @return True代表是系统类型（记本数据类型或者是NSArray、NSDictionary等）
         False代表是自定义类型
 */
+ (BOOL)checkClassIsSystemClass:(Class)cls;

@end
