//
//  GHJSONFormatter.m
//  Github
//
//  Created by Zach Williams on 9/22/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "GHJSONFormatter.h"

@implementation GHJSONFormatter

- (NSNumber *)formatCoordinate:(NSString *)coordinate {
    static NSNumberFormatter *coordinateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coordinateFormatter = [[NSNumberFormatter alloc] init];
        [coordinateFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    });
    return [coordinateFormatter numberFromString:coordinate];
}

- (NSDate *)formatDate:(NSString *)date {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZ";
    });
    return [dateFormatter dateFromString:date];
}

@end
