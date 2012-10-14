//
//  GHVenueViewController.m
//  Github
//
//  Created by Zach Williams on 9/30/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "GHVenueViewController.h"
#import <EventKit/EventKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import "Bar.h"
#import "Drinkup.h"
#import "GHBarInformationView.h"

@interface GHVenueViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) GHBarInformationView *barView;
@property (nonatomic, assign) BOOL canSendTweets;

@end


static float kMapViewOffset;
static float kScrollViewOffset;


@implementation GHVenueViewController

- (id)initWithDrinkup:(Drinkup *)drinkup {
    self = [super initWithNibName:@"GHVenue" bundle:nil];
    if (!self) {
        return nil;
    }
    _drinkup = drinkup;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate  = self;

    if ([self isPhone5]) {
        kMapViewOffset    = -100.0f;
        kScrollViewOffset = 300.0f;
    } else {
        kMapViewOffset    = -120.0f;
        kScrollViewOffset = 220.0f;
    }

    [self.view insertSubview:self.mapView belowSubview:self.scrollView];
    [self addToolbarButtons];
    [self createParallaxViewOffset];
    [self centerMapToLatitude:self.drinkup.bar.latitude longitude:self.drinkup.bar.longitude];
    [self registerForNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.scrollView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.scrollView.layer.shadowRadius = 1.0f;
    self.scrollView.layer.shadowOpacity = 0.15f;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self unregisterForNotifications];
}

#pragma mark - iPhone5

- (BOOL)isPhone5 {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            CGFloat height = [[UIScreen mainScreen] bounds].size.height * [[UIScreen mainScreen] scale];
            return height == 1136;
        }
    }
    return NO;
}

#pragma mark - UIScrollView

- (void)createParallaxViewOffset {
    // Adjust the scrollView content size.
    float combinedChromeHeight = 88.0f;
    float minimumScrollViewOffset = 0.5f;
    float scrollViewHeight = self.view.frame.size.height - combinedChromeHeight + minimumScrollViewOffset;
    
    if ([self isPhone5] == NO) {
        // Off by another 88 points on iPhone 4?
        scrollViewHeight -= combinedChromeHeight;
    }
    
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
    
    // Set the date label.
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"eeee, d MMM yy";
    });
    _barView.date.text = [dateFormatter stringFromDate:self.drinkup.date];
    
    // Set the time label.
    static NSDateFormatter *timeFormatter = nil;
    static dispatch_once_t anotherToken;
    dispatch_once(&anotherToken, ^{
        timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = @"h:mm a";
    });
    _barView.time.text = [timeFormatter stringFromDate:self.drinkup.date];
    
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
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"]
                                               landscapeImagePhone:nil
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(showActionSheet:)];
    self.toolbar.items = @[reminder, tweet, flexible, menu];
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
        } else {
            // Show an alert on the main queue.
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder Saved"
                                                                message:@"A drinkup reminder was set for you."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
                [alert show];
            });
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
        
        // Create the initial tweet.
        NSString *tweet = nil;
        if ([self.drinkup.bar.twitter isEqualToString:@""]) {
            tweet = [NSString stringWithFormat:@"Github drinkup at %@", self.drinkup.bar.name];
        } else {
            tweet = [NSString stringWithFormat:@"Github drinkup at @%@", self.drinkup.bar.twitter];
        }
        [tweetVC setInitialText:tweet];
        
        // Add the URL from Github's blog post.
        [tweetVC addURL:[NSURL URLWithString:self.drinkup.blog]];
        
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
        
        // Finally, present the tweet.
        [self presentViewController:tweetVC animated:YES completion:nil];
    }
}

#pragma mark - UIActionSheet

- (void)showActionSheet:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Call Bar", @"Foursquare", @"Github Blog", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // Phone Call
        if ([self.drinkup.bar.phone isEqualToString:@""] == NO) {
            NSCharacterSet *decimalSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
            NSString *phone = [[self.drinkup.bar.phone componentsSeparatedByCharactersInSet:decimalSet] componentsJoinedByString:@""];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phone]]];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Call Failed"
                                                            message:@"Sorry, that bar's number is unavailable."
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles: nil];
            [alert show];
        }
    } else if (buttonIndex == 1) {
        // Foursquare
        NSURL *foursquare = [NSURL URLWithString:[NSString stringWithFormat:@"foursquare://venues/%@", self.drinkup.bar.foursquare]];
        [[UIApplication sharedApplication] openURL:foursquare];
    } else if (buttonIndex == 2) {
        // Github Blog
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.drinkup.blog]];
    }
}

#pragma mark - NSNotificationCenter

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(switchToMaps:)
                                                 name:GHScrollViewTouchNotification
                                               object:nil];
}

- (void)unregisterForNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GHScrollViewTouchNotification
                                                  object:nil];
}

@end
