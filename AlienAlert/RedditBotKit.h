//
//  RedditBotKit.h
//  RedditBotKit
//
//  Created by Ethan Arbuckle on 7/10/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RedditBotKit : NSObject
@property NSString *modhash;
@property NSString *username;
@property int ratelimit;

- (BOOL)loginWithUsername:(NSString *)username andPassword:(NSString *)password;
- (BOOL)postCommentText:(NSString *)text onCommentID:(NSString *)pid;
- (void)markPostAsDone:(NSString *)postID;
- (BOOL)postAlreadyWorked:(NSString *)postID;
@end
