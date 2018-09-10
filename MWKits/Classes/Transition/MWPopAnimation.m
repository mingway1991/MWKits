//
//  MWPopAnimation.m
//  MWAnimationKit
//
//  Created by 石茗伟 on 2018/9/4.
//

#import "MWPopAnimation.h"
#import "MWDefines.h"

@interface MWPopAnimation ()

@end

@implementation MWPopAnimation

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return kMWPopAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    [[transitionContext containerView] addSubview:toVC.view];
    [[transitionContext containerView] addSubview:fromVC.view];
    CGRect toFinalRect = [transitionContext finalFrameForViewController:toVC];
    toVC.view.frame = CGRectMake(-MWScreenWidth*(1-kMWNaviTargetTranslateScale), 0, MWScreenWidth, MWScreenHeight);
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromVC.view.frame = CGRectMake(MWScreenWidth, 0, MWScreenWidth, MWScreenHeight);
        toVC.view.frame = toFinalRect;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

@end
