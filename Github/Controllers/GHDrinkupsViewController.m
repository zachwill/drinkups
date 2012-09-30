//
//  GHDrinkupsViewController.m
//  Github
//
//  Created by Zach Williams on 9/30/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "GHDrinkupsViewController.h"
#import "GHDrinkupCell.h"
#import "Drinkup.h"

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
    self.collectionView.showsVerticalScrollIndicator = NO;
}

- (void)createPullToRefresh {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:nil forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.collectionView addSubview:self.refreshControl];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Drinkup";
    GHDrinkupCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [[collectionView cellForItemAtIndexPath:indexPath] setSelected:YES];
}

#pragma mark - Scrolling

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.lastScrollPosition = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float scrollPosition = scrollView.contentOffset.y;
    // Throttle the scroll calls.
    if (abs(self.lastScrollPosition - scrollPosition) > kScrollViewThrottleOffset) {
        if (self.lastScrollPosition < scrollView.contentOffset.y) {
            if (self.navigationController.navigationBarHidden == NO) {
                [self.navigationController setNavigationBarHidden:YES animated:YES];
            }
        } else {
            if (self.navigationController.navigationBarHidden == YES) {
                [self.navigationController setNavigationBarHidden:NO animated:YES];
            }
        }
    }
}

@end
