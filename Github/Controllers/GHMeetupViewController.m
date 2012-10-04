//
//  GHMeetupViewController.m
//  Github
//
//  Created by Zach Williams on 9/30/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "GHMeetupViewController.h"
#import <EventKit/EventKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import "Bar.h"
#import "GHBarInformationView.h"

@interface GHMeetupViewController ()

@property (nonatomic, strong) GHBarInformationView *barView;
@property (nonatomic, assign) BOOL canSendTweets;

@end


static const float kMapViewOffset = -100.0f;
static const float kScrollViewOffset = 280.0f;


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
    self.scrollView.delegate  = self;
    [self.view insertSubview:self.mapView belowSubview:self.scrollView];
    [self addToolbarButtons];
    [self createParallaxViewOffset];
    [self centerMapToLatitude:self.drinkup.bar.latitude
                    longitude:self.drinkup.bar.longitude];
    [self registerForNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.scrollView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.scrollView.layer.shadowRadius = 1.0f;
    self.scrollView.layer.shadowOpacity = 0.15f;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GHScrollViewTouchNotification object:nil];
}

#pragma mark - UIScrollView

- (void)createParallaxViewOffset {
    // Adjust the scrollView content size.
    float combinedChromeHeight = 88.0f;
    float minimumScrollViewOffset = 0.5f;
    float scrollViewHeight = self.view.frame.size.height - combinedChromeHeight + minimumScrollViewOffset;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, scrollViewHeight);
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    // Add an offset to the scrollView's subview;
    CGRect frame = self.view.frame;
    frame.origin.y = kScrollViewOffset;
    self.barView.frame = frame;
    [self.scrollView addSubview:self.barView];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGRect frame = self.mapView.frame;
    
    // Center the mapView while scrolling down.
    if (scrollOffset < 0) {
        frame.origin.y = floorf(kMapViewOffset - (scrollOffset / 3));
        self.mapView.frame = frame;
    }
}

#pragma mark - MKMapView

- (MKMapView *)mapView {
    if (_mapView != nil) {
        return _mapView;
    }
    
    CGRect frame = CGRectMake(0, kMapViewOffset, self.view.frame.size.width, self.view.frame.size.height);
    _mapView = [[MKMapView alloc] initWithFrame:frame];
    _mapView.userInteractionEnabled = YES;
    return _mapView;
}

- (void)centerMapToLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude {
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([latitude doubleValue],
                                                              [longitude doubleValue]);
    MKMapPoint point  = MKMapPointForCoordinate(coord);
    MKMapRect mapRect = MKMapRectMake(point.x, point.y, 5000, 5000);
    self.mapView.region = MKCoordinateRegionForMapRect(mapRect);
    self.mapView.centerCoordinate = coord;
    MKPlacemark *annotation = [[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:nil];
    [self.mapView addAnnotation:annotation];
}

// Called by listening to NSNotificationCenter
- (void)switchToMaps:(id)sender {
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.drinkup.bar.latitude doubleValue],
                                                              [self.drinkup.bar.longitude doubleValue]);
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:nil];
    MKMapItem *map = [[MKMapItem alloc] initWithPlacemark:placemark];
    map.name = self.drinkup.bar.name;
    map.url = [NSURL URLWithString:self.drinkup.blog];
    [map openInMapsWithLaunchOptions:nil];
}

#pragma mark - GHBarInformationView

- (GHBarInformationView *)barView {
    if (_barView != nil) {
        return _barView;
    }
    
    _barView = [[GHBarInformationView alloc] initWithDrinkup:self.drinkup];
    return _barView;
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
        self.canSendTweets = YES;
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
        SLComposeViewController *tweetVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetVC addURL:[NSURL URLWithString:self.drinkup.blog]];
        [tweetVC setInitialText:[NSString stringWithFormat:@"%@ drinkup", self.drinkup.bar.name]];
        
        __weak id weakSelf = self;
        [tweetVC setCompletionHandler:^(SLComposeViewControllerResult result) {
            if (result == SLComposeViewControllerResultDone) {
                [weakSelf dismissViewControllerAnimated:YES completion:^{
                    NSLog(@"Tweet, tweet.");
                }];
            } else {
                [weakSelf dismissViewControllerAnimated:YES completion:^{
                    NSLog(@"Dismissed.");
                }];
            }
        }];
        
        [self presentViewController:tweetVC animated:YES completion:nil];
    }
}

#pragma mark - NSNotificationCenter

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(switchToMaps:)
                                                 name:GHScrollViewTouchNotification
                                               object:nil];
}

@end
