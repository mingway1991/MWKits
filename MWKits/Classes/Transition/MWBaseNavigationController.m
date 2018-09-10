//
//  MWBaseNavigationController.m
//  MWAnimationKit
//
//  Created by 石茗伟 on 2018/9/4.
//

#import "MWBaseNavigationController.h"
#import "UIViewController+MWTransition.h"
#import "MWDefines.h"

@interface MWBaseNavigationController () <UIGestureRecognizerDelegate>

/* 从屏幕截图数组中取出的图片进行显示 */
@property(nonatomic, strong) UIImageView *screenshotImageView;
/* 保存每一层级屏幕截图 */
@property(nonatomic, strong) NSMutableArray *screenshotImages;
/* 边缘拖动手势 */
@property(nonatomic, strong) UIScreenEdgePanGestureRecognizer *panGestureRecognizer;

@end

@implementation MWBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.canDragBack = YES;
    _panGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureRecognizer:)];
    _panGestureRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:_panGestureRecognizer];
}

#pragma mark - PanGesture
/* 响应手势的方法 */
- (void)panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer {
    if (self.viewControllers.count <= 1 ||
        self.visibleViewController == self.viewControllers.firstObject ||
        !self.topViewController.canDragBack) return;
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            [self dragBegin];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self dragEnd];
            break;
        }
        default:{
            //默认都是拖动中
            [self dragging:panGestureRecognizer];
            break;
        }
    }
}

#pragma mark - 屏幕截图
/* 屏幕截图 */
- (void)screenShot {
    // 将要被截图的view,即窗口的根控制器的view
    UIViewController *beyondVC = self.view.window.rootViewController;
    // 背景图片 总的大小
    CGSize size = beyondVC.view.frame.size;
    // 开启上下文,使用参数之后,截出来的是原图（YES  0.0 质量高）
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    // 要裁剪的矩形范围
    CGRect rect = CGRectMake(0, 0, MWScreenWidth, MWScreenHeight);
    //注：iOS7以后renderInContext：由drawViewHierarchyInRect：afterScreenUpdates：替代
    [beyondVC.view drawViewHierarchyInRect:rect afterScreenUpdates:NO];
    // 从上下文中,取出UIImage
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    // 添加截取好的图片到图片数组
    if (snapshot) {
        [self.screenshotImages addObject:snapshot];
    }
    // 千万记得,结束上下文(移除栈顶的基于当前位图的图形上下文)
    UIGraphicsEndImageContext();
}

#pragma mark - Push / Pop
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    //有在导航控制器里面有子控制器的时候才需要截图
    if (self.viewControllers.count >= 1) {
        // 调用自定义方法,使用上下文截图
        [self screenShot];
    }
    // 截图完毕之后,才调用父类的push方法
    [super pushViewController:viewController animated:YES];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    [self.screenshotImages removeLastObject];
    return [super popViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    for (NSInteger i = self.viewControllers.count - 1; i > 0; i--) {
        if (viewController == self.viewControllers[i]) {
            break;
        }
        [self.screenshotImages removeLastObject];
    }
    return [super popToViewController:viewController animated:animated];
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    [self.screenshotImages removeAllObjects];
    return [super popToRootViewControllerAnimated:animated];
}

#pragma mark - 开始拖动,添加图片和遮罩
- (void)dragBegin {
    // 重点,每次开始Pan手势时,都要添加截图imageview 和 遮盖cover到window中
    [self.view.window insertSubview:self.screenshotImageView atIndex:0];
    
    // 并且,让imgView显示截图数组中的最后(最新)一张截图
    self.screenshotImageView.image = [self.screenshotImages lastObject];
    self.screenshotImageView.transform = CGAffineTransformMakeTranslation(MWScreenWidth, 0);
}

#pragma mark - 正在拖动,动画效果的精髓,进行位移和透明度变化
- (void)dragging:(UIPanGestureRecognizer *)pan {
    // 得到手指拖动的位移
    CGFloat offsetX = [pan translationInView:self.view].x;
    // 让整个view都平移     // 挪动整个导航view
    if (offsetX > 0) {
        self.view.transform = CGAffineTransformMakeTranslation(offsetX, 0);
    }
    // 计算目前手指拖动位移占屏幕总的宽高的比例,当这个比例达到3/4时, 就让imageview完全显示，遮盖完全消失
    if (offsetX < MWScreenWidth) {
        self.screenshotImageView.transform = CGAffineTransformMakeTranslation((offsetX - MWScreenWidth) * 0.6, 0);
    }
}

#pragma mark - 结束拖动,判断结束时拖动的距离作相应的处理,并将图片和遮罩从父控件上移除
- (void)dragEnd {
    // 取出挪动的距离
    CGFloat translateX = self.view.transform.tx;
    // 取出宽度
    CGFloat width = self.view.frame.size.width;
    
    if (translateX <= 40) {
        // 如果手指移动的距离还不到屏幕的一半,往左边挪 (弹回)
        [UIView animateWithDuration:0.3 animations:^{
            // 重要~~让被右移的view弹回归位,只要清空transform即可办到
            self.view.transform = CGAffineTransformIdentity;
            // 让imageView大小恢复默认的translation
            self.screenshotImageView.transform = CGAffineTransformMakeTranslation(-MWScreenWidth, 0);
        } completion:^(BOOL finished) {
            // 重要,动画完成之后,每次都要记得 移除两个view,下次开始拖动时,再添加进来
            [self.screenshotImageView removeFromSuperview];
        }];
    } else {
        // 如果手指移动的距离还超过了屏幕的一半,往右边挪
        [UIView animateWithDuration:0.3 animations:^{
            // 让被右移的view完全挪到屏幕的最右边,结束之后,还要记得清空view的transform
            self.view.transform = CGAffineTransformMakeTranslation(width, 0);
            // 让imageView位移还原
            self.screenshotImageView.transform = CGAffineTransformMakeTranslation(0, 0);
        } completion:^(BOOL finished) {
            // 重要~~让被右移的view完全挪到屏幕的最右边,结束之后,还要记得清空view的transform,不然下次再次开始drag时会出问题,因为view的transform没有归零
            self.view.transform = CGAffineTransformIdentity;
            // 移除两个view,下次开始拖动时,再加回来
            [self.screenshotImageView removeFromSuperview];
            // 执行正常的Pop操作:移除栈顶控制器,让真正的前一个控制器成为导航控制器的栈顶控制器
            [self popViewControllerAnimated:NO];
        }];
    }
}

#pragma mark - Lazy Load
- (UIImageView *)screenshotImageView {
    if (!_screenshotImageView) {
        self.screenshotImageView = [[UIImageView alloc] init];
        _screenshotImageView.frame = CGRectMake(0, 0, MWScreenWidth, MWScreenHeight);
    }
    return _screenshotImageView;
}

- (NSMutableArray *)screenshotImages {
    if (!_screenshotImages) {
        self.screenshotImages = [NSMutableArray array];
    }
    return _screenshotImages;
}

@end
