//
//  Drinkup.h
//  Github
//
//  Created by Zach Williams on 9/22/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bar;

@interface Drinkup : NSManagedObject

@property (nonatomic, retain) NSString * blog;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * drinkup_id;
@property (nonatomic, retain) Bar *bar;

@end
