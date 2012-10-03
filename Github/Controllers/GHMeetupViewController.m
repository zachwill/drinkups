//
//  GHMeetupViewController.m
//  Github
//
//  Created by Zach Williams on 9/30/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "GHMeetupViewController.h"
#import <Social/Social.h>
#import "Bar.h"

@interface GHMeetupViewController ()

@property (strong, nonatomic) NSNumber *canSendTweets;

@end


static const float kToolbarFixedWidthSpacing = 4.0f;


@implementation GHMeetupViewController

- (id)initWithDrinkup:(Drinkup *)drinkup {
    self = [super initWithNibName:@"GHMeetup" bundle:nil];
    if (!self) {
        return nil;
    }
    _drinkup = drinkup;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:@"eee"];
    [self addToolbarButtons];
}

#pragma mark - UIToolbar Buttons and Actions

- (void)addToolbarButtons {
    UIBarButtonItem *tweet = [[UIBarButtonItem alloc] initWithTitle:@"Tweet"
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(createTweet:)];
    UIBarButtonItem *reminder = [[UIBarButtonItem alloc] initWithTitle:@"Reminder"
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(createReminder:)];
    self.toolbar.items = @[reminder, tweet];
    [self checkAbilityToTweet];
}

- (void)checkAbilityToTweet {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        self.canSendTweets = @YES;
    }
}

- (void)createReminder:(id)sender {
    
}

- (void)createTweet:(id)sender {
    if (self.canSendTweets) {
        __block id viewController = self;
        SLComposeViewController *tweetVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetVC addURL:[NSURL URLWithString:self.drinkup.blog]];
        [tweetVC setInitialText:[NSString stringWithFormat:@"%@ drinkup", self.drinkup.bar.name]];
        [tweetVC setCompletionHandler:^(SLComposeViewControllerResult result) {
            if (result == SLComposeViewControllerResultDone) {
                // Otherwise the screen freezes?
                [viewController dismissViewControllerAnimated:YES completion:^{
                    NSLog(@"Tweet, tweet.");
                }];
            } else {
                [viewController dismissViewControllerAnimated:YES completion:^{
                    NSLog(@"Dismissed.");
                }];
            }
        }];
        [self presentViewController:tweetVC animated:YES completion:nil];
    }
}

@end
