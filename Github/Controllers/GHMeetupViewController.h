//
//  GHMeetupViewController.h
//  Github
//
//  Created by Zach Williams on 9/30/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Drinkup.h"

@interface GHMeetupViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) Drinkup *drinkup;
@property (strong, nonatomic) MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIView *offsetView;

- (id)initWithDrinkup:(Drinkup *)drinkup;

@end
