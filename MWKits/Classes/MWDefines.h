//
//  MWDefines.h
//  Pods
//
//  Created by 石茗伟 on 2018/9/4.
//

#ifndef MWDefines_h
#define MWDefines_h

//NSLog
#ifdef DEBUG
#define NSLog(fmt, ...)  NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define NSLog(...)
#endif

/*
 全局配置
 */
#define MWScreenWidth [UIScreen mainScreen].bounds.size.width
#define MWScreenHeight [UIScreen mainScreen].bounds.size.height

#define MWGetMinX(view) CGRectGetMinX(view.frame)//视图最小X坐标
#define MWGetMinY(view) CGRectGetMinY(view.frame)//视图最小Y坐标
#define MWGetMidX(view) CGRectGetMidX(view.frame)//视图中间X坐标
#define MWGetMidY(view) CGRectGetMidY(view.frame)//视图中间Y坐标
#define MWGetMaxX(view) CGRectGetMaxX(view.frame)//视图最大X坐标
#define MWGetMaxY(view) CGRectGetMaxY(view.frame)//视图最大Y坐标
#define MWGetWidth(view) CGRectGetWidth(view.frame)//视图宽度
#define MWGetHeight(view) CGRectGetHeight(view.frame)//视图高度

//导航条高度
#define MWNavigationBarHeight 44.f
//状态栏高度，如果状态栏隐藏则会返回0
#define MWStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
//状态栏加导航条高度
#define MWTopBarHeight MWStatusBarHeight+MWNavigationBarHeight

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
