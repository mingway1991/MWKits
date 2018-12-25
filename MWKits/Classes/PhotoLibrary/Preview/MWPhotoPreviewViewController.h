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

@property (nonatomic, strong) MWPhotoConfiguration *configuration;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSArray<MWPhotoObject *> *photoObjects;

/** 是否是push到该页面 */
@property (nonatomic, assign) BOOL isPush;

@end

NS_ASSUME_NONNULL_END
