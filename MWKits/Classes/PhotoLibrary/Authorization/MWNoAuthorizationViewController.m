//
//  MWNoAuthorizationViewController.m
//  MWKits
//
//  Created by 石茗伟 on 2018/12/26.
//

#import "MWNoAuthorizationViewController.h"
#import "MWImageHelper.h"
#import "MWDefines.h"
#import "UIColor+MWUtil.h"

@interface MWNoAuthorizationViewController ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *tipsLabel;

@end

@implementation MWNoAuthorizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupParams];
    [self setupUI];
}

#pragma mark - Setup
- (void)setupParams {
    self.title = @"授权失败";
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self pvt_setupNavigationBarButtons];
    [self.view addSubview:self.iconImageView];
    [self.view addSubview:self.tipsLabel];
}

- (void)pvt_setupNavigationBarButtons {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, MWNavigationBarHeight, MWNavigationBarHeight);
    backButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [backButton setTitleColor:self.configuration.navTitleColor forState:UIControlStateNormal];
    [backButton setTitle:@"取消" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.rightBarButtonItems = @[backItem];
}

#pragma mark - Actions
- (void)clickBackButton {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - LazyLoad
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30.f, 30.f)];
        _iconImageView.image = [MWImageHelper loadImageWithName:@"no_authorization"];
        MWSetCenterX(_iconImageView, self.view.center.x);
        MWSetCenterY(_iconImageView, MWGetHeight(self.view)/5.f);
    }
    return _iconImageView;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.f, CGRectGetMaxY(self.iconImageView.frame)+20.f, MWScreenWidth-20.f, 30.f)];
        _tipsLabel.font = [UIFont systemFontOfSize:14.f];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.textColor = [UIColor mw_colorWithHexString:@"bfbfbf"];
        switch (self.type) {
            case MWPhotoAuthorizationTypePhotoLibrary: {
                _tipsLabel.text = @"请在设备的\"设置-隐私-相册\"中允许访问相册。";
                break;
            }
            case MWPhotoAuthorizationTypeCamera: {
                _tipsLabel.text = @"请在设备的\"设置-隐私-相机\"中允许访问相机。";
                break;
            }
            case MWPhotoAuthorizationTypeMicrophone: {
                _tipsLabel.text = @"请在设备的\"设置-隐私-麦克风\"中允许访问x麦克风。";
                break;
            }
            default:
                break;
        }
    }
    return _tipsLabel;
}

@end
