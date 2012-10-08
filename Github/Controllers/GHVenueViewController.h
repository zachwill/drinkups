//
//  GHMeetupViewController.h
//  Github
//
//  Created by Zach Williams on 9/30/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class Drinkup;

@interface GHVenueViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) Drinkup *drinkup;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;

- (id)initWithDrinkup:(Drinkup *)drinkup;

@end
