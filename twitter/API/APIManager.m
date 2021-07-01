//
//  APIManager.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "APIManager.h"
#import "Tweet.h"
#import "User.h"

static NSString * const baseURLString = @"https://api.twitter.com";

@interface APIManager()

@end

@implementation APIManager

+ (instancetype)shared {
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    
    // TODO: fix code below to pull API Keys from your new Keys.plist file
    
     NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
     NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
     
     NSString *key= [dict objectForKey: @"consumer_Key"];
     NSString *secret = [dict objectForKey: @"consumer_Secret"];
    
    // Check for launch arguments override
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-key"]) {
        key = [[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-key"];
    }
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-secret"]) {
        secret = [[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-secret"];
    }
    
    self = [super initWithBaseURL:baseURL consumerKey:key consumerSecret:secret];
    if (self) {
        
    }
    return self;
}

- (void)getHomeTimelineWithCompletion:(void(^)(NSArray *tweets, NSError *error))completion {
    NSString *urlString = [NSString stringWithFormat: @"1.1/statuses/home_timeline.json"];
    NSDictionary *parameters = @{@"tweet_mode":@"extended"};
    
    [self GET:urlString
       parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray *  _Nullable tweetDictionaries) {
           // Success
           NSMutableArray *tweets  = [Tweet tweetsWithArray:tweetDictionaries];
           completion(tweets, nil);
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           // There was a problem
           completion(nil, error);
    }];
}

- (void)getHomeTimelineWithCount:(NSInteger) count completion:(void(^)(NSArray *tweets, NSError *error))completion {
    NSString *urlString = [NSString stringWithFormat: @"1.1/statuses/user_timeline.json?count=%ld",(long)count];
    NSLog(urlString);
    NSDictionary *parameters = @{@"tweet_mode":@"extended"};
    
    [self GET:urlString
       parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray *  _Nullable tweetDictionaries) {
           // Success
           NSMutableArray *tweets  = [Tweet tweetsWithArray:tweetDictionaries];
           completion(tweets, nil);
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           // There was a problem
           completion(nil, error);
    }];
}

- (void)getUserTimelineWithUser:(User *)user completion:(void(^)(NSArray *tweets, NSError *error))completion {
    
    NSDictionary *parameters = @{@"tweet_mode":@"extended"};
    NSString *urlString = [NSString stringWithFormat: @"1.1/statuses/user_timeline.json?user_id=%@",user.idStr];
    [self GET:urlString
       parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray *  _Nullable tweetDictionaries) {
           // Success
           NSMutableArray *tweets  = [Tweet tweetsWithArray:tweetDictionaries];
           completion(tweets, nil);
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           // There was a problem
           completion(nil, error);
    }];
}

- (void)getRepliesWithTweet:(NSString *) idStr screenName:(NSString *)screenName completion:(void(^)(NSArray *tweets, NSError *error))completion {
    NSString *urlString = [NSString stringWithFormat: @"1.1/search/tweets.json?q=to:%@&since_id=%@",screenName,idStr];
    NSDictionary *parameters = @{@"tweet_mode":@"extended"};
    [self GET:urlString
       parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable statuses) {
           // Success
        NSArray *tweetDictionaries = statuses[@"statuses"];
        NSMutableArray *searchTweets  = [[Tweet tweetsWithArray:tweetDictionaries] mutableCopy];
        NSMutableArray *tweets = [[NSMutableArray alloc] init];
        for (Tweet *tweet in searchTweets){
            if (tweet.replyToTweetId != [NSNull null] && [tweet.replyToTweetId isEqualToString:idStr]){
                [tweets addObject:tweet];
            }
        }
        completion(tweets, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // There was a problem
        completion(nil, error);
    }];
}

