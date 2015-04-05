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
#import "Settings.h"
#import "DTCSandboxURL.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - App Lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Custom UI
    [self customizeAppearance];
    
    self.window = [[UIWindow alloc]
                   initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // First run => save key LAST_SELECTED_BOOK to be the first to be displayed when the app relaunches. Download JSON
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *libraryArray = nil;
    if(![defaults objectForKey:LAST_SELECTED_BOOK]){
        // Set up for first launch
        libraryArray = [self configureModelForFirstLaunch];
        
        // Set default value: first element of second section (first is favorites)
        [defaults setObject:@[@1,@0] forKey:LAST_SELECTED_BOOK];
        
        // Save manually
        [defaults synchronize];
        
        //NSLog(@"First launch: load from JSON");
    }
    else{
        // Not first launch: Load data from Sandbox
        libraryArray = [self loadModelFromSandbox];
        //NSLog(@"Not first launch: load from JSON");
    }
    
    // Load the model of library (JSON or Sandbox)
    DTCLibrary *library = [[DTCLibrary alloc]initWithArray:libraryArray];
    
    // Configure for the devices
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        //iPad
        [self configureForPadWithModel:library];
    }
    else{
        //iPhone
        [self configureForPhoneWithModel:library];
    }
    
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

#pragma mark - Init settings

// Custom UI
-(void)customizeAppearance{
    
    // Custom colors
    UIColor *darkOrangeColor = [UIColor colorWithRed:233.0/255.0 green:154.0/255.0 blue:50.0/255.0 alpha:1];
    UIColor *lightOrangeColor = [UIColor colorWithRed:255.0/255.0 green:210.0/255.0 blue:150.0/255.0 alpha:1];
    UIColor *whiteColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1];
    UIColor *lightGrayColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    UIColor *darkGrayColor = [UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1];
    
    // Shadow for the Navigation title
    NSShadow *titleShadow = [[NSShadow alloc]init];
    titleShadow.shadowColor = darkGrayColor;
    titleShadow.shadowOffset = CGSizeMake(1, 1);
    
    // Background and font for headers and footers of tables
    [[UITableViewHeaderFooterView appearance] setTintColor:lightOrangeColor];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont fontWithName:@"Avenir" size:16]];
    
    // Appearance for Navigation Bar
    [[UINavigationBar appearance] setBarTintColor:darkOrangeColor];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTintColor:lightGrayColor];
    NSDictionary *barTextAttributes = nil;
    
    // Appearance of the navigation bar's title for the devices
    if (IS_IPHONE) {
        barTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                             [UIFont fontWithName:@"Starjedi" size:14], NSFontAttributeName ,whiteColor, NSForegroundColorAttributeName, titleShadow, NSShadowAttributeName,nil];
        
    }
    else{
        barTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                             [UIFont fontWithName:@"Starjedi" size:20], NSFontAttributeName ,whiteColor, NSForegroundColorAttributeName, titleShadow, NSShadowAttributeName,nil];
        
    }
    [[UINavigationBar appearance] setTitleTextAttributes:barTextAttributes];
    
    // Tint color for toolbar
    [[UIToolbar appearance] setTintColor:darkOrangeColor];
    
}


- (NSArray *)configureModelForFirstLaunch{
    // Array of dictionaries with updated image path
    NSMutableArray *newJSONModel = nil;
    NSData *newJSONData = nil;
    
    // Get data from a remote resource via JSON
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:JSON_API_URL]];
    
    // Get response from server dealing with errors
    NSURLResponse *response = [[NSURLResponse alloc]init];
    NSError *error;
    NSData *modelData = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
    
    if (modelData!=nil) {
        id JSONObjects = [NSJSONSerialization JSONObjectWithData:modelData
                                                         options:kNilOptions
                                                           error:&error];
        if (JSONObjects!=nil) {
            // Data parsed successfully => Create an Array of NSDictionary
            if ([JSONObjects isKindOfClass:[NSArray class]]) {
                
                // Initialize new JSON model
                newJSONModel = [NSMutableArray arrayWithCapacity:[JSONObjects count]];
                
                for (NSDictionary *dict in JSONObjects) {
                    // Request image
                    NSURLRequest *imageURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[dict objectForKey:@"image_url"]]];
                    
                    // Get response from server dealing with errors
                    NSURLResponse *imageURLResponse = [[NSURLResponse alloc]init];
                    NSError *error;
                    NSData *imageData = [NSURLConnection sendSynchronousRequest:imageURLRequest
                                                              returningResponse:&imageURLResponse
                                                                          error:&error];
                    
                    if (!imageData) {
                        NSLog(@"Error %@ when fetching image '%@'", error.localizedDescription,[dict objectForKey:@"image_url"]);
                    }
                    else{
                        // Get local path for image and save it
                        NSURL *imageRemoteURL = [NSURL URLWithString:[dict objectForKey:@"image_url"]];
                        NSString *imageFilename = [DTCSandboxURL filenameFromURL:imageRemoteURL];
                        [self saveImageToSandbox:imageData withFilename:imageFilename];
                        
                        // Update image_url path to local. Create a new dictionary for every book with its updated image_url and add to the new array of dictionaries
                        DTCBook *book = [[DTCBook alloc]initWithDictionary:dict];
                        DTCBook *newBook = [[DTCBook alloc] initWithTitle:book.title
                                                                  authors:[book stringOfItemsFromArray:book.authors]
                                                               isFavorite: NO
                                                                     tags:[book stringOfItemsFromArray:book.tags]
                                                                 photoURL:[NSURL URLWithString:imageFilename]
                                                                   pdfURL:book.pdfURL];
                        
                        NSDictionary *bookDictionary = [newBook proxyForJSON];
                        [newJSONModel addObject:bookDictionary];
                        
                        // Parse the array of dictionaries as JSON and save it in /Documents
                        newJSONData = [NSJSONSerialization dataWithJSONObject:newJSONModel
                                                                      options:NSJSONWritingPrettyPrinted
                                                                        error:&error];
                        if (newJSONModel == nil) {
                            NSLog(@"Error %@ when parsing new model to JSON", error.localizedDescription);
                        }
                    }
                }
            }
            // Save updated library model (via JSON) in Sandbox
            [self saveModelToSandbox:newJSONData];
        }
        else{
            NSLog(@"Error while parsing JSON: %@",error.localizedDescription);
        }
    }
    else{
        // No data or error
        NSLog(@"Error while downloading JSON from server: %@",error.localizedDescription);
    }
    // Return the array of dictionaries with the updated image_url
    return newJSONModel;
}


