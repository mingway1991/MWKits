//
//  MWPushAnimation.m
//  MWAnimationKit
//
//  Created by 石茗伟 on 2018/9/4.
//

#import "MWPushAnimation.h"
#import "MWTransitionDefines.h"
#import "MWDefines.h"

@interface MWPushAnimation ()

@end

@implementation MWPushAnimation

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return kMWPushAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGRect finalRect = [transitionContext finalFrameForViewController:toVC];
    toVC.view.frame = CGRectOffset(finalRect, [[UIScreen mainScreen] bounds].size.width, 0);
    [[transitionContext containerView] addSubview:toVC.view];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromVC.view.frame = CGRectOffset(finalRect, -[[UIScreen mainScreen] bounds].size.width*(1-kMWNaviTargetTranslateScale), 0);
        toVC.view.frame = finalRect;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

@end
