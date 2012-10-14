//
//  GHDrinkupsViewController.m
//  Github
//
//  Created by Zach Williams on 9/30/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "GHDrinkupsViewController.h"
#import "GHDataModel.h"
#import "GHDrinkupCell.h"
#import "Drinkup.h"
#import "GHVenueViewController.h"
#import "Reachability.h"

@interface GHDrinkupsViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end


static const float kScrollViewThrottleOffset = 15.0f;
static NSString * const kCellReuseIdentifier = @"Drinkup";


@implementation GHDrinkupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:@"GHDrinkupCell" bundle:nil]
          forCellWithReuseIdentifier:kCellReuseIdentifier];
    self.collectionView.backgroundColor = [UIColor gh_backgroundColor];
    [self refetchData];
    [self createPullToRefresh];
    [self customBackButton];
    [self checkNetworkReachability];
}

# pragma mark - User Interface

- (void)createPullToRefresh {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refetchData) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor gh_refreshTintColor];
    self.refreshControl = refreshControl;
    [self.collectionView addSubview:self.refreshControl];
}

// Used on the next navigation controller.
- (void)customBackButton {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Drinkup"];
    NSManagedObjectContext *context = [[GHDataModel sharedModel] mainContext];
    fetchRequest.fetchBatchSize = 30;
    fetchRequest.returnsObjectsAsFaults = NO;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:context
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:@"Drinkup"];
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView reloadData];
}

- (void)refetchData {
    [self.fetchedResultsController performSelectorOnMainThread:@selector(performFetch:)
                                                    withObject:nil
                                                 waitUntilDone:YES
                                                     modes:@[NSRunLoopCommonModes]];
    if ([self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self.fetchedResultsController.sections objectAtIndex:section] numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GHDrinkupCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseIdentifier
                                                                         forIndexPath:indexPath];
    cell.drinkup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Drinkup *drinkup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    GHVenueViewController *meetupVC = [[GHVenueViewController alloc] initWithDrinkup:drinkup];
    [self.navigationController pushViewController:meetupVC animated:YES];
}

#pragma mark - Reachability

- (void)checkNetworkReachability {
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    reach.unreachableBlock = ^(Reachability *reach){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Connection Failed"
                                       message:@"Sorry, internet connection failed."
                                      delegate:self
                             cancelButtonTitle:@"OK"
                             otherButtonTitles: nil] show];
        });
    };
    [reach startNotifier];
}

@end
