//
//  GHLayout.m
//  Github
//
//  Created by Zach Williams on 9/30/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "GHLayout.h"

static const float kItemSize = 150.0f;

@implementation GHLayout

- (id)init {
    self = [super init];
    if (self) {
        self.itemSize = CGSizeMake(kItemSize, kItemSize);
        self.minimumInteritemSpacing = 0;
        self.sectionInset = UIEdgeInsetsMake(10, 6, 10, 6);
    }
    return self;
}

@end
