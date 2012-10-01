//
//  GHMeetupViewController.h
//  Github
//
//  Created by Zach Williams on 9/30/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Drinkup.h"

@interface GHMeetupViewController : UIViewController

@property (strong, nonatomic) Drinkup *drinkup;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

- (id)initWithDrinkup:(Drinkup *)drinkup;

@end
