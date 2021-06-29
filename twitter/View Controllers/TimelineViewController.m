//
//  TimelineViewController.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "TimelineViewController.h"
#import "APIManager.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "TweetCell.h"
#import "Tweet.h"
#import "ComposeViewController.h"
#import "DetailsViewController.h"
#import "DateTools.h"

@interface TimelineViewController () <ComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray *arrayOfTweets;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self fetchTweets];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor colorWithRed:222 green:97 blue:86 alpha:1];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    [self.refreshControl addTarget:self action:@selector(fetchTweets) forControlEvents:UIControlEventValueChanged];
    
    
}

-(void) fetchTweets{
    // Get timeline
    [self.activityIndicator startAnimating];
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            self.arrayOfTweets = tweets;
            [self.tableView reloadData];
            [self.activityIndicator stopAnimating];
            [self.refreshControl endRefreshing];
            NSLog(@"😎😎😎 Successfully loaded home timeline");
            NSLog(@"%@", tweets[0]);
//            for (NSDictionary *dictionary in tweets) {
//                NSString *text = dictionary[@"text"];
//                NSLog(@"%@", text);
//            }
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)userLogout:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    [[APIManager shared] logout];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    
    Tweet *tweet = self.arrayOfTweets[indexPath.row];
    cell.tweet = tweet;

    NSString *URLString = tweet.user.profilePicture;
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    NSDate *date = [formatter dateFromString:tweet.createdAtString];
    
    NSString *dateString;
    //if (date) NSLog(@"%@", [date daysFrom:[NSDate now]]);
    if (@available(iOS 13.0, *)) {
        if ([date daysFrom:[NSDate now]] > 6){
            formatter.dateStyle = NSDateFormatterShortStyle;
            formatter.timeStyle = NSDateFormatterNoStyle;
            dateString = [formatter stringFromDate:date];
        }
        else{
            dateString = [date shortTimeAgoSinceNow];
        }
    } else {
        // Fallback on earlier versions
    }
    
    cell.profileImageView.layer.cornerRadius = cell.profileImageView.bounds.size.width / 2;
    cell.profileImageView.image = [UIImage imageWithData:urlData];
    cell.userLabel.text = tweet.user.name;
    cell.userTagLabel.text = [NSString stringWithFormat:@"@%@ · %@", tweet.user.screenName, dateString];
    cell.contentLabel.text = tweet.text;
    [cell.retweetButton setTitle:[NSString stringWithFormat: @"%d", tweet.retweetCount] forState:UIControlStateNormal];
    if (tweet.retweeted){
        [cell.retweetButton setImage: [UIImage imageNamed:@"retweet-icon-green"] forState:UIControlStateNormal];
    }
    [cell.favoriteButton setTitle:[NSString stringWithFormat: @"%d", tweet.favoriteCount] forState:UIControlStateNormal];
    if (tweet.favorited){
        [cell.favoriteButton setImage: [UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateNormal];
    }
    
    return cell;
}

- (void)didTweet:(Tweet *)tweet{
    [self.arrayOfTweets addObject:tweet];
    [self.tableView reloadData];
}





#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] class] == [UINavigationController class]){
        UINavigationController *navigationController = [segue destinationViewController];
        ComposeViewController *composeController = (ComposeViewController*)navigationController.topViewController;
        composeController.delegate = self;
    }
    else if ([[segue destinationViewController] class] == [DetailsViewController class]) {
        DetailsViewController *detailsViewController = [segue destinationViewController];
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        detailsViewController.tweet = self.arrayOfTweets[indexPath.row];
    }
}



@end
