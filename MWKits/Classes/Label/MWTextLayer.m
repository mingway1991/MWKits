//
//  MWTextLayer.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/19.
//

#import "MWTextLayer.h"

@implementation MWTextLayer

- (void)display {
    super.contents = super.contents;
    [self _display];
}

- (void)_display {
    __strong id<MWTextLayerDelegate> delegate = (id)self.delegate;
    MWTextLayerDisplayTask *task = [delegate newDisplayTask];
    if (!task.display) {
        if (task.willDisplay) task.willDisplay(self);
        self.contents = nil;
        if (task.didDisplay) task.didDisplay(self, YES);
        return;
    }
    
    if (task.willDisplay) task.willDisplay(self);
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, self.contentsScale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.opaque && context) {
        CGSize size = self.bounds.size;
        size.width *= self.contentsScale;
        size.height *= self.contentsScale;
        CGContextSaveGState(context); {
            if (!self.backgroundColor || CGColorGetAlpha(self.backgroundColor) < 1) {
                CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
                CGContextFillPath(context);
            }
            if (self.backgroundColor) {
                CGContextSetFillColorWithColor(context, self.backgroundColor);
                CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
                CGContextFillPath(context);
            }
        } CGContextRestoreGState(context);
    }
    task.display(context, self.bounds.size, ^{return NO;});
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.contents = (__bridge id)(image.CGImage);
    if (task.didDisplay) task.didDisplay(self, YES);
}

@end

@implementation MWTextLayerDisplayTask
@end
