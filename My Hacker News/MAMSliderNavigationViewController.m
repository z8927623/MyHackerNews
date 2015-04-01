//
//  MAMSliderNavigationViewController.m
//  My Hacker News
//
//  Created by Wild Yaoyao on 14-4-21.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import "MAMSliderNavigationViewController.h"
#import "UIView+AnchorPoint.h"


@interface MAMSliderNavigationViewController ()

@end

@implementation MAMSliderNavigationViewController

- (void)viewWillLayoutSubviews
{
    [self.view.window setBackgroundColor:[UIColor colorWithRed:0.949 green:.949 blue:0.949 alpha:1.0]];
}

// 覆写push方法
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (animated) {
        CABasicAnimation *stretchAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
        [stretchAnimation setToValue:[NSNumber numberWithFloat:1.04]];
        [stretchAnimation setRemovedOnCompletion:YES];
        [stretchAnimation setFillMode:kCAFillModeRemoved];
        [stretchAnimation setAutoreverses:YES];
        [stretchAnimation setDuration:0.15];
        [stretchAnimation setBeginTime:CACurrentMediaTime() + 0.3];
        [stretchAnimation setDelegate:self];
        [stretchAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.view setAnchorPoint:CGPointMake(1, 0.5) forView:self.view];
        [self.view.layer addAnimation:stretchAnimation forKey:@"stretchAnimation"];
    }
    
    CATransition *transition = [CATransition animation];
    UIInterfaceOrientation interfaceOrientation = viewController.interfaceOrientation;
    NSString *subtypeTransition = kCATransitionFromRight;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            subtypeTransition = kCATransitionFromBottom;
            break;
        case UIInterfaceOrientationLandscapeRight:
            subtypeTransition = kCATransitionFromTop;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            subtypeTransition = kCATransitionFromLeft;
            break;
        default:
            break;
    }
    transition.duration = 0.4f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = subtypeTransition;
    transition.removedOnCompletion = YES;
    transition.fillMode = kCAFillModeRemoved;
    [self.view.layer addAnimation:transition forKey:nil];
    
    return [super pushViewController:viewController animated:NO];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if (animated) {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.3f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        transition.type = kCATransitionReveal;
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        NSString *subtypeTransition = kCATransitionFromLeft;
        switch (interfaceOrientation)
        {
            case UIInterfaceOrientationLandscapeLeft:
                subtypeTransition = kCATransitionFromTop;
                break;
            case UIInterfaceOrientationLandscapeRight:
                subtypeTransition = kCATransitionFromBottom;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                subtypeTransition = kCATransitionFromRight;
                break;
            default:
                break;
        }
        transition.subtype = subtypeTransition;
        transition.removedOnCompletion = YES;
        transition.fillMode = kCAFillModeRemoved;
        [self.view.layer addAnimation:transition forKey:nil];
    }
    
    return [super popViewControllerAnimated:NO];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
