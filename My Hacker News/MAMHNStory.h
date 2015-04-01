//
//  MAMHNStory.h
//  My Hacker News
//
//  Created by Wild Yaoyao on 14-4-22.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAMHNStory : NSObject <NSCoding>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *pubDate;
@property (nonatomic, copy) NSString *score;
@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *discussionLink;
@property (nonatomic, copy) NSString *commentsValue;
@property (nonatomic, copy) NSString *hostValue;
@property (nonatomic, copy) NSString *hnID;

- (NSString *)subtitle;
- (NSString *)footer;

- (NSString *)domain;

- (void)loadClearReadLoadBody:(void(^)(NSString *resultBody, MAMHNStory *story))completionBlock;

@end
