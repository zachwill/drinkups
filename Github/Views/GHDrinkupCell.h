//
//  GHDrinkupCell.h
//  Github
//
//  Created by Zach Williams on 9/30/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bar.h"

@interface GHDrinkupCell : UICollectionViewCell

@property (strong, nonatomic) Bar *bar;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *city;

@end
