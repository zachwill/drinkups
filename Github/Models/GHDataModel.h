//
//  GHDataModel.h
//  Github
//
//  Created by Zach Williams on 9/17/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface GHDataModel : NSObject

@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSManagedObjectContext *mainContext;

+ (GHDataModel *)sharedModel;
- (NSString *)modelName;
- (NSString *)pathToModel;
- (NSString *)storeFileName;
- (NSURL *)localStoreURL;
- (void)createSharedURLCache;

@end
