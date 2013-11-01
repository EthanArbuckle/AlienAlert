//
//  RedditBotKit.m
//  RedditBotKit
//
//  Created by Ethan Arbuckle on 7/10/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "RedditBotKit.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"

FMDatabase *db;

@implementation RedditBotKit

- (id)init {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"alienalertcache.sqlite"];
    db = [FMDatabase databaseWithPath:writableDBPath];
    [db open];
    [db executeUpdate:@"create table posts (id text)"];
    [db close];
    return self;
}

- (BOOL)loginWithUsername:(NSString *)username andPassword:(NSString *)password {
    self.username = username;
    NSURL *loginurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.reddit.com/api/login/%@", username]];
    NSMutableURLRequest *loginrequest = [NSMutableURLRequest requestWithURL:loginurl];
    [loginrequest setHTTPMethod:@"POST"];
    NSData *loginRequestBody = [[NSString stringWithFormat:@"api_type=json&user=%@&passwd=%@", username, password] dataUsingEncoding:NSUTF8StringEncoding];
    [loginrequest setHTTPBody:loginRequestBody];
    [loginrequest setValue:@"AlienBlue Bot - Answers questions on /r/alienblue - made by /u/its_not_herpes" forHTTPHeaderField:@"User-Agent"];
    NSURLResponse *loginResponse = NULL;
    NSError *loginRequestError = NULL;
    NSData *loginResponseData = [NSURLConnection sendSynchronousRequest:loginrequest returningResponse:&loginResponse error:&loginRequestError];
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:loginResponseData options:0 error:nil];
    _modhash = [[[response objectForKey:@"json"] objectForKey:@"data"] objectForKey:@"modhash"];
    if ([_modhash length] > 2) {
        return TRUE;
    }
    return FALSE;

}

- (BOOL)postCommentText:(NSString *)text onCommentID:(NSString *)pid {
    NSURL *commentURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.reddit.com/api/comment"]];
    NSMutableURLRequest *commentRequest = [NSMutableURLRequest requestWithURL:commentURL];
    [commentRequest setHTTPMethod:@"POST"];
    [commentRequest setValue:@"AlienBlue Bot - Answers questions on /r/alienblue - made by /u/its_not_herpes" forHTTPHeaderField:@"User-Agent"];
    NSData *commentRequestBody = [[NSString stringWithFormat:@"api_type=json&text=%@&thing_id=t3_%@&uh=%@", text,pid,_modhash] dataUsingEncoding:NSUTF8StringEncoding];
    [commentRequest setHTTPBody:commentRequestBody];
    NSURLResponse *commentResponse = NULL;
    NSError *commentRequestError = NULL;
    NSData *commentResponseData = [NSURLConnection sendSynchronousRequest:commentRequest returningResponse:&commentResponse error:&commentRequestError];
    NSString *commentResponseString = [[NSString alloc]initWithData:commentResponseData encoding:NSUTF8StringEncoding];
    if ([commentResponseString rangeOfString:@"too much"].location != NSNotFound) {
        NSMutableDictionary *error = [NSJSONSerialization JSONObjectWithData:[commentResponseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        _ratelimit = [[[error objectForKey:@"json"] objectForKey:@"ratelimit"] intValue];
        NSLog(@"%d", _ratelimit/60);
        NSLog(@"%d", _ratelimit/60);
        NSLog(@"%d", _ratelimit/60);NSLog(@"%d", _ratelimit/60);
        NSLog(@"%d", _ratelimit/60);
        [NSThread sleepForTimeInterval:_ratelimit/60];
        [self postCommentText:text onCommentID:pid];
        return false;
    }
    return true;
}

- (void)markPostAsDone:(NSString *)postID {
    if (![db open]) {
        [db open];
    }
    [db beginTransaction];
    [db executeUpdate:@"insert into posts (id) values (?)" , postID];
    [db commit];
}

- (BOOL)postAlreadyWorked:(NSString *)postID {
    if (![db open]) {
        [db open];
    }
    FMResultSet *rs = [db executeQuery:@"select * from posts where id = ?", postID];
    if ([rs next]) {
        return YES;
    }
    return NO;
}
@end
