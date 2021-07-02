//
//  Tweet.m
//  twitter
//
//  Created by Pranitha Reddy Kona on 6/28/21.
//  Copyright © 2021 Emerson Malca. All rights reserved.
//

#import "Tweet.h"
#import "DateTools.h"

@implementation Tweet

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
     self = [super init];
     if (self) {

         NSDictionary *originalTweet = dictionary[@"retweeted_status"];
         if(originalTweet != nil){
             NSDictionary *userDictionary = dictionary[@"user"];
             self.retweetedByUser = [[User alloc] initWithDictionary:userDictionary];
             dictionary = originalTweet;
         }
         
         self.idStr = dictionary[@"id_str"];
         self.text = dictionary[@"full_text"];
         self.favoriteCount = [dictionary[@"favorite_count"] intValue];
         self.favorited = [dictionary[@"favorited"] boolValue];
         self.retweetCount = [dictionary[@"retweet_count"] intValue];
         self.retweeted = [dictionary[@"retweeted"] boolValue];
         
         NSDictionary *user = dictionary[@"user"];
         self.user = [[User alloc] initWithDictionary:user];
         
         NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
         formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
         NSDate *date = [formatter dateFromString:dictionary[@"created_at"]];
         
         self.createdAtString = [date shortTimeAgoSinceNow];
         self.createdAtUnformattedString = dictionary[@"created_at"];
         
         NSDictionary *entities = dictionary[@"entities"];
         self.urls = entities[@"urls"];
         self.media = entities[@"media"];
         
         self.replyToTweetId = dictionary[@"in_reply_to_status_id_str"];
     }
     return self;
 }

+ (NSMutableArray *)tweetsWithArray:(NSArray *)dictionaries{
    NSMutableArray *tweets = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:dictionary];
        [tweets addObject:tweet];
    }
    return tweets;
}

@end
