//
//  GHDrinkupCell.m
//  Github
//
//  Created by Zach Williams on 9/30/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "GHDrinkupCell.h"

@implementation GHDrinkupCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHex:@"eee"];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    self.layer.shadowColor  = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 2;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowOpacity = .25;
}

- (void)setSelected:(BOOL)selected {
    UIView *view = [[UIView alloc] initWithFrame:self.frame];
    view.backgroundColor = [UIColor blueColor];
    self.selectedBackgroundView = view;
    [super setSelected:selected];
}

@end
