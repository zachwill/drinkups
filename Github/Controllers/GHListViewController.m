//
//  GHListViewController.m
//  Github
//
//  Created by Zach Williams on 9/22/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "GHListViewController.h"
#import "GHDataModel.h"
#import "Drinkup.h"
#import "Bar.h"
#import "GHDrinkupTableViewCell.h"

@interface GHListViewController () <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end

@implementation GHListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Drinkup"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"drinkup_id" ascending:NO]];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:[[GHDataModel sharedModel] mainContext]
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:@"DrinkupCache"];
    _fetchedResultsController.delegate = self;
    [self refetchData];
}

- (void)refetchData {
    [_fetchedResultsController performSelectorOnMainThread:@selector(performFetch:)
                                                withObject:nil waitUntilDone:YES
                                                     modes:@[NSRunLoopCommonModes]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_fetchedResultsController sections].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    GHDrinkupTableViewCell *cell = (GHDrinkupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[GHDrinkupTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Drinkup *drinkup = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.drinkup = drinkup;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

@end
