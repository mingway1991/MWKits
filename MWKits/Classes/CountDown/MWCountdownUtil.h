//
//  MWCountdownUtil.h
//  MWKits
//
//  Created by 石茗伟 on 2018/9/10.
//

/*
 GCD实现倒计时
 
 注 如果想要进入后台继续执行倒计时，需要执行以下操作：
 1.开启后台执行任务模式
 2.需要在applicationDidEnterBackground加入以下代码
 - (void)applicationDidEnterBackground:(UIApplication *)application {
    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid){
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid){
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
 }
 */

/* timer每个间隔更新block */
typedef void(^MWCountDownUpdateBlock)(NSTimeInterval timeInterval);
/* timer结束调用 */
typedef void(^MWCountDownEndBlock)(void);

#import <Foundation/Foundation.h>

@interface MWCountdownUtil : NSObject

/**
 间隔一秒倒计时
 
 @param seconds 总共需要倒计时的时间
 @param updateBlock 更次间隔更新调用
 @param endBlock 计时完成调用
 @return dispatch_source_t
 */

+ (dispatch_source_t)countDownOneSecondForSeconds:(NSTimeInterval)seconds
                         updateBlock:(MWCountDownUpdateBlock)updateBlock
                            endBlock:(MWCountDownEndBlock)endBlock;

/** 倒计时
 @param seconds 总共需要倒计时的时间
 @param timeInterval 倒计时的间隔
 @param updateBlock 更次间隔更新调用
 @param endBlock 计时完成调用
 @return dispatch_source_t
 */
+ (dispatch_source_t)countDownSeconds:(NSTimeInterval)seconds
            timeInterval:(NSTimeInterval)timeInterval
             updateBlock:(MWCountDownUpdateBlock)updateBlock
                endBlock:(MWCountDownEndBlock)endBlock;

/**
 结束timer
 dealloc中调用，销毁计时
 */
+ (void)cancalTimer:(dispatch_source_t)timer;

@end
