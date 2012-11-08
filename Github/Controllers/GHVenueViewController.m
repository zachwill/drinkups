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
#import "BlocksKit.h"
#import "Drinkup.h"
#import "Bar+Annotation.h"
#import "GHBarInformationView.h"

// ***************************************************************************

@interface GHVenueViewController ()

@property (nonatomic, strong) GHBarInformationView *barView;
@property (nonatomic, assign) BOOL canSendTweets;

@end

// ***************************************************************************

static float kMapViewOffset;
static float kScrollViewOffset;

// ***************************************************************************

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
    self.scrollView.delegate = self;
    self.scrollView.alwaysBounceVertical = YES;

    if ([self isPhone5]) {
        kMapViewOffset    = -110.0f;
        kScrollViewOffset = 300.0f;
    } else {
        kMapViewOffset    = -140.0f;
        kScrollViewOffset = 220.0f;
    }

    // UI
    [self.view insertSubview:self.mapView belowSubview:self.scrollView];
    [self addToolbarButtons];
    [self createParallaxViewOffset];

    // Add bar to map
    [self centerMapToBarLocation];
    [self.mapView addAnnotation:self.drinkup.bar];
    
    // UIGestureRecognizer
    [self addGestures];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.scrollView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.scrollView.layer.shadowRadius = 1.0f;
    self.scrollView.layer.shadowOpacity = 0.15f;
}

#pragma mark - iPhone 5

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
    float scrollViewHeight = self.view.frame.size.height - combinedChromeHeight;
    
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

- (void)centerMapToBarLocation {
    MKMapPoint point  = MKMapPointForCoordinate(self.drinkup.bar.coordinate);
    MKMapRect mapRect = MKMapRectMake(point.x, point.y, 5000, 5000);
    self.mapView.region = MKCoordinateRegionForMapRect(mapRect);
    self.mapView.centerCoordinate = self.drinkup.bar.coordinate;
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
                                                                action:@selector(showReminderAlert:)];
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

- (void)showReminderAlert:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create Reminder"
                                                    message:@"Create a reminder for this drinkup?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:nil];
    
    [alert addButtonWithTitle:@"OK" handler:^{
        [self createReminder];
    }];
    
    [alert show];
}

- (void)createReminder {
    [[EKEventStore alloc] requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        EKReminder *reminder = [EKReminder reminderWithEventStore:eventStore];
        NSString *barName = self.drinkup.bar.name;
        reminder.title = [NSString stringWithFormat:@"Github Drinkup at %@", barName];
        reminder.location = barName;
        reminder.calendar = [eventStore defaultCalendarForNewReminders];

        // Date components setup.
        unsigned options = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:options fromDate:self.drinkup.date];
        // Default hour set to noon.
        components.hour = 12;
        
        // Add alarm with correct date.
        reminder.startDateComponents = components;
        NSDate *dateToRemind = [[NSCalendar currentCalendar] dateFromComponents:components];
        [reminder addAlarm:[EKAlarm alarmWithAbsoluteDate:dateToRemind]];

        // TODO: Check and see if reminder already exists.
        NSError *reminderError;
        [eventStore saveReminder:reminder commit:YES error:&reminderError];
        if (reminderError) {
            NSLog(@"Error saving reminder: %@", reminderError);
        } else {
            NSLog(@"Reminder created successfully");
        }
    }];
}

- (void)createTweet:(id)sender {
    if (self.canSendTweets) {
        SLComposeViewController *tweetVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        // Create the initial tweet.
        NSString *location;
        if ([self.drinkup.bar.twitter isEqualToString:@""]) {
            location = self.drinkup.bar.name;
        } else {
            location = [NSString stringWithFormat:@"@%@", self.drinkup.bar.twitter];
        }
        [tweetVC setInitialText:[NSString stringWithFormat:@"Github drinkup at %@", location]];
        
        // Add the URL from Github's blog post.
        [tweetVC addURL:[NSURL URLWithString:self.drinkup.blog]];
        
        __weak id weakSelf = self;
        [tweetVC setCompletionHandler:^(SLComposeViewControllerResult result) {
            if (result == SLComposeViewControllerResultDone) {
                // Could be used for Flurry purposes.
                NSLog(@"Tweet sent");
            }
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
        
        // Finally, present the tweet.
        [self presentViewController:tweetVC animated:YES completion:nil];
    }
}

#pragma mark - UIActionSheet

- (void)showActionSheet:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;

    __weak id weakSelf = self;
    __weak Drinkup *drinkup = self.drinkup;

    [actionSheet addButtonWithTitle:@"Call Bar" handler:^{
        if ([drinkup.bar.phone isEqualToString:@""] == NO) {
            NSCharacterSet *decimalSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
            NSString *phone = [[drinkup.bar.phone componentsSeparatedByCharactersInSet:decimalSet] componentsJoinedByString:@""];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phone]]];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Call Failed"
                                        message:@"Sorry, that bar's number is unavailable."
                                       delegate:weakSelf
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:nil] show];
        }
    }];

    [actionSheet addButtonWithTitle:@"Foursquare" handler:^{
        NSURL *foursquare = [NSURL URLWithString:[NSString stringWithFormat:@"foursquare://venues/%@", drinkup.bar.foursquare]];
        [[UIApplication sharedApplication] openURL:foursquare];
    }];

    [actionSheet addButtonWithTitle:@"Github Blog" handler:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:drinkup.blog]];
    }];

    [actionSheet setCancelButtonWithTitle:@"Cancel" handler:nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIGestureRecognizer

- (void)addGestures {
    // Swipe Gesture Recognizer
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeBackward:)];
    swipeGesture.delegate  = self;
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeGesture];
    
    // Pinch Gesture Recognizer
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinchMapView:)];
    pinchGesture.delegate = self;
    [self.view addGestureRecognizer:pinchGesture];
    
    // Tap Gesture
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMapView:)];
    tapGesture.delegate = self;
    [self.scrollView addGestureRecognizer:tapGesture];
}

- (void)didSwipeBackward:(UISwipeGestureRecognizer *)swipe {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didPinchMapView:(UIPinchGestureRecognizer *)pinch {
    static MKCoordinateRegion originalRegion;
    if (pinch.state == UIGestureRecognizerStateBegan) {
        originalRegion = self.mapView.region;
    }    

    double latdelta = originalRegion.span.latitudeDelta / pinch.scale;
    double lngdelta = originalRegion.span.longitudeDelta / pinch.scale;

    latdelta = MAX(MIN(latdelta, 8), 0.002);
    lngdelta = MAX(MIN(lngdelta, 8), 0.002);
    MKCoordinateSpan span = MKCoordinateSpanMake(latdelta, lngdelta);

    [self.mapView setRegion:MKCoordinateRegionMake(originalRegion.center, span) animated:YES];
}

- (void)didTapMapView:(UITapGestureRecognizer *)tap {
    if ([tap locationInView:self.scrollView].y < kScrollViewOffset) {
        // Ask the user to open the Maps application.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Switch To Maps"
                                            message:@"Switch to the Maps application?"
                                           delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:nil];
        [alert addButtonWithTitle:@"OK" handler:^{
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.drinkup.bar.coordinate addressDictionary:nil];
            MKMapItem *map = [[MKMapItem alloc] initWithPlacemark:placemark];
            map.name = self.drinkup.bar.name;
            map.url = [NSURL URLWithString:self.drinkup.blog];
            [map openInMapsWithLaunchOptions:nil];
        }];
        [alert show];
    }
}

@end
