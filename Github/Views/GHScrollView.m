//
//  GHScrollView.m
//  Github
//
//  Created by Zach Williams on 10/3/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "GHScrollView.h"

@implementation GHScrollView

// Because dealing with UIScrollView and UIGestures is still difficult.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    NSString *touchClass = NSStringFromClass(touch.view.class);
    if ([touchClass isEqualToString:@"GHScrollView"]) {
        // Then the area above the scrollView was actually touched.
        [[NSNotificationCenter defaultCenter] postNotificationName:GHScrollViewTouchNotification object:nil];
    }
}

@end
