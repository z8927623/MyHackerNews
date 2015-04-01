//
//  MAMHNComment.h
//  My Hacker News
//
//  Created by Wild Yaoyao on 14-4-22.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAMHNComment : NSObject

@property (copy, nonatomic) NSString *comment;
@property (copy, nonatomic) NSString *commentID;
@property (copy, nonatomic) NSString *time;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *replyID;

- (void)setIndentationLevel:(int)level;
- (int)indentationLevel;

- (UIColor *)color;

@end
