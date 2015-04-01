//
//  MAMReaderViewController.m
//  My Hacker News
//
//  Created by Wild Yaoyao on 14-4-21.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import "MAMReaderViewController.h"

// Dependancies
#import "MAMCommentsViewController.h"
#import "MAMWebViewController.h"
#import "NSString+Additions.h"
#import <QuartzCore/QuartzCore.h>

//Categories
#import "UIView+AnchorPoint.h"

typedef NS_ENUM(NSInteger, StoryTransitionType) {
    StoryTransitionTypeNext,
    StoryTransitionTypePrevious
};

typedef NS_ENUM(NSInteger, FontSizeChangeType) {
    FontSizeChangeTypeIncrease,
    FontSizeChangeTypeDecrease,
    FontSizeChangeTypeNone
};


@interface MAMReaderViewController () <UIGestureRecognizerDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *topBar;

- (IBAction)tabButtonTapped:(id)sender;
- (IBAction)back:(id)sender;

- (IBAction)fontSizePinch:(id)sender;
- (IBAction)tapGesture:(id)sender;


@end

@implementation MAMReaderViewController
{
    MAMHNStory *_story;
    NSMutableString *_string;
    int _currentFontSize;
}

- (BOOL)prefersStatusBarHidden
{
    if ([MAMHNController isPad]) {
       return YES;
    }
    return NO;
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
    
    // 设置字体
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ftsz"] == nil) {
        _currentFontSize = 100;
    } else {
        _currentFontSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"ftsz"];
    }
    
    // why
    for (UIView *view in [[[self.webView subviews] objectAtIndex:0] subviews]) {
        if ([view isKindOfClass:[UIImageView class]]) {
            view.hidden = YES;
        }
    }
    
    BOOL isPad = [MAMHNController isPad];
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake((isPad) ? 44 : 0, 0, (isPad) ? 0 : 44, 0);
    self.webView.scrollView.contentInset = edgeInsets;
    self.webView.scrollView.scrollIndicatorInsets = edgeInsets;
    
    UITapGestureRecognizer *imageTapDetector = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    imageTapDetector.numberOfTapsRequired = 1;
    imageTapDetector.delegate = self;
    // Set this property to YES to prevent views from processing any touches in the UITouchPhaseBegan phase that may be recognized as part of this gesture.
    // 在UIScrollView中识别手势
    imageTapDetector.delaysTouchesBegan = YES;
    [self.webView addGestureRecognizer:imageTapDetector];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark WebView

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeReload) {
        NSLog(@"%@", request.URL);
    }
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [self performSegueWithIdentifier:@"toWeb" sender:request];
        return NO;
    }
    return YES;
}

- (void)tapDetected:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateRecognized) {
        CGPoint touchPoint = [tap locationInView:self.view];
        NSString *imageURL = [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y]];
        static NSSet *imageFormats;
        if (!imageFormats.count) {
            imageFormats = [NSSet setWithObjects:@"jpg", @"jpeg", @"bmp", @"png", nil];
        }
        if ([imageFormats containsObject:imageURL.pathExtension]) {
            NSCachedURLResponse *response = [[NSURLCache sharedURLCache] cachedResponseForRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL] cachePolicy:NSURLRequestReturnCacheDataDontLoad timeoutInterval:11]];
            NSLog(@"response: %@", response);
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toWeb"]) {
        NSURLRequest *urlRequest = sender;
        MAMWebViewController *webViewController = segue.destinationViewController;
        [webViewController loadURL:urlRequest.URL];
    }
    
    if ([segue.identifier isEqualToString:@"toComments"]) {
        MAMCommentsViewController *commentsViewController = segue.destinationViewController;
        [commentsViewController setStory:self.story];
    }
}

- (IBAction)tabButtonTapped:(id)sender {
    int numberOfButtonTapped = [sender tag];
    switch (numberOfButtonTapped) {
        case 0:
            [self back:nil];
            break;
        case 1:
            [self transitionToStory:StoryTransitionTypePrevious];
            break;
        case 2:
            [self transitionToStory:StoryTransitionTypeNext];
            break;
        case 3:
            [self performSegueWithIdentifier:@"toComments" sender:nil];
            break;
        case 4:
        {
            NSURL *URL = [NSURL URLWithString:self.story.link];
            [self.navigationController presentViewController:nil animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

- (IBAction)back:(id)sender {
    [_delegate readerExit];
}

- (void)transitionToStory:(StoryTransitionType)transitionType
{
    MAMHNController *hnController = [MAMHNController sharedController];
    MAMHNStory *story = (transitionType == StoryTransitionTypeNext) ? [hnController nextStory:_story] : [hnController previousStory:_story];
    
    CABasicAnimation *strethAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    [strethAnimation setToValue:[NSNumber numberWithFloat:1.02]];
    [strethAnimation setRemovedOnCompletion:YES];
    [strethAnimation setFillMode:kCAFillModeRemoved];
    [strethAnimation setAutoreverses:YES];
    [strethAnimation setDuration:0.15];
    [strethAnimation setDelegate:self];
    if (story != nil) {
        [strethAnimation setBeginTime:CACurrentMediaTime() + 0.35];
    }
    [strethAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.view setAnchorPoint:CGPointMake(0.0, (transitionType == StoryTransitionTypeNext) ? 1 : 0) forView:self.view];
    [self.view.layer addAnimation:strethAnimation forKey:@"stretchAnimation"];
    
    if (story == nil) {
        return;
    }
    
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionPush];
    [animation setSubtype:(transitionType == StoryTransitionTypeNext ? kCATransitionFromTop : kCATransitionFromBottom)];
    [animation setDuration:0.5f];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.webView.layer addAnimation:animation forKey:nil];
    
    [self setStory:story];
}

#pragma mark - CAAnimationDelegate
// 重新设定锚点
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.view setAnchorPoint:CGPointMake(0.5, 0.5) forView:self.view];
}

