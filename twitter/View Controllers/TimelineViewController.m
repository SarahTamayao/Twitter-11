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

@interface TimelineViewController () <TweetCellDelegate, ComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (strong, nonatomic) NSMutableArray *arrayOfTweets;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (weak, nonatomic) InfiniteScrollActivityView* loadingMoreView;
@property (nonatomic) NSInteger dataCount;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.dataCount = 20;
    
    [self fetchTweets];
    
    
    CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
    self.loadingMoreView = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    self.loadingMoreView.hidden = true;
    [self.tableView addSubview:self.loadingMoreView];
    
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    self.tableView.contentInset = insets;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor colorWithRed:222 green:97 blue:86 alpha:1];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    [self.refreshControl addTarget:self action:@selector(fetchTweets) forControlEvents:UIControlEventValueChanged];
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
}

-(void) fetchTweets{
    // Get timeline
    [self.activityIndicator startAnimating];
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

- (void)didTweet:(Tweet *)tweet{
    [self.arrayOfTweets insertObject:tweet atIndex:0];
    [self.tableView reloadData];
}

- (void)tweetCell:(TweetCell *)tweetCell didTap:(User *)user{
    [self performSegueWithIdentifier:@"HomeToUser" sender:user];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row + 1 == self.dataCount){
        self.dataCount += 20;
        //[self loadMoreData];
    }
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if(!self.isMoreDataLoading){
//        int scrollViewContentHeight = self.tableView.contentSize.height;
//        int scrollOffsetThreshold = scrollViewContentHeight - self.tableView.bounds.size.height;
//
//        // When the user has scrolled past the threshold, start requesting
//        if(scrollView.contentOffset.y > scrollOffsetThreshold && self.tableView.isDragging) {
//            self.isMoreDataLoading = true;
//            [self loadMoreData];
//            self.isMoreDataLoading = false;
//          // ... Code to load more results ...
//
//       }
//    }
//}
     
- (void)loadMoreData{
    [self.loadingMoreView startAnimating];
    [[APIManager shared] getHomeTimelineWithCount:self.dataCount completion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            self.arrayOfTweets = tweets;
            [self.tableView reloadData];
            [self.activityIndicator stopAnimating];
            [self.refreshControl endRefreshing];
            self.isMoreDataLoading = false;
            NSLog(@"%lu", (unsigned long)self.arrayOfTweets.count);
            NSLog(@"load more😎😎😎 Successfully loaded home timeline");
        } else {
            NSLog(@"load more😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
    }];
    [self.loadingMoreView stopAnimating];
    self.isMoreDataLoading = false;
    [self.tableView reloadData];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"HomeToCompose"]){
        UINavigationController *navigationController = [segue destinationViewController];
        ComposeViewController *composeController = (ComposeViewController*)navigationController.topViewController;
        composeController.delegate = self;
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
