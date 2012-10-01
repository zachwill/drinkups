//
//  GHMeetupViewController.m
//  Github
//
//  Created by Zach Williams on 9/30/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "GHMeetupViewController.h"

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
    [self addToolbarButtons];
    self.view.backgroundColor = [UIColor colorWithHex:@"eee"];
}

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
}

#pragma mark - Actions

- (void)createReminder:(id)sender {
    
}

- (void)createTweet:(id)sender {
    
}

@end
