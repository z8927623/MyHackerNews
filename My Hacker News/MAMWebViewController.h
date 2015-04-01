//
//  MAMWebViewController.h
//  My Hacker News
//
//  Created by Wild Yaoyao on 14-4-22.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAMWebViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (void)loadURL:(NSURL *)URL;

@end
