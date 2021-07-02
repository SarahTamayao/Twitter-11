//
//  PhotoViewController.m
//  twitter
//
//  Created by Pranitha Reddy Kona on 6/30/21.
//  Copyright © 2021 Emerson Malca. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *mediaView;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    float imageViewHeight = self.mediaView.frame.size.width/self.media.size.width * self.media.size.height;
    self.mediaView.frame = CGRectMake(0, 0, self.mediaView.frame.size.width, imageViewHeight);
    self.mediaView.image = self.media;
}

- (IBAction)didTap:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}


@end
