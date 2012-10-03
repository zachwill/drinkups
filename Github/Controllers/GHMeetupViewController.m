//
//  GHMeetupViewController.m
//  Github
//
//  Created by Zach Williams on 9/30/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "GHMeetupViewController.h"
#import <Social/Social.h>
#import <EventKit/EventKit.h>
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
    [[EKEventStore alloc] requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        EKReminder *reminder = [EKReminder reminderWithEventStore:eventStore];
        NSString *bar = self.drinkup.bar.name;
        reminder.title = [NSString stringWithFormat:@"Github Drinkup at %@", bar];
        reminder.location = bar;
        reminder.calendar = [eventStore defaultCalendarForNewReminders];

        NSDateComponents *components = [self reminderComponents];
        reminder.startDateComponents = components;
        NSDate *dateToRemind = [[NSCalendar currentCalendar] dateFromComponents:components];
        [reminder addAlarm:[EKAlarm alarmWithAbsoluteDate:dateToRemind]];

        // TODO: Check and see if reminder already exists.
        NSError *reminderError;
        [eventStore saveReminder:reminder commit:YES error:&reminderError];
        if (reminderError) {
            NSLog(@"Error saving reminder: %@", reminderError);
        }
    }];
}

- (NSDateComponents *)reminderComponents {
    unsigned options = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:options fromDate:self.drinkup.date];
    // Default hour set to noon.
    components.hour = 12;
    return components;
}

- (void)createTweet:(id)sender {
    if (self.canSendTweets) {
        __block id viewController = self;
        SLComposeViewController *tweetVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetVC addURL:[NSURL URLWithString:self.drinkup.blog]];
        [tweetVC setInitialText:[NSString stringWithFormat:@"%@ drinkup", self.drinkup.bar.name]];
        [tweetVC setCompletionHandler:^(SLComposeViewControllerResult result) {
            if (result == SLComposeViewControllerResultDone) {
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
