//
//  UIViewController+MWTransition.m
//  MWAnimationKit
//
//  Created by 石茗伟 on 2018/9/4.
//

#import "UIViewController+MWTransition.h"
#import "MWPresentAnimation.h"
#import <objc/runtime.h>

static NSString *presentAnimationKey = @"presentAnimation";
static NSString *dismissAnimationKey = @"dismissAnimation";
static NSString *pushAnimationKey = @"pushAnimation";
static NSString *popAnimationKey = @"popAnimation";
static NSString *canDragBackKey = @"canDragBack";

@implementation UIViewController (MWTransition)

- (void)mwSetupPresentAndDismiss {
    self.presentAnimation = [[MWPresentAnimation alloc] init];
    self.dismissAnimation = [[MWDismissAnimation alloc] init];
    self.transitioningDelegate = self;
    self.modalPresentationStyle = UIModalPresentationCustom;
}

- (void)mwSetupPushAndPop {
    self.pushAnimation = [[MWPushAnimation alloc] init];
    self.popAnimation = [[MWPopAnimation alloc] init];
    self.navigationController.delegate = self;
}

#pragma mark - UIViewControllerTransitioningDelegate(控制present、dismiss)
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.presentAnimation;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.dismissAnimation;
}

#pragma mark - UINavigationControllerDelegate(控制push、pop)
- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush) {
        return self.pushAnimation;
    } else if (operation == UINavigationControllerOperationPop) {
        return self.popAnimation;
    }
    return nil;
}

#pragma mark - Setter / Getter
- (void)setPresentAnimation:(MWPresentAnimation *)presentAnimation {
    objc_setAssociatedObject(self, &presentAnimationKey, presentAnimation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MWPresentAnimation *)presentAnimation {
    return objc_getAssociatedObject(self, &presentAnimationKey);
}

- (void)setDismissAnimation:(MWDismissAnimation *)dismissAnimation {
    objc_setAssociatedObject(self, &dismissAnimationKey, dismissAnimation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MWDismissAnimation *)dismissAnimation {
    return objc_getAssociatedObject(self, &dismissAnimationKey);
}

- (void)setPushAnimation:(MWPushAnimation *)pushAnimation {
    objc_setAssociatedObject(self, &pushAnimationKey, pushAnimation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MWPushAnimation *)pushAnimation {
    return objc_getAssociatedObject(self, &pushAnimationKey);
}

- (void)setPopAnimation:(MWPopAnimation *)popAnimation {
    objc_setAssociatedObject(self, &popAnimationKey, popAnimation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MWPopAnimation *)popAnimation {
    return objc_getAssociatedObject(self, &popAnimationKey);
}

- (void)setCanDragBack:(BOOL)canDragBack {
    objc_setAssociatedObject(self, &canDragBackKey, @(canDragBack), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)canDragBack {
    id object = objc_getAssociatedObject(self, &canDragBackKey);
    if (!object) {
        //默认值为YES
        return YES;
    }
    return [object boolValue];
}

@end
