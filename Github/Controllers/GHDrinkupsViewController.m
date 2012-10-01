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
#import "GHMeetupViewController.h"

@interface GHDrinkupsViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) float lastScrollPosition;

@end

static const float kScrollViewThrottleOffset = 15.0f;

@implementation GHDrinkupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:@"GHDrinkupCell" bundle:nil]
          forCellWithReuseIdentifier:@"Drinkup"];
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    [self refetchData];
    [self createPullToRefresh];
}

- (void)createPullToRefresh {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refetchData) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor colorWithHex:@"666"];
    self.refreshControl = refreshControl;
    [self.collectionView addSubview:self.refreshControl];
}

#pragma mark - Data Source

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
                                                                               cacheName:@"drinkups"];
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView reloadData];
}

- (void)refetchData {
    [self.fetchedResultsController performSelectorOnMainThread:@selector(performFetch:)
                                                withObject:nil waitUntilDone:YES
                                                     modes:@[NSRunLoopCommonModes]];
    if ([self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self.fetchedResultsController.sections objectAtIndex:section] numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Drinkup";
    GHDrinkupCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.drinkup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Drinkup *drinkup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    GHMeetupViewController *meetupVC = [[GHMeetupViewController alloc] initWithDrinkup:drinkup];
    [self customBackButton];
    [self.navigationController pushViewController:meetupVC animated:YES];
}

- (void)customBackButton {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

@end
