//
//  GHBarInformation.h
//  Github
//
//  Created by Zach Williams on 10/3/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Drinkup;

@interface GHBarInformationView : UIView

@property (nonatomic, strong) Drinkup *drinkup;
@property (nonatomic, weak) IBOutlet UILabel *address;
@property (nonatomic, weak) IBOutlet UILabel *date;
@property (nonatomic, weak) IBOutlet UILabel *bar;
@property (nonatomic, weak) IBOutlet UILabel *time;

- (id)initWithDrinkup:(Drinkup *)drinkup;

@end
