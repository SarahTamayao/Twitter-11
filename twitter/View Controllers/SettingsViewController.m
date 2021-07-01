//
//  SettingsViewController.m
//  twitter
//
//  Created by Pranitha Reddy Kona on 7/1/21.
//  Copyright © 2021 Emerson Malca. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *themeControl;
@property (weak, nonatomic) IBOutlet UILabel *themeLabel;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)themeChanged:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"theme"] == nil){
        [userDefaults setObject:@"light" forKey:@"theme"];
    }
    else if ([[userDefaults objectForKey:@"theme"] isEqual:@"light"]){
        [userDefaults setObject:@"dark" forKey:@"theme"];
    }
    else{
        [userDefaults setObject:@"light" forKey:@"theme"];
    }
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
