//
//  GHIncrementalStore.m
//  Github
//
//  Created by Zach Williams on 9/17/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "GHIncrementalStore.h"
#import "GHAPIClient.h"
#import "GHDataModel.h"

@implementation GHIncrementalStore

+ (void)initialize {
    [NSPersistentStoreCoordinator registerStoreClass:self forStoreType:[self type]];
}

+ (NSString *)type {
    return NSStringFromClass(self);
}

- (NSManagedObjectModel *)model {
    NSURL *dataModelURL = [[NSBundle mainBundle] URLForResource:[[GHDataModel sharedModel] modelName]
                                                  withExtension:@"xcdatamodeld"];
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:dataModelURL];
}

- (id<AFIncrementalStoreHTTPClient>)HTTPClient {
    return [GHAPIClient sharedClient];
}

@end
