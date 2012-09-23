//
//  GHJSONFormatter.h
//  Github
//
//  Created by Zach Williams on 9/22/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHJSONFormatter : NSObject

- (NSNumber *)formatCoordinate:(NSString *)coordinate;
- (NSDate *)formatDate:(NSString *)date;

@end
