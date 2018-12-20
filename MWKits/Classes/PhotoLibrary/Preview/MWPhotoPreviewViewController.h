//
//  MWPhotoPreviewViewController.h
//  MWKits
//
//  Created by 石茗伟 on 2018/12/20.
//

#import <UIKit/UIKit.h>
#import "MWPhotoObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface MWPhotoPreviewViewController : UIViewController

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSArray<MWPhotoObject *> *photoObjects;

@end

NS_ASSUME_NONNULL_END
