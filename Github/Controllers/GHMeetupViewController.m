//
//  GHMeetupViewController.m
//  Github
//
//  Created by Zach Williams on 9/30/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "GHMeetupViewController.h"

@interface GHMeetupViewController ()

@end

@implementation GHMeetupViewController

- (id)initWithDrinkup:(Drinkup *)drinkup {
    self = [super init];
    _drinkup = drinkup;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
}

@end
