//
//  GHAPIClient.h
//  Github
//
//  Created by Zach Williams on 9/17/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "AFRESTClient.h"
#import "AFIncrementalStore.h"

@interface GHAPIClient : AFRESTClient <AFIncrementalStoreHTTPClient>

+ (GHAPIClient *)sharedClient;

@end
