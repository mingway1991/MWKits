//
//  MWTextLayer.h
//  MWKits
//
//  Created by 石茗伟 on 2018/9/19.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class MWTextLayerDisplayTask;

NS_ASSUME_NONNULL_BEGIN

@protocol MWTextLayerDelegate <NSObject>
@required
- (MWTextLayerDisplayTask *)newDisplayTask;

@end

@interface MWTextLayer : CALayer

@end

@interface MWTextLayerDisplayTask : NSObject

@property (nullable, nonatomic, copy) void (^willDisplay)(CALayer *layer);
@property (nullable, nonatomic, copy) void (^display)(CGContextRef context, CGSize size, BOOL(^isCancelled)(void));
@property (nullable, nonatomic, copy) void (^didDisplay)(CALayer *layer, BOOL finished);

@end

NS_ASSUME_NONNULL_END
