//
//  APIManager.h
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "BDBOAuth1SessionManager.h"
#import "BDBOAuth1SessionManager+SFAuthenticationSession.h"
#import "Tweet.h"

@interface APIManager : BDBOAuth1SessionManager

+ (instancetype)shared;

- (void)getHomeTimelineWithCompletion:(void(^)(NSArray *tweets, NSError *error))completion;
- (void)getHomeTimelineWithCount:(NSInteger)count completion:(void(^)(NSArray *tweets, NSError *error))completion;
- (void)getUserTimelineWithUser:(User *)user completion:(void(^)(NSArray *tweets, NSError *error))completion;
- (void)getRepliesWithTweet:(NSString *) idStr screenName:(NSString *)screenName completion:(void(^)(NSArray *tweets, NSError *error))completion;
- (void)getProfileWithCompletion:(void(^)(User *user, NSError *error))completion;
- (void)getAccountWithCompletion:(void(^)(NSArray *tweets, NSError *error))completion;
- (void)postStatusWithText:(NSString *)text completion:(void (^)(Tweet *, NSError *))completion;
- (void)postReplyWithText:(NSString *)text toTweet:(Tweet*) tweet completion:(void (^)(Tweet *, NSError *))completion;
- (void)favorite:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion;
- (void)unfavorite:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion;
- (void)retweet:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion;
- (void)unretweet:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion;

@end
