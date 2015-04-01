//
//  KGStatusBar.h
//  My Hacker News
//
//  Created by Wild Yaoyao on 14-4-27.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KGStatusBar : UIView

+ (void)showWithStatus:(NSString *)status;
+ (void)showErrorWithStatus:(NSString *)status;
+ (void)showSuccessWithStatus:(NSString *)status;
+ (void)dismiss;

+ (void)showWithStatus:(NSString *)status duration:(NSInteger)duration;

@end
