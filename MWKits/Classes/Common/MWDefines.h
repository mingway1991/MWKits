//
//  MWDefines.h
//  Pods
//
//  Created by 石茗伟 on 2018/9/4.
//

#ifndef MWDefines_h
#define MWDefines_h

#define force_inline __inline__ __attribute__((always_inline))

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

//get
#define MWGetMinX(view) CGRectGetMinX(view.frame)//视图最小X坐标
#define MWGetMinY(view) CGRectGetMinY(view.frame)//视图最小Y坐标
#define MWGetMidX(view) CGRectGetMidX(view.frame)//视图中间X坐标
#define MWGetMidY(view) CGRectGetMidY(view.frame)//视图中间Y坐标
#define MWGetMaxX(view) CGRectGetMaxX(view.frame)//视图最大X坐标
#define MWGetMaxY(view) CGRectGetMaxY(view.frame)//视图最大Y坐标
#define MWGetWidth(view) CGRectGetWidth(view.frame)//视图宽度
#define MWGetHeight(view) CGRectGetHeight(view.frame)//视图高度
#define MWGetCenterX(view) view.center.x//centerX
#define MWGetCenterY(view) view.center.y//centerY

//set
#define MWSetMinX(view,x) view.frame = CGRectMake(x,MWGetMinY(view),MWGetWidth(view),MWGetHeight(view))
#define MWSetMinY(view,y) view.frame = CGRectMake(MWGetMinX(view),y,MWGetWidth(view),MWGetHeight(view))
#define MWSetOrigin(view,origin) view.frame = CGRectMake(origin.x,origin.y,MWGetWidth(view),MWGetHeight(view))
#define MWSetWidth(view,width) view.frame = CGRectMake(MWGetMinX(view),MWGetMinY(view),width,MWGetHeight(view))
#define MWSetHeight(view,height) view.frame = CGRectMake(MWGetMinX(view),MWGetMinY(view),MWGetWidth(view),height)
#define MWSetCenterX(view,x) view.center = CGPointMake(x,MWGetCenterY(view))
#define MWSetCenterY(view,y) view.center = CGPointMake(MWGetCenterX(view),y)

//导航条高度
#define MWNavigationBarHeight 44.f
//状态栏高度，如果状态栏隐藏则会返回0
#define MWStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
//状态栏加导航条高度
#define MWTopBarHeight MWStatusBarHeight+MWNavigationBarHeight

#endif /* MWDefines_h */
