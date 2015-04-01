//
//  MAMCommentTableViewCell.h
//  My Hacker News
//
//  Created by Wild Yaoyao on 14-4-22.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTTAttributedLabel;

@interface MAMCommentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *user;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *comment;

+ (CGFloat)heightForCellWithText:(NSString *)text constrainedToWidth:(float)width;

@end
