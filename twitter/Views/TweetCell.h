//
//  TweetCell.h
//  twitter
//
//  Created by Pranitha Reddy Kona on 6/28/21.
//  Copyright © 2021 Emerson Malca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"


NS_ASSUME_NONNULL_BEGIN
@protocol TweetCellDelegate;

@interface TweetCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTagLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentLabel;

@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIImageView *tweetImageView;
@property (weak, nonatomic) IBOutlet UIImageView *mediaView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaViewBottomConstraintt;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *cardView;


@property (nonatomic, weak) id<TweetCellDelegate> delegate;
@property (weak, nonatomic) Tweet *tweet;

- (void) setCellWithTweet:(Tweet *)tweet;

@end

@protocol TweetCellDelegate
- (void)tweetCell:(TweetCell *) tweetCell didTap: (User *)user;
- (void)reply: (Tweet *) tweet;
@end

NS_ASSUME_NONNULL_END
