//
//  GHDrinkupTableViewCell.m
//  Github
//
//  Created by Zach Williams on 9/23/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "GHDrinkupTableViewCell.h"
#import "Bar.h"

@implementation GHDrinkupTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setDrinkup:(Drinkup *)drinkup {
    self.textLabel.text = drinkup.bar.name;
    self.detailTextLabel.text = drinkup.bar.city;
}

@end
