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


@interface UserViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTagLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *arrayOfTweets;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *bottomBarView;
@property (weak, nonatomic) IBOutlet UIView *userView;


@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource =self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self fetchTweets];
    
//    self.headerView = [[GSKStretchyHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.userView.frame.size.width, 200)];
//    //self.headerView.stretchDelegate = self.tableView;
//    [self.backdropView setImageWithURL:[NSURL URLWithString: self.user.profileBanner]];
//    [self.headerView setScalesLargeContentImage:self.backdropView.image];
//    [self.headerView addSubview:self.backdropView];
    
    
//    NSString *profileUrlString = self.user.profilePicture;
//    NSURL *profileUrl = [NSURL URLWithString:profileUrlString];
//    NSData *profileUrlData = [NSData dataWithContentsOfURL:profileUrl];
//
//    NSString *backdropUrlString = self.user.profileBanner;
//    NSURL *backdropUrl = [NSURL URLWithString:backdropUrlString];
//    NSData *backdropUrlData = [NSData dataWithContentsOfURL:backdropUrl];
    
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
    
}

-(void) fetchTweets{
    // Get timeline
    [self.activityIndicator startAnimating];
    [[APIManager shared] getUserTimelineWithUser:self.user completion:^(NSArray *tweets, NSError *error) { 
        if (tweets) {
            self.arrayOfTweets = tweets;
            [self.tableView reloadData];
            [self.activityIndicator stopAnimating];
            NSLog(@"😎😎😎 Successfully loaded home timeline");
//            for (NSDictionary *dictionary in tweets) {
//                NSString *text = dictionary[@"text"];
//                NSLog(@"%@", text);
//            }
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
