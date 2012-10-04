//
//  GHBarInformation.h
//  Github
//
//  Created by Zach Williams on 10/3/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Drinkup.h"

@interface GHBarInformationView : UIView

@property (strong, nonatomic) Drinkup *drinkup;

- (id)initWithDrinkup:(Drinkup *)drinkup;

@end
