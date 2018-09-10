//
//  MWDefines.h
//  Pods
//
//  Created by 石茗伟 on 2018/9/4.
//

#ifndef MWDefines_h
#define MWDefines_h

/*
 全局配置
 */
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

/*
 Transition 相关配置
 */
//动画时间
#define kMWPushAnimationDuration 0.3f
#define kMWPopAnimationDuration 0.3f
#define kMWPresentAnimationDuration 0.3f
#define kMWDismissAnimationDuration 0.3f

// 当拖动的距离,占了屏幕的总宽高的3/4时, 就让imageview完全显示，遮盖完全消失
#define kMWNaviTargetTranslateScale 0.75

#endif /* MWDefines_h */
