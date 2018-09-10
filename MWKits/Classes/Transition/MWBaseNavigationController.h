//
//  MWBaseNavigationController.h
//  MWAnimationKit
//
//  Created by 石茗伟 on 2018/9/4.
//

/*
 
 需要使用push和pop动画，并且可以拖动返回的，继承这个controller
 
 某个viewcontroller需要关闭滑动返回，设置如下
 [(MWBaseNavigationController *)self.navigationController setCanDragBack:NO];
 
 */

#import <UIKit/UIKit.h>

@interface MWBaseNavigationController : UINavigationController

/* 是否可以滑动返回 */
@property (nonatomic, assign) BOOL canDragBack;

@end
