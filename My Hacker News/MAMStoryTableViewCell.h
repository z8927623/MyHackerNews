//
//  MAMStoryTableViewCell.h
//  My Hacker News
//
//  Created by Wild Yaoyao on 14-4-21.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MAMStoryTableViewCell;

@protocol MAMStoryTableViewCellDelegate <NSObject>

@optional
- (void)tableViewDidRecognozeLongPressGestureWithCell:(MAMStoryTableViewCell *)cell;

@end

// UITableViewCell默认已经声明UIGestureRecognizerDelegate协议
@interface MAMStoryTableViewCell : UITableViewCell

@property (weak, nonatomic) id <MAMStoryTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;
@property (weak, nonatomic) IBOutlet UILabel *description;
@property (weak, nonatomic) IBOutlet UILabel *footer;

@end
