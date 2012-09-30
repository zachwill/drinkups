//
//  GHDrinkupCell.m
//  Github
//
//  Created by Zach Williams on 9/30/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "GHDrinkupCell.h"
#import "Bar.h"

@implementation GHDrinkupCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHex:@"eee"];
    }
    return self;
}

- (void)setDrinkup:(Drinkup *)drinkup {
    self.name.text = drinkup.bar.name;
    self.city.text = drinkup.bar.city;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
}

@end
