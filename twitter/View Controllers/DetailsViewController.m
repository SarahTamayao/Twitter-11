//
//  DetailsViewController.m
//  twitter
//
//  Created by Pranitha Reddy Kona on 6/28/21.
//  Copyright © 2021 Emerson Malca. All rights reserved.
//

#import "DetailsViewController.h"
#import "APIManager.h"
#import "DateTools.h"
#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"

@interface DetailsViewController () <TweetCellDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *profileView;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTagLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UILabel *retweetsLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *tweetView;
@property(nonatomic) NSArray *arrayOfTweets;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *mediaView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentBottomConstraint;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = self.tweetView;
    
    [self fetchReplies];
    
    NSString *URLString = self.tweet.user.profilePicture;
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
   // NSLog(@"%@", self.tweet);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    NSDate *date = [formatter dateFromString:self.tweet.createdAtUnformattedString];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    NSString *dateString = [formatter stringFromDate:date];

    formatter.dateStyle = NSDateFormatterNoStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    NSString *timeString = [formatter stringFromDate:date];
    
    self.profileView.layer.cornerRadius = self.profileView.bounds.size.width /2;
    self.profileView.image = [UIImage imageWithData:urlData];
    self.userLabel.text = self.tweet.user.name;
    self.userTagLabel.text = [NSString stringWithFormat: @"@%@",self.tweet.user.screenName];
    self.dateLabel.text = [NSString stringWithFormat:@"%@ · %@", timeString, dateString];
    self.contentLabel.text = self.tweet.text;
    self.retweetsLabel.text = [NSString stringWithFormat:@"%d Retweets  %d Replies  %d Likes", self.tweet.retweetCount, self.arrayOfTweets.count, self.tweet.favoriteCount];
    if (self.tweet.retweeted){
        [self.retweetButton setImage: [UIImage imageNamed:@"retweet-icon-green"] forState:UIControlStateNormal];
    }
    if (self.tweet.favorited){
        [self.favoriteButton setImage: [UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateNormal];
    }
    
    self.mediaView.layer.cornerRadius = 15;
    
    if (self.tweet.media){
        self.mediaView.hidden = false;
        self.mediaBottomConstraint.priority = UILayoutPriorityDefaultHigh;
        self.contentBottomConstraint.priority = UILayoutPriorityDefaultLow;
        NSURL *mediaUrl = [NSURL URLWithString:self.tweet.media[0][@"media_url_https"]];
        [self.mediaView setImageWithURL:mediaUrl];
//        NSObject *index =  tweet.media[0][@"indices"][0];
//        self.contentLabel.text = [tweet.text substringToIndex: index];
    }
    else{
        self.mediaBottomConstraint.priority = UILayoutPriorityDefaultLow;
        self.contentBottomConstraint.priority = UILayoutPriorityDefaultHigh;
        self.mediaView.hidden = true;
    }
    
}

-(void) fetchReplies{
    // Get timeline
    [self.activityIndicator startAnimating];
    [[APIManager shared] getRepliesWithTweet:self.tweet.idStr screenName:self.tweet.user.screenName completion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            self.arrayOfTweets = tweets;
            [self.tableView reloadData];
            [self.activityIndicator stopAnimating];
            [self refreshData];
            NSLog(@"%lu", (unsigned long)self.arrayOfTweets.count);
            NSLog(@"😎😎😎 Successfully loaded replies");
        } else {
            NSLog(@"😫😫😫 Error getting replies: %@", error.localizedDescription);
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayOfTweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    
    if (cell == nil) {
            // Load the top-level objects from the custom cell XIB.
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TweetCell" owner:self options:nil];
            // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
            cell = [topLevelObjects objectAtIndex:0];
        }
    //NSLog(@"%ld", (long)indexPath.row);
    Tweet *tweet = self.arrayOfTweets[indexPath.row];
    [cell setCellWithTweet:tweet];
    cell.delegate = self;
    
    return cell;
}

- (void)tweetCell:(TweetCell *)tweetCell didTap:(User *)user{
    [self performSegueWithIdentifier:@"HomeToUser" sender:user];
}

- (IBAction)didTapFavorite:(id)sender {
    self.tweet.favorited = !self.tweet.favorited;
    if (self.tweet.favorited){
        self.tweet.favoriteCount += 1;
        [[APIManager shared] favorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
             if(error){
                  NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
             }
             else{
                 NSLog(@"Successfully favorited the following Tweet: %@", tweet.text);
             }
         }];
    }
    else{
        self.tweet.favoriteCount -= 1;
        [[APIManager shared] unfavorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
             if(error){
                  NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
             }
             else{
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
            }
            else{
                NSLog(@"Successfully retweeted the following Tweet: %@", tweet.text);
            }
        }];
   }
   else{
       self.tweet.retweetCount -= 1;
       [[APIManager shared] unretweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                 NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
            }
            else{
                NSLog(@"Successfully unretweeted the following Tweet: %@", tweet.text);
            }
        }];
   }
   [self refreshData];
}


-(void)refreshData{
    self.retweetsLabel.text = [NSString stringWithFormat:@"%d Retweets  %d Replies  %d Likes", self.tweet.retweetCount, self.arrayOfTweets.count, self.tweet.favoriteCount];
    if (self.tweet.retweeted){
        [self.retweetButton setImage: [UIImage imageNamed:@"retweet-icon-green"] forState:UIControlStateNormal];
    }
    else{
        [self.retweetButton setImage: [UIImage imageNamed:@"retweet-icon"] forState:UIControlStateNormal];
    }
    if (self.tweet.favorited){
        [self.favoriteButton setImage: [UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateNormal];
    }
    else{
        [self.favoriteButton setImage: [UIImage imageNamed:@"favor-icon"] forState:UIControlStateNormal];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
