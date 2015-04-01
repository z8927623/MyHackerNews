//
//  MAMReaderViewController.h
//  My Hacker News
//
//  Created by Wild Yaoyao on 14-4-21.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReaderViewDelegate <NSObject>

- (void)readerExit;

@end

@interface MAMReaderViewController : UIViewController

@property (weak, nonatomic) id <ReaderViewDelegate> delegate;

- (void)setStory:(MAMHNStory *)story;
- (MAMHNStory *)story;

@end
