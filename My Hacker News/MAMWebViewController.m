//
//  MAMWebViewController.m
//  My Hacker News
//
//  Created by Wild Yaoyao on 14-4-22.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import "MAMWebViewController.h"

@interface MAMWebViewController ()

- (IBAction)dismiss:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)forward:(id)sender;
- (IBAction)safari:(id)sender;

@end

@implementation MAMWebViewController
{
    NSURL *_URLToLoad;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    if ([MAMHNController isPad]) {
        return YES;
    }
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    BOOL isPad = [MAMHNController isPad];
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake((isPad) ? 0 : 0, 0, (isPad) ? 0 : 44, 0);
    [self.webView.scrollView setContentInset:edgeInsets];
    [self.webView.scrollView setScrollIndicatorInsets:edgeInsets];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:_URLToLoad]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadURL:(NSURL *)URL
{
    _URLToLoad = URL;
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)back:(id)sender {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

- (IBAction)forward:(id)sender {
    if ([self.webView canGoForward]) {
        [self.webView goForward];
    }
}

- (IBAction)safari:(id)sender {
    NSURL *URL = self.webView.request.URL;
}

#pragma mark -
#pragma mark Gesture Recognizer
// 允许同时检测多个手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
@end
