//
//  ComposeViewController.m
//  twitter
//
//  Created by Pranitha Reddy Kona on 6/28/21.
//  Copyright © 2021 Emerson Malca. All rights reserved.
//

#import "ComposeViewController.h"
#import "APIManager.h"

@interface ComposeViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UIToolbar *keyboardToolbar;
@property (weak, nonatomic) UILabel *characterCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *characterCountButton;


@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tweetTextView.delegate = self;
    
    self.tweetTextView.inputAccessoryView = self.keyboardToolbar;
    self.keyboardToolbar.layer.cornerRadius = 5;
    self.tweetButton.layer.cornerRadius = 10;
}

- (void)viewDidAppear:(BOOL)animated{
    [self.tweetTextView becomeFirstResponder];
}

- (IBAction)closeCompose:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)sendTweet:(id)sender {
    [[APIManager shared] postStatusWithText:self.tweetTextView.text completion:^(Tweet *tweet, NSError *error) {
        if(error){
            NSLog(@"Error composing Tweet: %@", error.localizedDescription);
        }
        else{
            [self.delegate didTweet:tweet];
            [self dismissViewControllerAnimated:true completion:nil];
            NSLog(@"Compose Tweet Success!");
        }
    }];
    
}

- (void)textViewDidChange:(UITextView *)textView{
    NSLog(@"hello");
    [self.characterCountButton setTitle:[NSString stringWithFormat:@"%lu/280",(unsigned long)self.tweetTextView.text.length] forState:UIControlStateNormal];
    if (self.tweetTextView.text.length > 280){
        self.characterCountButton.titleLabel.textColor = [UIColor redColor];
        self.tweetButton.enabled = false;
    }
    else{
        self.characterCountButton.titleLabel.textColor = [UIColor blueColor];
        self.tweetButton.enabled = true;
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
