//
//  GHBarInformation.m
//  Github
//
//  Created by Zach Williams on 10/3/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "GHBarInformationView.h"
#import "Drinkup.h"
#import "Bar+Annotation.h"

@implementation GHBarInformationView

- (id)initWithDrinkup:(Drinkup *)drinkup {
    self = [super init];
    if (self) {
        self = [[NSBundle mainBundle] loadNibNamed:@"GHBarInformationView" owner:self options:nil][0];
        _drinkup = drinkup;
        self.address.text = _drinkup.bar.address;
        self.bar.text = _drinkup.bar.name;
    }
    return self;
}

@end
