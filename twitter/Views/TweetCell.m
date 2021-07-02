//
//  TweetCell.m
//  twitter
//
//  Created by Pranitha Reddy Kona on 6/28/21.
//  Copyright © 2021 Emerson Malca. All rights reserved.
//

#import "TweetCell.h"
#import "APIManager.h"
#import "User.h"
#import "UserViewController.h"
#import "DateTools.h"
#import "UIImageView+AFNetworking.h"

@implementation TweetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profileImageView addGestureRecognizer:profileTapGestureRecognizer];
    [self.profileImageView setUserInteractionEnabled:YES];
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.width / 2;
    self.mediaView.layer.cornerRadius = 15;
    self.cardView.layer.cornerRadius = 15;

}

- (void) setCellWithTweet:(Tweet *)tweet{
    self.tweet = tweet;
    NSString *URLString = tweet.user.profilePicture;
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];

    self.profileImageView.image = [UIImage imageWithData:urlData];
    self.userLabel.text = tweet.user.name;
    self.userTagLabel.text = [NSString stringWithFormat:@"@%@ · %@", tweet.user.screenName, tweet.createdAtString];

    [self.retweetButton setTitle:[NSString stringWithFormat: @"%d", tweet.retweetCount] forState:UIControlStateNormal];
    if (tweet.retweeted){
        [self.retweetButton setTintColor: [UIColor greenColor]];
    }
    [self.favoriteButton setTitle:[NSString stringWithFormat: @"%d", tweet.favoriteCount] forState:UIControlStateNormal];
    if (tweet.favorited){
        [self.favoriteButton setTintColor: [UIColor redColor]];
    }

    [self.contentLabel setText: tweet.text];
    [self.contentLabel layoutIfNeeded];
    
    if (tweet.media){
        self.mediaView.hidden = false;
        self.mediaViewBottomConstraintt.priority = UILayoutPriorityDefaultHigh;
        self.contentBottomConstraint.priority = UILayoutPriorityDefaultLow;
        NSURL *mediaUrl = [NSURL URLWithString:tweet.media[0][@"media_url_https"]];
        [self.mediaView setImageWithURL:mediaUrl];
    }
    else{
        self.mediaViewBottomConstraintt.priority = UILayoutPriorityDefaultLow;
        self.contentBottomConstraint.priority = UILayoutPriorityDefaultHigh;
        self.mediaView.hidden = true;
    }
}

- (IBAction)didTapFavorite:(id)sender {
    self.tweet.favorited = !self.tweet.favorited;
    if (self.tweet.favorited){
        self.tweet.favoriteCount += 1;
        [[APIManager shared] favorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
             if(error){
                  NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
             } else{
                 NSLog(@"Successfully favorited the following Tweet: %@", tweet.text);
             }
         }];
    } else{
        self.tweet.favoriteCount -= 1;
        [[APIManager shared] unfavorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
             if(error){
                  NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
             } else{
                 NSLog(@"Successfully unfavorited the following Tweet: %@", tweet.text);
             }
         }];
    }
    [self refreshData];
}

-(IBAction)didTapRetweet:(id)sender {
   self.tweet.retweeted = !self.tweet.retweeted;
   if (self.tweet.retweeted){
       self.tweet.retweetCount += 1;
       [[APIManager shared] retweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                 NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
            } else{
                NSLog(@"Successfully retweeted the following Tweet: %@", tweet.text);
            }
        }];
   } else{
       self.tweet.retweetCount -= 1;
       [[APIManager shared] unretweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                 NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
            } else{
                NSLog(@"Successfully unretweeted the following Tweet: %@", tweet.text);
            }
        }];
   }
   [self refreshData];
}


-(void)refreshData{
    [self.retweetButton setTitle:[NSString stringWithFormat: @"%d", self.tweet.retweetCount] forState:UIControlStateNormal];
    if (self.tweet.retweeted){
        [self.retweetButton setTintColor: [UIColor greenColor]];
    } else{
        [self.retweetButton setTintColor: [UIColor lightGrayColor]];
        
    }
    
    [self.favoriteButton setTitle:[NSString stringWithFormat: @"%d", self.tweet.favoriteCount] forState:UIControlStateNormal];
    if (self.tweet.favorited){
        [self.favoriteButton setTintColor: [UIColor redColor]];
    } else{
        [self.favoriteButton setTintColor: [UIColor lightGrayColor]];
    }
}

- (void) didTapUserProfile:(UITapGestureRecognizer *)sender{
    [self.delegate tweetCell:self didTap:self.tweet.user];
}


- (IBAction)didTapReply:(id)sender {
    [self.delegate reply:self.tweet];
}


@end