- (void)changeFontSize:(FontSizeChangeType)changeType
{
    // 最大字体
    if (changeType == FontSizeChangeTypeIncrease && _currentFontSize == 160) {
        return;
    }
    // 最小字体
    if (changeType == FontSizeChangeTypeDecrease && _currentFontSize == 50) {
        return;
    }
    if (changeType != FontSizeChangeTypeNone) {
        _currentFontSize = (changeType == FontSizeChangeTypeIncrease) ? _currentFontSize + 5 : _currentFontSize - 5;
        [[NSUserDefaults standardUserDefaults] setInteger:_currentFontSize forKey:@"ftsz"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    // 设置webView字体
    NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%i%%'", _currentFontSize];
    [self.webView stringByEvaluatingJavaScriptFromString:jsString];
}

#pragma mark -
#pragma mark Story Management

- (void)setStory:(MAMHNStory *)story
{
    _story = story;
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.open();document.close();"];
    
    NSString *storyLink = story.link.localCachePath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:storyLink]) {
        NSString *htmlString = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:storyLink] encoding:NSUTF8StringEncoding error:nil];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"**[txtadjust]**" withString:[NSString stringWithFormat:@"%i%%", _currentFontSize]];
        [self.webView loadHTMLString:htmlString baseURL:nil];
        return;
    }
    // 网页加载下来之前的填充
    NSMutableString *string = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:([MAMHNController isPad]) ? @"view_Pad" : @"view" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil] mutableCopy];
    [string replaceOccurrencesOfString:@"**[title]**" withString:_story.title options:0 range:NSMakeRange(0, string.length)];
    [string replaceOccurrencesOfString:@"**[points]**" withString:_story.score options:0 range:NSMakeRange(0, string.length)];
    [string replaceOccurrencesOfString:@"**[domain]**" withString:_story.domain options:0 range:NSMakeRange(0, string.length)];
    [string replaceOccurrencesOfString:@"**[link]**" withString:_story.link options:0 range:NSMakeRange(0, string.length)];
    NSString *targetFontSize = [NSString stringWithFormat:@"%i.000001%%",_currentFontSize];
    [string replaceOccurrencesOfString:@"**[txtadjust]**" withString:targetFontSize options:0 range:NSMakeRange(0, string.length)];
    
    _string = string;
    [self.webView loadHTMLString:string baseURL:nil];
    
    __weak MAMReaderViewController *weakSelf = self;
    [_story loadClearReadLoadBody:^(NSString *resultBody, MAMHNStory *story) {
        if (story != _story) {
            return;
        }
        // 完成后再替换
        [string replaceOccurrencesOfString:targetFontSize withString:@"**[txtadjust]**" options:0 range:NSMakeRange(0, string.length)];
        NSString *clearReadDocument = [string stringByReplacingOccurrencesOfString:@"Loading...  " withString:resultBody options:0 range:NSMakeRange(0, _string.length)];
        [clearReadDocument writeToFile:storyLink atomically:NO encoding:NSUTF8StringEncoding error:nil];
        [weakSelf.webView loadHTMLString:[clearReadDocument stringByReplacingOccurrencesOfString:@"**[txtadjust]**" withString:targetFontSize] baseURL:nil];
    }];
}

- (MAMHNStory *)story
{
    return _story;
}

#pragma mark -
#pragma mark Gesture Recognizers
// 显示/隐藏bottomBar
- (IBAction)tapGesture:(id)sender {
    if ([(UITapGestureRecognizer *)sender state] == UIGestureRecognizerStateRecognized) {
        [UIView animateWithDuration:0.3 animations:^{
            BOOL show = (self.topBar.alpha == 0.0);
            [self.topBar setAlpha:show ? 0.9 : 0.0];
            UIEdgeInsets edgeInsets = UIEdgeInsetsMake(([MAMHNController isPad])?44:0, 0, ([MAMHNController isPad])?0:44, 0);
            if (!show) {
                edgeInsets = UIEdgeInsetsZero;
            }
            self.webView.scrollView.contentInset = edgeInsets;
            self.webView.scrollView.scrollIndicatorInsets = edgeInsets;
        }];
    }
}

- (IBAction)fontSizePinch:(id)sender {
    UIPinchGestureRecognizer *pinch = sender;
    if (pinch.state == UIGestureRecognizerStateRecognized) {
        [self changeFontSize:pinch.scale > 1 ? FontSizeChangeTypeIncrease : FontSizeChangeTypeDecrease];
    }
}

#pragma mark - UIGestureRecognizerDelegate
// 允许同时检测多个手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
