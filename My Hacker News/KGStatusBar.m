//
//  KGStatusBar.m
//  My Hacker News
//
//  Created by Wild Yaoyao on 14-4-27.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import "KGStatusBar.h"

@interface KGStatusBar ()

@property (nonatomic, strong, readonly) UIWindow *overlayWindow;
@property (nonatomic, strong, readonly) UIView *topBar;
@property (nonatomic, strong) UILabel *stringLabel;

@end

@implementation KGStatusBar
{
    BOOL _statusBarWasInitiallyHidden;
}

@synthesize topBar, overlayWindow, stringLabel;

+ (KGStatusBar *)sharedView
{
    static dispatch_once_t once;
    static KGStatusBar *sharedView = nil;
    dispatch_once(&once, ^ {
        sharedView = [[KGStatusBar alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    });
    
    return sharedView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

+ (void)showSuccessWithStatus:(NSString *)status
{
    [KGStatusBar showWithStatus:status];
    [KGStatusBar performSelector:@selector(dismiss) withObject:self afterDelay:2.0];
}

+ (void)showErrorWithStatus:(NSString *)status
{
    [[KGStatusBar sharedView] showWithStatus:status barColor:[UIColor colorWithRed:97.0/255.0 green:4.0/255.0 blue:4.0/255.0 alpha:1.0] textColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [KGStatusBar performSelector:@selector(dismiss) withObject:self afterDelay:2.0];
}

+ (void)showWithStatus:(NSString *)status duration:(NSInteger)duration
{
    [KGStatusBar showWithStatus:status];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [KGStatusBar dismiss];
    });
}

+ (void)showWithStatus:(NSString *)status
{
    [[KGStatusBar sharedView] showWithStatus:status barColor:[UIColor colorWithRed:0.94f green:0.94f blue:0.94f alpha:1.00f] textColor:[UIColor darkTextColor]];
}

+ (void)dismiss
{
    [[KGStatusBar sharedView] dismiss];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.4 animations:^{
        self.stringLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        [topBar removeFromSuperview];
        topBar = nil;
        
        [overlayWindow removeFromSuperview];
        overlayWindow = nil;
    }];
}


- (void)showWithStatus:(NSString *)status barColor:(UIColor *)barColor textColor:(UIColor *)textColor
{
    if (!self.superview) {
        [self.overlayWindow addSubview:self];
    }
    // 使被使用对象的主窗口显示到屏幕的最前端
    [self.overlayWindow makeKeyAndVisible];
    // overlayWindow {0, 0}, {320, 568}
    self.topBar.hidden = NO;
    self.topBar.backgroundColor = barColor;
    
    NSString *labelText = status;
    CGRect labelRect = CGRectZero;
    CGFloat stringWidth = 0;
    CGFloat stringHeight = 0;
    if (labelText) {
        stringWidth = [labelText boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.topBar.frame), CGRectGetHeight(self.topBar.frame)) options:NSStringDrawingUsesDeviceMetrics attributes:@{NSFontAttributeName:self.stringLabel.font} context:nil].size.width;
        
        stringHeight = 20;
        
        labelRect = CGRectMake(CGRectGetMidX(self.topBar.frame) - (stringWidth / 2), 0, stringWidth, stringHeight);

    }
    self.stringLabel.frame = labelRect;
    self.stringLabel.alpha = 0.0;
    self.stringLabel.hidden = NO;
    self.stringLabel.text = labelText;
    self.stringLabel.textColor = textColor;
    [UIView animateWithDuration:0.4 animations:^{
        self.stringLabel.alpha = 1.0;
    }];
    // setNeedsDisplay调用drawRect方法来实现view的绘制，而setNeedsLayout则调用layoutSubView来实现view中subView的重新布局
    [self setNeedsDisplay];
}

#pragma mark - Handle Rotation

- (CGFloat)rotation
{
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat rotation = 0.f;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            rotation = -M_PI_2;
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotation = M_PI_2;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            rotation = M_PI;
            break;
        case UIInterfaceOrientationPortrait:
            break;
        default:
            break;
    }
    return rotation;
}

 -(CGSize)rotatedSize
{
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGSize rotatedSize = screenSize;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            rotatedSize = CGSizeMake(screenSize.height, screenSize.width);
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotatedSize = CGSizeMake(screenSize.height, screenSize.width);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            break;
        case UIInterfaceOrientationPortrait:
            break;
        default:
            break;
    }
    return rotatedSize;
}

- (UIWindow *)overlayWindow
{
    if (!overlayWindow) {
        overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayWindow.backgroundColor = [UIColor clearColor];
        overlayWindow.userInteractionEnabled = YES;
        // 优先级
        overlayWindow.windowLevel = UIWindowLevelStatusBar + 1;
        
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation([self rotation]);
        self.overlayWindow.transform = rotationTransform;
        // 320 568
        self.overlayWindow.bounds = CGRectMake(0.f, 0.f, [self rotatedSize].width, [self rotatedSize].height);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRotation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
    }
    
    return overlayWindow;
}

- (UIView *)topBar
{
    if (!topBar) {
        topBar = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, [self rotatedSize].width, 20.0f)];
        [overlayWindow addSubview:topBar];
    }
    return topBar;
}

- (UILabel *)stringLabel
{
    if (stringLabel == nil) {
        stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        stringLabel.textColor = [UIColor colorWithRed:191.0/255.0 green:191.0/255.0 blue:191.0/255.0 alpha:1.0];
		stringLabel.backgroundColor = [UIColor clearColor];
        stringLabel.adjustsFontSizeToFitWidth = YES;
        stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        stringLabel.font = [UIFont systemFontOfSize:12];
        stringLabel.numberOfLines = 0;
        stringLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    
    if (!stringLabel.superview) {
        [self.topBar addSubview:stringLabel];
    }
    
    return stringLabel;
}

- (void)handleRotation:(id)sender
{
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation([self rotation]);
    [UIView animateWithDuration:[[UIApplication sharedApplication] statusBarOrientation] animations:^(void) {
        self.overlayWindow.transform = rotationTransform;
        self.overlayWindow.bounds = CGRectMake(0.f, 0.f, [self rotatedSize].width, [self rotatedSize].height);
        self.topBar.frame = CGRectMake(0.f, 0.f, [self rotatedSize].width, 20.f);
    }];
}

@end