- (void)getProfileWithCompletion:(void(^)(User *user, NSError *error))completion {
    
    [self GET:@"1.1/account/settings.json"
       parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDictionaries) {
           // Success
        NSString *screenName = tweetDictionaries[@"screen_name"];
        NSDictionary *parameters = @{@"tweet_mode":@"extended"};
        NSString *urlString = [NSString stringWithFormat: @"1.1/users/show.json?screen_name=%@",screenName];
        NSLog(urlString);
        [self GET:urlString
           parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable userDictionary) {
            User *user = [[User alloc] initWithDictionary:userDictionary];
               completion(user, nil);
           } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
               // There was a problem
               completion(nil, error);
        }];
        
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           // There was a problem
           completion(nil, error);
    }];
    
}

- (void)getAccountWithCompletion:(void(^)(NSArray *tweets, NSError *error))completion {
    
    [self GET:@"1.1/account/settings.json"
       parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDictionaries) {
           // Success
        NSString *screenName = tweetDictionaries[@"screen_name"];
        NSDictionary *parameters = @{@"tweet_mode":@"extended"};
        NSString *urlString = [NSString stringWithFormat: @"1.1/statuses/user_timeline.json?screen_name=%@",screenName];
        NSLog(urlString);
        [self GET:urlString
           parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray *  _Nullable tweetDictionaries) {
               // Success
               NSMutableArray *tweets  = [Tweet tweetsWithArray:tweetDictionaries];
               completion(tweets, nil);
           } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
               // There was a problem
               completion(nil, error);
        }];
        
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           // There was a problem
           completion(nil, error);
    }];
    
}

- (void)postStatusWithText:(NSString *)text completion:(void (^)(Tweet *, NSError *))completion{
    NSString *urlString = @"1.1/statuses/update.json";
    NSDictionary *parameters = @{@"status": text, @"tweet_mode":@"extended"};
    
    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDictionary) {
        Tweet *tweet = [[Tweet alloc]initWithDictionary:tweetDictionary];
        completion(tweet, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)postReplyWithText:(NSString *)text toTweet:(Tweet*) tweet completion:(void (^)(Tweet *, NSError *))completion{
    NSString *urlString = @"1.1/statuses/update.json";
    NSDictionary *parameters = @{@"status": text, @"in_reply_to_status_id":tweet.idStr ,@"tweet_mode":@"extended"};
    
    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDictionary) {
        Tweet *tweet = [[Tweet alloc]initWithDictionary:tweetDictionary];
        completion(tweet, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)favorite:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion{

    NSString *urlString = @"1.1/favorites/create.json";
    NSDictionary *parameters = @{@"id": tweet.idStr};
    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDictionary) {
        Tweet *tweet = [[Tweet alloc]initWithDictionary:tweetDictionary];
        completion(tweet, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)unfavorite:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion{

    NSString *urlString = @"1.1/favorites/destroy.json";
    NSDictionary *parameters = @{@"id": tweet.idStr};
    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDictionary) {
        Tweet *tweet = [[Tweet alloc]initWithDictionary:tweetDictionary];
        completion(tweet, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)retweet:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion{

    NSString *urlString = [NSString stringWithFormat:@"1.1/statuses/retweet/%@.json", tweet.idStr];
    NSDictionary *parameters = @{@"id": tweet.idStr};
    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDictionary) {
        Tweet *tweet = [[Tweet alloc]initWithDictionary:tweetDictionary];
        completion(tweet, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)unretweet:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion{

    NSString *urlString = [NSString stringWithFormat:@"1.1/statuses/unretweet/%@.json", tweet.idStr];
    NSDictionary *parameters = @{@"id": tweet.idStr};
    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDictionary) {
        Tweet *tweet = [[Tweet alloc]initWithDictionary:tweetDictionary];
        completion(tweet, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

//NSString *urlString = @"1.1/statuses/update.json";
//    NSDictionary *parameters = @{@"status": text, @"tweet_mode":@"extended"};
//
//    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDictionary) {
//        Tweet *tweet = [[Tweet alloc]initWithDictionary:tweetDictionary];
//        completion(tweet, nil);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        completion(nil, error);
//    }];

@end
