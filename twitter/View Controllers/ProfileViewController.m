//
//  ProfileViewController.m
//  twitter
//
//  Created by Pranitha Reddy Kona on 6/30/21.
//  Copyright © 2021 Emerson Malca. All rights reserved.
//

#import "ProfileViewController.h"
#import "User.h"
#import "APIManager.h"
#import "TweetCell.h"
#import "Tweet.h"
#import "DateTools.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "UIImageView+AFNetworking.h"

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTagLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIView *cardView;

@property (strong, nonatomic) NSArray *arrayOfTweets;
@property (strong, nonatomic) NSArray *arrayOfUserTweets;
@property (strong, nonatomic) NSArray *arrayOfUserLikes;
@property (strong, nonatomic) User *user;

@end

@implementation ProfileViewController 


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource =self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.cardView.layer.cornerRadius = 15;
    
    [self fetchTweets];
    [self refreshData];
}

-(void) fetchTweets{
    [self.activityIndicator startAnimating];
    
    [[APIManager shared] getAccountWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            self.arrayOfTweets = tweets;
            self.arrayOfUserTweets = tweets;
            
            Tweet *tweet = self.arrayOfTweets[0];
            self.user = tweet.user;
            
            [self.tableView reloadData];
            [self refreshData];
            [self.activityIndicator stopAnimating];
            
            NSLog(@"😎😎😎 Successfully loaded account");
        } else {
            NSLog(@"😫😫😫 Error getting account: %@", error.localizedDescription);
        }
    }];
    
}

-(void) fetchLikes{
    [self.activityIndicator startAnimating];
    [[APIManager shared] getLikesWithUser:self.user completion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            self.arrayOfUserLikes = tweets;
            
            [self.tableView reloadData];
            [self.activityIndicator stopAnimating];
            
            NSLog(@"😎😎😎 Successfully loaded likes");
        } else {
            NSLog(@"😫😫😫 Error getting likes: %@", error.localizedDescription);
        }
    }];
}

-(void)refreshData{
    self.nameLabel.text = self.user.name;
    self.userTagLabel.text = [NSString stringWithFormat:@"@%@", self.user.screenName];
    self.bioLabel.text = self.user.bio;
    self.followersLabel.text = [NSString stringWithFormat: @"%@ followers  %@ following", self.user.followers, self.user.following];
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.width /2;
    [self.profileImageView setImageWithURL: [NSURL URLWithString: self.user.profilePicture]];
    [self.backdropView setImageWithURL:[NSURL URLWithString: self.user.profileBanner]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return MIN(20, self.arrayOfTweets.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    
    if (cell == nil) {
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TweetCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    Tweet *tweet = self.arrayOfTweets[indexPath.row];
    [cell setCellWithTweet:tweet];
    
    return cell;
    
}

- (IBAction)controlChange:(id)sender {
    if (self.segmentControl.selectedSegmentIndex == 0){
        self.arrayOfTweets = self.arrayOfUserTweets;
    }
    else {
        self.arrayOfTweets = self.arrayOfUserLikes;
    }
    [self.tableView reloadData];
}

- (IBAction)userLogout:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    [[APIManager shared] logout];
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
