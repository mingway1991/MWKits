//
//  MWCountdownUtil.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/10.
//

#import "MWCountdownUtil.h"

@interface MWCountdownUtil ()

@end

@implementation MWCountdownUtil

+ (dispatch_source_t)countDownOneSecondForSeconds:(NSTimeInterval)seconds
                         updateBlock:(MWCountDownUpdateBlock)updateBlock
                            endBlock:(MWCountDownEndBlock)endBlock {
    return [self countDownSeconds:seconds timeInterval:1.f updateBlock:^(NSTimeInterval timeInterval) {
        updateBlock(timeInterval);
    } endBlock:^{
        endBlock();
    }];
}

+ (dispatch_source_t)countDownSeconds:(NSTimeInterval)seconds
            timeInterval:(NSTimeInterval)timeInterval
             updateBlock:(MWCountDownUpdateBlock)updateBlock
                endBlock:(MWCountDownEndBlock)endBlock {
    __block NSTimeInterval timeOutCount = seconds;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __block dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    uint64_t interval = (uint64_t)(timeInterval * NSEC_PER_SEC);
    //leeway精准参数，0为越精确越好
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, 0);
    dispatch_source_set_event_handler(timer, ^{
        timeOutCount -= timeInterval;
        if (timeOutCount <= 0) {
            //倒计时结束，结束timer，调用结束block
            [self cancalTimer:timer];
            dispatch_async(dispatch_get_main_queue(), ^{
                endBlock();
            });
        } else {
            //倒计时中，调用更新block
            dispatch_async(dispatch_get_main_queue(), ^{
                updateBlock(timeOutCount);
            });
        }
    });
    dispatch_resume(timer);
    return timer;
}

+ (void)cancalTimer:(dispatch_source_t)timer {
    if (timer) {
        dispatch_cancel(timer);
        timer = nil;
    }
}

@end
