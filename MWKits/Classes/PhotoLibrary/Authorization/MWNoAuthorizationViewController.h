//
//  MWNoAuthorizationViewController.h
//  MWKits
//
//  Created by 石茗伟 on 2018/12/26.
//

#import <UIKit/UIKit.h>
#import "MWPhotoConfiguration.h"

typedef enum : NSUInteger {
    MWPhotoAuthorizationTypePhotoLibrary,
    MWPhotoAuthorizationTypeCamera,
    MWPhotoAuthorizationTypeMicrophone,
} MWPhotoAuthorizationType;

NS_ASSUME_NONNULL_BEGIN

@interface MWNoAuthorizationViewController : UIViewController

@property (nonatomic, strong) MWPhotoConfiguration *configuration;

@property (nonatomic, assign) MWPhotoAuthorizationType type;

@end

NS_ASSUME_NONNULL_END
