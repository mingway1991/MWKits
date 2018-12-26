//
//  MWPhotoPreviewViewController.h
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import <UIKit/UIKit.h>
#import "MWPhotoObject.h"
#import "MWPhotoConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface MWPhotoPreviewViewController : UIViewController

/** 配置 */
@property (nonatomic, strong) MWPhotoConfiguration *configuration;

/** 当前展示索引 */
@property (nonatomic, assign) NSInteger currentIndex;

/** 传入需要展示的照片对象数组 */
@property (nonatomic, strong) NSArray<MWPhotoObject *> *photoObjects;

/** 是否是push到该页面。YES为从选择进入到该页面，NO为直接进入预览界面 */
@property (nonatomic, assign) BOOL isPush;

/** 是否支持选择 */
@property (nonatomic, assign) BOOL canSelect;

@end

NS_ASSUME_NONNULL_END
