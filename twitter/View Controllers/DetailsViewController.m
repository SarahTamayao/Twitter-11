//
//  DetailsViewController.m
//  twitter
//
//  Created by Pranitha Reddy Kona on 6/28/21.
//  Copyright © 2021 Emerson Malca. All rights reserved.
//

#import "DetailsViewController.h"
#import "PhotoViewController.h"
#import "UserViewController.h"
#import "ComposeViewController.h"
#import "APIManager.h"
#import "DateTools.h"
#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"

@interface DetailsViewController () <ComposeViewControllerDelegate, TweetCellDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *profileView;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTagLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UILabel *retweetsLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *tweetView;
@property(nonatomic) NSMutableArray *arrayOfTweets;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *mediaView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentBottomConstraint;
@property (strong, nonatomic) UIImage *media;
@property (weak, nonatomic) IBOutlet UIImageView *bottomBarView;


@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self fetchReplies];
    
    NSString *URLString = self.tweet.user.profilePicture;
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
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
    [self.contentLabel layoutIfNeeded];
    self.retweetsLabel.text = [NSString stringWithFormat:@"%d Retweets  %d Replies  %d Likes", self.tweet.retweetCount, self.arrayOfTweets.count, self.tweet.favoriteCount];
    if (self.tweet.retweeted){
        [self.retweetButton setTintColor: [UIColor greenColor]];
    }
    if (self.tweet.favorited){
        [self.favoriteButton setTintColor: [UIColor redColor]];
    }
    
    self.mediaView.layer.cornerRadius = 15;
    
    if (self.tweet.media){
        self.mediaView.hidden = false;
        self.mediaBottomConstraint.priority = UILayoutPriorityDefaultHigh;
        self.contentBottomConstraint.priority = UILayoutPriorityDefaultLow;
        NSURL *mediaUrl = [NSURL URLWithString:self.tweet.media[0][@"media_url_https"]];
        [self.mediaView setImageWithURL:mediaUrl];
        self.media = self.mediaView.image;

//        NSObject *index =  tweet.media[0][@"indices"][0];
//        self.contentLabel.text = [tweet.text substringToIndex: index];
    }
    else{
        self.mediaBottomConstraint.priority = UILayoutPriorityDefaultLow;
        self.contentBottomConstraint.priority = UILayoutPriorityDefaultHigh;
        self.mediaView.hidden = true;
    }
    
    [self.tweetView setNeedsLayout];
    [self.tweetView layoutIfNeeded];
    [self.tweetView sizeToFit];
    
    float fw = self.bottomBarView.frame.origin.x + self.bottomBarView.frame.size.width;
    float fh = self.bottomBarView.frame.origin.y + self.bottomBarView.frame.size.height;
    [self.tweetView setFrame:CGRectMake(self.tweetView.frame.origin.x, self.tweetView.frame.origin.y, fw, fh)];
    
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
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TweetCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }

    Tweet *tweet = self.arrayOfTweets[indexPath.row];
    [cell setCellWithTweet:tweet];
    cell.delegate = self;
    
    return cell;
}

- (void)tweetCell:(TweetCell *)tweetCell didTap:(User *)user{
    [self performSegueWithIdentifier:@"DetailsCellToUser" sender:user];
}

- (void)reply:(nonnull Tweet *)tweet {
    [self performSegueWithIdentifier:@"DetailsCellToCompose" sender:tweet];
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
        [self.retweetButton setTintColor: [UIColor greenColor]];
    }
    else{
        [self.retweetButton setTintColor: [UIColor lightGrayColor]];
        
    }
    if (self.tweet.favorited){
        [self.favoriteButton setTintColor: [UIColor redColor]];
    }
    else{
        [self.favoriteButton setTintColor: [UIColor lightGrayColor]];
    }
    
}

#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual: @"DetailsToCompose"]){
        UINavigationController *navigationController = [segue destinationViewController];
        ComposeViewController *composeViewController = (ComposeViewController*)navigationController.topViewController;
        composeViewController.delegate = self;
        composeViewController.tweet = self.tweet;
    }
    else if ([segue.identifier isEqual: @"DetailsCellToCompose"]){
        UINavigationController *navigationController = [segue destinationViewController];
        ComposeViewController *composeViewController = (ComposeViewController*)navigationController.topViewController;
        composeViewController.delegate = self;
        composeViewController.tweet = sender;
    }
    else if ([segue.identifier isEqual: @"DetailsToPhoto"]){
        PhotoViewController *photoViewController = [segue destinationViewController];
        photoViewController.media = self.media;
    }
    else if ([segue.identifier isEqual: @"DetailsToUser"]){
        UserViewController *userViewController = [segue destinationViewController];
        userViewController.user = self.tweet.user;
    }
    else if ([segue.identifier isEqual: @"DetailsCellToUser"]){
        UserViewController *userViewController = [segue destinationViewController];
        userViewController.user = sender;
    }
}


- (void)didTweet:(nonnull Tweet *)tweet {
    [self.arrayOfTweets insertObject:tweet atIndex:0];
    [self.tableView reloadData];
}




@end
