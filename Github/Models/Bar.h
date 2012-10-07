//
//  Bar.h
//  Github
//
//  Created by Zach Williams on 10/6/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Drinkup;

@interface Bar : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * bar_id;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * foursquare;
@property (nonatomic, retain) NSString * twitter;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSSet *drinkups;
@end

@interface Bar (CoreDataGeneratedAccessors)

- (void)addDrinkupsObject:(Drinkup *)value;
- (void)removeDrinkupsObject:(Drinkup *)value;
- (void)addDrinkups:(NSSet *)values;
- (void)removeDrinkups:(NSSet *)values;

@end
