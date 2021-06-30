//
//  User.m
//  twitter
//
//  Created by Pranitha Reddy Kona on 6/28/21.
//  Copyright © 2021 Emerson Malca. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.idStr = dictionary[@"id_str"];
        self.name = dictionary[@"name"];
        self.screenName = dictionary[@"screen_name"];
        self.profilePicture = dictionary[@"profile_image_url_https"];
        self.profileBanner = dictionary[@"profile_banner_url"];
        self.bio = dictionary[@"description"];
        self.verified = dictionary[@"verified"];
        self.followers = dictionary[@"followers_count"];
        self.following = dictionary[@"friends_count"];
        
    }
    return self;
}

@end
