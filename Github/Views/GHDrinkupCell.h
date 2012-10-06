//
//  GHDrinkupCell.h
//  Github
//
//  Created by Zach Williams on 9/30/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Drinkup.h"

@interface GHDrinkupCell : UICollectionViewCell

@property (nonatomic, strong) Drinkup *drinkup;
@property (nonatomic, weak) IBOutlet UILabel *name;
@property (nonatomic, weak) IBOutlet UILabel *city;
@property (nonatomic, weak) IBOutlet UIImageView *barPicture;

@end
