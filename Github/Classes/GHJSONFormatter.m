//
//  GHJSONFormatter.m
//  Github
//
//  Created by Zach Williams on 9/22/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "GHJSONFormatter.h"

@interface GHJSONFormatter ()
@property (strong, nonatomic) NSNumberFormatter *coordinateFormatter;
@end

@implementation GHJSONFormatter

- (NSNumberFormatter *)coordinateFormatter {
    if (_coordinateFormatter == nil) {
        _coordinateFormatter = [[NSNumberFormatter alloc] init];
        [_coordinateFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    }
    return _coordinateFormatter;
}

- (NSNumber *)formatCoordinate:(NSString *)coordinate {
    return [self.coordinateFormatter numberFromString:coordinate];
}

@end
