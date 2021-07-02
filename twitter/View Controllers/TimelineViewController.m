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
#import "UserViewController.h"
#import "DateTools.h"
#import "InfiniteScrollActivityView.h"
#import "UIImageView+AFNetworking.h"
#import "UIButton+AFNetworking.h"
#import "UIImage+AFNetworking.h"

@interface TimelineViewController () <TweetCellDelegate, ComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (strong, nonatomic) NSMutableArray *arrayOfTweets;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;


@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    
    [self.activityIndicator startAnimating];
    [self fetchTweets];
    [self fetchProfile];

    
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    self.tableView.contentInset = insets;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor colorWithRed:222 green:97 blue:86 alpha:1];
    self.refreshControl.backgroundColor = [UIColor blackColor];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    [self.refreshControl addTarget:self action:@selector(fetchTweets) forControlEvents:UIControlEventValueChanged];

}

-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
}


-(void) fetchTweets{
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            self.arrayOfTweets = tweets;
            [self.tableView reloadData];
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = true;
            [self.refreshControl endRefreshing];
            NSLog(@"%lu", (unsigned long)self.arrayOfTweets.count);
            NSLog(@"😎😎😎 Successfully loaded home timeline");
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
    }];
}

-(void) fetchProfile{
    [[APIManager shared] getProfileWithCompletion:^(User *user, NSError *error) {
        if (user) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:user.profilePicture forKey:@"profile_path"];
            [userDefaults synchronize];
            
            [[APIManager shared] getFollowersWithUser:user completion:^(NSArray *ids, NSError *error) {
                if (ids) {
                    [userDefaults setObject:ids forKey:@"following"];
                    [userDefaults synchronize];
                    NSLog(@"😎😎😎 Successfully loaded profile");
                } else {
                    NSLog(@"😫😫😫 Error getting profile", error.localizedDescription);
                }
            }];
            NSLog(@"😎😎😎 Successfully loaded profile");
        } else {
            NSLog(@"😫😫😫 Error getting profile", error.localizedDescription);
        }
    }];
}


- (void)didTweet:(Tweet *)tweet{
    [self.arrayOfTweets insertObject:tweet atIndex:0];
    NSLog(tweet.text);
    [self.tableView reloadData];
}

- (void)tweetCell:(TweetCell *)tweetCell didTap:(User *)user{
    [self performSegueWithIdentifier:@"HomeToUser" sender:user];
}

- (void)reply:(Tweet *)tweet{
    [self performSegueWithIdentifier:@"HomeToCompose" sender:tweet];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet *tweet = self.arrayOfTweets[indexPath.row];
    [self performSegueWithIdentifier:@"HomeToDetails" sender:tweet];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"HomeToCompose"]){
        UINavigationController *navigationController = [segue destinationViewController];
        ComposeViewController *composeController = (ComposeViewController*)navigationController.topViewController;
        composeController.delegate = self;
        if ([sender class] == [Tweet class]){
            composeController.tweet = sender;
        }
    }
    else if ([segue.identifier isEqualToString:@"HomeToUser"]) {
        User *user = sender;
        UserViewController *userViewController = [segue destinationViewController];
        userViewController.user = sender;
    }
    else if ([segue.identifier isEqualToString:@"HomeToDetails"]) {
        DetailsViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.tweet = sender;
    }
}



@end
