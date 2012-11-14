//
//  GHAppDelegate.m
//  Github
//
//  Created by Zach Williams on 9/17/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "AppDelegate.h"
#import "GHDataModel.h"
#import "GHDrinkupsViewController.h"
#import "GHLayout.h"
#import "AFNetworking.h"
#import "Reachability.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[GHDataModel sharedModel] createSharedURLCache];
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    // Create initial UIViewController
    GHLayout *layout = [[GHLayout alloc] init];
    GHDrinkupsViewController *drinkupsVC = [[GHDrinkupsViewController alloc] initWithCollectionViewLayout:layout];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:drinkupsVC];

    // Make UINavigationController the root controller
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    // General styling through UIAppearance
    [self applyStyleSheet];

    // Network Reachability
    [self checkNetworkReachability];

    // TODO: Flurry analytics

    return YES;
}

// A global appearance stylesheet.
- (void)applyStyleSheet {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav"]
                                       forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"nav_shadow"]];
    UIImage *back = [[UIImage imageNamed:@"backbutton"] stretchableImageWithLeftCapWidth:13
                                                                            topCapHeight:0];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:back
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    [[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"toolbar"]
                            forToolbarPosition:UIToolbarPositionAny
                                    barMetrics:UIBarMetricsDefault];
    [[UIToolbar appearance] setShadowImage:[UIImage imageNamed:@"toolbar_shadow"]
                        forToolbarPosition:UIToolbarPositionAny];
    [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"toolbar_button"]
                                            forState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
}
							
#pragma mark - Reachability

- (void)checkNetworkReachability {
    Reachability *heroku = [Reachability reachabilityWithHostname:@"http://drinkups.herokuapp.com"];
    heroku.unreachableBlock = ^(Reachability *reachable){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Connection Failed"
                                message:@"Sorry, internet connection failed."
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles: nil] show];
        });
    };
    [heroku startNotifier];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
