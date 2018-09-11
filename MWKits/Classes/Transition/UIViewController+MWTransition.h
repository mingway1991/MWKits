//
//  UIViewController+MWTransition.h
//  MWAnimationKit
//
//  Created by 石茗伟 on 2018/9/4.
//

#import <UIKit/UIKit.h>
#import "MWPresentAnimation.h"
#import "MWDismissAnimation.h"
#import "MWPushAnimation.h"
#import "MWPopAnimation.h"

@interface UIViewController (MWTransition) <UIViewControllerTransitioningDelegate,
                                            UINavigationControllerDelegate>

@property (nonatomic, strong) MWPresentAnimation *presentAnimation;
@property (nonatomic, strong) MWDismissAnimation *dismissAnimation;
@property (nonatomic, strong) MWPushAnimation *pushAnimation;
@property (nonatomic, strong) MWPopAnimation *popAnimation;
/** 设置是否开启拖动返回，默认为YES **/
@property (nonatomic, assign) BOOL canDragBack;

/* 初始化模态动画相关，放在viewDidLoad调用 */
- (void)mw_setupPresentAndDismiss;
/* 初始化模态动画相关，放在viewWillAppear调用 */
- (void)mw_setupPushAndPop;

@end
