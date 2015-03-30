//
//  AppDelegate.m
//  HackerBooks
//
//  Created by David de Tena on 27/03/15.
//  Copyright (c) 2015 David de Tena. All rights reserved.
//

#import "AppDelegate.h"
#import "DTCBook.h"
#import "DTCBookViewController.h"
#import "DTCLibrary.h"
#import "DTCLibraryTableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]
                   initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Load the model of library
    DTCLibrary *library = [[DTCLibrary alloc]init];
    
    // Configure according the device
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [self configureForPadWithModel:library];
    }
    else{
        [self configureForPhoneWithModel:library];
    }
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Settings
- (void)configureForPadWithModel:(DTCLibrary *)model{
    // Create the VCs. Select the first book of the first tag to be display first
    DTCLibraryTableViewController *libraryVC = [[DTCLibraryTableViewController alloc]initWithModel:model style:UITableViewStylePlain];
    DTCBookViewController *bookVC = [[DTCBookViewController alloc] initWithModel:[model bookForTag:[model.tags objectAtIndex:0] atIndex:0]];
    
    // Create the combiners
    UINavigationController *navLib = [[UINavigationController alloc]initWithRootViewController:libraryVC];
    UINavigationController *navBook = [[UINavigationController alloc]initWithRootViewController:bookVC];
    
    // Create the UISplitVC with the other VCs
    UISplitViewController *splitVC = [[UISplitViewController alloc]init];
    splitVC.viewControllers = @[navLib,navBook];
    
    // Set delegates (the book will be the delegate for the UISplitVC and the tableVC)
    libraryVC.delegate = bookVC;
    splitVC.delegate = bookVC;
    
    // Set the UISplitVC as the root VC
    self.window.rootViewController = splitVC;
}

- (void)configureForPhoneWithModel:(DTCLibrary *)model{
    DTCLibraryTableViewController *libraryVC = [[DTCLibraryTableViewController alloc]initWithModel:model style:UITableViewStylePlain];

    // Auto-delegate
    libraryVC.delegate = libraryVC;
    
    // Create the combiner and add the library to it
    UINavigationController *navLib = [[UINavigationController alloc]initWithRootViewController:libraryVC];
    // Set as root view controller
    self.window.rootViewController = navLib;
    
    
}

@end
