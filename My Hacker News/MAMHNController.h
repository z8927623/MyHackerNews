//
//  MAMHNController.h
//  My Hacker News
//
//  Created by Wild Yaoyao on 14-4-21.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MAMHNStory.h"
#import "MAMHNComment.h"

typedef NS_ENUM(NSInteger, HNControllerStoryType) {
    HNControllerStoryTypeTrending,
    HNControllerStoryTypeNew,
    HNControllerStoryTypeBest
};

@interface MAMHNController : NSObject

+ (id)sharedController;

// Methods
- (NSArray *)loadStoriesFromCacheOfType:(HNControllerStoryType)storyType;
- (void)loadStoriesOfType:(HNControllerStoryType)storyType result:(void(^)(NSArray *results, HNControllerStoryType type, BOOL success))completionBlock;

- (MAMHNStory *)nextStory:(MAMHNStory *)currentStory;
- (MAMHNStory *)previousStory:(MAMHNStory *)currentStory;

- (void)loadCommentsOnStoryWithID:(NSString *)storyID result:(void(^)(NSArray *results))completionBlock;

// Helpers
+ (BOOL)isPad;

@end
