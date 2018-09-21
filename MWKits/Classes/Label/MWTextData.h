//
//  MWTextData.h
//  MWKits
//
//  Created by 石茗伟 on 2018/9/19.
//

#import <Foundation/Foundation.h>
#import "MWTextLayout.h"

@interface MWTextData : NSObject

@property (nonatomic, strong) NSAttributedString *text;
@property (nonatomic, assign) NSUInteger numberOfLines;
@property (nonatomic) CGSize size;
@property (nonatomic) UIEdgeInsets insets;

@property (nonatomic, readonly) CGSize textBoundingSize;

@end
