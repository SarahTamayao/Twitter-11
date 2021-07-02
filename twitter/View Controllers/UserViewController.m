//
//  UserViewController.m
//  twitter
//
//  Created by Pranitha Reddy Kona on 6/29/21.
//  Copyright © 2021 Emerson Malca. All rights reserved.
//

#import "UserViewController.h"
#import "APIManager.h"
#import "TweetCell.h"
#import "Tweet.h"
#import "DateTools.h"
#import "UIImageView+AFNetworking.h"
#import "GSKStretchyHeaderView.h"


@interface UserViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTagLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *bottomBarView;
@property (weak, nonatomic) IBOutlet UIView *userView;
@property (weak, nonatomic) GSKStretchyHeaderView *stretchyHeader;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *unfollowButton;
@property (weak, nonatomic) IBOutlet UIView *cardView;

@property (nonatomic) BOOL followed;
@property (strong, nonatomic) NSArray *arrayOfTweets;
@property (strong, nonatomic) NSArray *arrayOfUserTweets;
@property (strong, nonatomic) NSArray *arrayOfUserTweetsReplies;
@property (strong, nonatomic) NSArray *arrayOfUserLikes;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource =self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self fetchTweets];
    [self fetchLikes];

    self.cardView.layer.cornerRadius = 15;
    self.nameLabel.text = self.user.name;
    self.userTagLabel.text = [NSString stringWithFormat:@"@%@", self.user.screenName];
    self.bioLabel.text = self.user.bio;
    self.followersLabel.text = [NSString stringWithFormat: @"%@ followers  %@ following", self.user.followers, self.user.following];

    self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.width /2;
    [self.profileImageView setImageWithURL:[NSURL URLWithString: self.user.profilePicture]];
    [self.backdropView setImageWithURL:[NSURL URLWithString: self.user.profileBanner]];
    
    [self.userView setNeedsLayout];
    [self.userView layoutIfNeeded];
    [self.userView sizeToFit];
    
    float fw = self.bottomBarView.frame.origin.x + self.bottomBarView.frame.size.width;
    float fh = self.bottomBarView.frame.origin.y + self.bottomBarView.frame.size.height;
    [self.userView setFrame:CGRectMake(self.userView.frame.origin.x, self.userView.frame.origin.y, fw, fh)];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *following = [userDefaults objectForKey:@"following"];
    
    self.followButton.layer.cornerRadius = 10;
    self.unfollowButton.layer.cornerRadius = 10;
    if ([following containsObject:self.user.idStr]){
        self.followButton.hidden = true;
        self.unfollowButton.hidden = false;
    }
    
}

-(void) fetchTweets{
    // Get timeline
    [self.activityIndicator startAnimating];
    [[APIManager shared] getUserTimelineWithUser:self.user completion:^(NSArray *tweets, NSArray *tweetsReplies, NSError *error) {
        if (tweets) {
            self.arrayOfUserTweets = tweets;
            self.arrayOfTweets = tweets;
            self.arrayOfUserTweetsReplies = tweetsReplies;
            [self.tableView reloadData];
            [self.activityIndicator stopAnimating];
            NSLog(@"😎😎😎 Successfully loaded user timeline");
        } else {
            NSLog(@"😫😫😫 Error getting user timeline: %@", error.localizedDescription);
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
    else if (self.segmentControl.selectedSegmentIndex == 1){
        self.arrayOfTweets = self.arrayOfUserTweetsReplies;
    }
    else {
        self.arrayOfTweets = self.arrayOfUserLikes;
    }
    [self.tableView reloadData];
}

- (IBAction)clickFollow:(id)sender {
    self.followButton.hidden = true;
    self.unfollowButton.hidden = false;
    [[APIManager shared] follow:self.user completion:^(User *user, NSError *error) {
        if (user) {
            NSLog(@"😎😎😎 Successfully followed user");
        } else {
            NSLog(@"😫😫😫 Error following user: %@", error.localizedDescription);
        }
    }];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *following = [[userDefaults objectForKey:@"following"] mutableCopy];
    [following addObject:self.user.idStr];
    [userDefaults setObject:following forKey:@"following"];
    [userDefaults synchronize];
}

- (IBAction)clickUnfollow:(id)sender {
    self.followButton.hidden = false;
    self.unfollowButton.hidden = true;
    [[APIManager shared] unfollow:self.user completion:^(User *user, NSError *error) {
        if (user) {
            NSLog(@"😎😎😎 Successfully unfollowed user");
        } else {
            NSLog(@"😫😫😫 Error unfollowing user: %@", error.localizedDescription);
        }
    }];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *following = [[userDefaults objectForKey:@"following"] mutableCopy];
    [following removeObject:self.user.idStr];
    [userDefaults setObject:following forKey:@"following"];
    [userDefaults synchronize];
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
