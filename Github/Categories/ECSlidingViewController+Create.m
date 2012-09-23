//
//  ECSlidingViewController+Create.m
//  Drinkups
//
//  Created by Zach Williams on 9/5/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "ECSlidingViewController+Create.h"

static const float kAnchorPeekAmount = 60.0f;
static NSString * const kTopViewController  = @"";
static NSString * const kLeftViewController = @"";

@implementation ECSlidingViewController (Create)

- (void)createChildViewControllers {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self.topViewController = [storyboard instantiateViewControllerWithIdentifier:kTopViewController];
    self.underLeftViewController = [storyboard instantiateViewControllerWithIdentifier:kLeftViewController];
    self.anchorRightPeekAmount = kAnchorPeekAmount;
}
@end
