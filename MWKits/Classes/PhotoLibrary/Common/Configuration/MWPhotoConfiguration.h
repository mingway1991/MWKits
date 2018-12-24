//
//  MWPhotoConfiguration.h
//  MWKits
//
//  Created by 石茗伟 on 2018/12/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MWPhotoConfiguration : NSObject

/** 最小选择数 默认1张 */
@property (nonatomic, assign) NSInteger minSelectCount;

/** 最大选择数 默认9张 */
@property (nonatomic, assign) NSInteger maxSelectCount;

/** 是否允许选择图片 */
@property (nonatomic, assign) BOOL allowSelectImage;

/** 是否允许选择gif */
@property (nonatomic, assign) BOOL allowSelectGif;

/** 是否允许选择视频 */
@property (nonatomic, assign) BOOL allowSelectVideo;

/** 是否允许选择原图，默认YES */
@property (nonatomic, assign) BOOL allowSelectOriginal;

/** 是否允许滑动选择 默认 YES */
@property (nonatomic, assign) BOOL allowSlideSelect;

/** 导航条颜色，默认白色 */
@property (nonatomic, strong) UIColor *navBarColor;

/** 导航标题颜色，默认黑色 */
@property (nonatomic, strong) UIColor *navTitleColor;


- (instancetype)init NS_UNAVAILABLE;

/**
 默认相册配置
 */
+ (instancetype)defaultPhotoConfiguration;

@end

NS_ASSUME_NONNULL_END
