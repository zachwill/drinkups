//
//  Bar+Annotation.h
//  Github
//
//  Created by Zach Williams on 10/28/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "Bar.h"
#import <MapKit/MapKit.h>

@interface Bar (Annotation)

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;

@end
