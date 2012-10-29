//
//  Bar+Annotation.m
//  Github
//
//  Created by Zach Williams on 10/28/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "Bar+Annotation.h"

@implementation Bar (Annotation)

- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
    return coordinate;
}

- (NSString *)title {
    return self.name;
}

@end
