//
//  GHAPIClient.m
//  Github
//
//  Created by Zach Williams on 9/17/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "GHAPIClient.h"
#import "GHJSONFormatter.h"

@interface GHAPIClient ()
@property (strong, nonatomic) GHJSONFormatter *jsonFormatter;
@end

static NSString * const kAPIBaseURL = @"http://drinkups.herokuapp.com/api/v1/";


@implementation GHAPIClient

+ (GHAPIClient *)sharedClient {
    static GHAPIClient *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *url = [NSURL URLWithString:kAPIBaseURL];
        _sharedInstance = [[GHAPIClient alloc] initWithBaseURL:url];
    });
    return _sharedInstance;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self)
        return nil;
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    return self;
}

#pragma mark - AFIncrementalStore

// Return the "objects" array from Tastypie API
- (id)representationOrArrayOfRepresentationsFromResponseObject:(id)responseObject {
    responseObject = [super representationOrArrayOfRepresentationsFromResponseObject:responseObject];
    NSArray *tastyPieObjects = [responseObject objectForKey:@"objects"];
    if ([responseObject isKindOfClass:[NSDictionary class]] && tastyPieObjects) {
        return tastyPieObjects;
    }
    return responseObject;
}

- (NSURLRequest *)requestForFetchRequest:(NSFetchRequest *)fetchRequest
                             withContext:(NSManagedObjectContext *)context
{
    NSMutableURLRequest *mutableRequest = nil;
    if ([fetchRequest.entityName isEqualToString:@"Drinkup"]) {
        mutableRequest = [self requestWithMethod:@"GET" path:@"drinkups" parameters:nil];
    }
    return mutableRequest;
}

- (NSDictionary *)attributesForRepresentation:(NSDictionary *)representation
                                     ofEntity:(NSEntityDescription *)entity
                                 fromResponse:(NSHTTPURLResponse *)response
{
    NSMutableDictionary *mutableProperties = [[super attributesForRepresentation:representation
                                                                        ofEntity:entity
                                                                    fromResponse:response] mutableCopy];
    if ([entity.name isEqualToString:@"Drinkup"]) {
        NSDate *date = [self.jsonFormatter formatDate:representation[@"date"]];
        mutableProperties[@"date"] = date;
        mutableProperties[@"drinkup_id"] = representation[@"id"];
    } else if ([entity.name isEqualToString:@"Bar"]) {
        NSNumber *latitude  = [self.jsonFormatter formatCoordinate:representation[@"latitude"]];
        NSNumber *longitude = [self.jsonFormatter formatCoordinate:representation[@"longitude"]];
        mutableProperties[@"latitude"]  = latitude;
        mutableProperties[@"longitude"] = longitude;
        mutableProperties[@"bar_id"] = representation[@"id"];
    }
    return mutableProperties;
}

// Use TastyPie's "resource_uri" field
- (NSString *)resourceIdentifierForRepresentation:(NSDictionary *)representation
                                         ofEntity:(NSEntityDescription *)entity
                                     fromResponse:(NSHTTPURLResponse *)response
{
    return representation[@"resource_uri"];
}

- (BOOL)shouldFetchRemoteAttributeValuesForObjectWithID:(NSManagedObjectID *)objectID
                                 inManagedObjectContext:(NSManagedObjectContext *)context
{
    return NO;
}

- (BOOL)shouldFetchRemoteValuesForRelationship:(NSRelationshipDescription *)relationship
                               forObjectWithID:(NSManagedObjectID *)objectID
                        inManagedObjectContext:(NSManagedObjectContext *)context
{
    return NO;
}

#pragma mark - Private Properties

- (GHJSONFormatter *)jsonFormatter {
    if (_jsonFormatter == nil) {
        _jsonFormatter = [[GHJSONFormatter alloc] init];
    }
    return _jsonFormatter;
}

@end