// Settings for iPads
- (void)configureForPadWithModel:(DTCLibrary *)model{
    // Create the VCs. Select the book saved in NSUserDefaults as the first to be displayed
    DTCLibraryTableViewController *libraryVC = [[DTCLibraryTableViewController alloc]initWithModel:model style:UITableViewStylePlain];
    DTCBookViewController *bookVC = [[DTCBookViewController alloc] initWithModel:[self lastSelectedBookInModel:model]];
    
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


// Settings for iPhones
- (void)configureForPhoneWithModel:(DTCLibrary *)model{
    DTCLibraryTableViewController *libraryVC = [[DTCLibraryTableViewController alloc]initWithModel:model style:UITableViewStylePlain];
    
    // Auto-delegate
    libraryVC.delegate = libraryVC;
    
    // Create the combiner and add the library to it
    UINavigationController *navLib = [[UINavigationController alloc]initWithRootViewController:libraryVC];
    // Set as root view controller
    self.window.rootViewController = navLib;
}


// Get last selected book to be the first to be displayed
- (DTCBook *)lastSelectedBookInModel: (DTCLibrary *) library{
    // Get the saved coords of the last book
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *coords = [defaults objectForKey:LAST_SELECTED_BOOK];
    NSUInteger section = [[coords objectAtIndex:0] integerValue];
    NSUInteger pos = [[coords objectAtIndex:1] integerValue];
    
    // Select the book of these coords
    DTCBook *book = nil;
    if (section>0) {
        book = [library bookForTag:[library.tags objectAtIndex:section-1] atIndex:pos];
    }
    else{
        // VER CUAL DE LOS FAVORITOS ES EL QUE SE MOSTRABA
    }
    return book;
}


#pragma mark - Sandbox

// Save image to sandbox
- (void) saveImageToSandbox: (NSData *) imageData withFilename: (NSString *) filename{
    
    // Save image in /Documents/Images
    NSURL *url = [DTCSandboxURL URLToCacheCustomFolder:@"Images" forFilename:filename];
    NSError *error;
    BOOL ec = NO;
    
    // Save image in local directory
    ec = [imageData writeToURL:url
                       options:kNilOptions
                         error:&error];
    
    // Error when saving image
    if (ec==NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                        message:@"Error while saving image to disk"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Done", nil];
        [alert show];
    }
}


// Save the model in JSON to sandbox
- (void) saveModelToSandbox: (NSData *) modelData{

    NSURL *url = [DTCSandboxURL URLToDocumentsFolderForFilename:SANDBOX_MODEL_FILENAME];
    NSError *error;
    BOOL ec = NO;
    ec = [modelData writeToURL:url
                       options:kNilOptions
                         error:&error];
    if (!ec) {
        // Error when saving
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                        message:@"Error while saving model to disk"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Done", nil];
        [alert show];
    }
}


// Load the library model from disk in an Array
- (NSArray *) loadModelFromSandbox{
    
    NSURL *url = [DTCSandboxURL URLToDocumentsFolderForFilename:SANDBOX_MODEL_FILENAME];
    NSError *error;
    NSData *modelData = [NSData dataWithContentsOfURL:url
                                              options:kNilOptions
                                                error:&error];
    NSArray *libraryArray = nil;
    if (!modelData) {
        // Error when loading
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                        message:@"Error while loading library model from Sandbox"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Done", nil];
        [alert show];
    }
    else{
        // Loaded. Convert this data into an array of Dictionaries
        id JSONObjects = [NSJSONSerialization JSONObjectWithData:modelData
                                                         options:kNilOptions
                                                           error:&error];
        // Data parsed successfully => Create an Array of NSDictionary
        if ([JSONObjects isKindOfClass:[NSArray class]]) {
            libraryArray = [NSArray arrayWithArray:JSONObjects];
        }
    }
    return libraryArray;
}

@end
