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
    self.window = [[UIWindow alloc]
                   initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // First run => save key LAST_SELECTED_BOOK to be the first to be displayed when the app relaunches. download JSON
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *libraryArray = nil;
    if(![defaults objectForKey:LAST_SELECTED_BOOK]){
        // Set up for first launch
        libraryArray = [self configureModelForFirstLaunch];
        
        // Set default value: first element of second section (first is favorites)
        [defaults setObject:@[@1,@0] forKey:LAST_SELECTED_BOOK];
        
        // Save manually
        [defaults synchronize];
    }
    else{
        // Load data from Sandbox
        libraryArray = [self loadModelFromSandbox];
    }
    
    // Load the model of library (either from JSON or from Sandbox)
    DTCLibrary *library = [[DTCLibrary alloc]initWithArray:libraryArray];
    
    // Configure according the device
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [self configureForPadWithModel:library];
    }
    else{
        [self configureForPhoneWithModel:library];
    }
    
    // Override point for customization after application launch.
    //self.window.backgroundColor = [UIColor whiteColor];
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

- (void)configureForPhoneWithModel:(DTCLibrary *)model{
    DTCLibraryTableViewController *libraryVC = [[DTCLibraryTableViewController alloc]initWithModel:model style:UITableViewStylePlain];

    // Auto-delegate
    libraryVC.delegate = libraryVC;
    
    // Create the combiner and add the library to it
    UINavigationController *navLib = [[UINavigationController alloc]initWithRootViewController:libraryVC];
    // Set as root view controller
    self.window.rootViewController = navLib;
}

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
    return book;
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
//                    
//                    NSURL *imageURL = [NSURL URLWithString:[dict objectForKey:@"image_url"]];
//                    NSData *imageData = [NSData dataWithContentsOfURL:imageURL
//                                                              options:kNilOptions
//                                                                error:&error];
                    
                    if (!imageData) {
                        NSLog(@"Error %@ when fetching image '%@'", error.localizedDescription,[dict objectForKey:@"image_url"]);
                    }
                    else{
                        // Get local path for image and save it
                        NSURL *imageRemoteURL = [NSURL URLWithString:[dict objectForKey:@"image_url"]];
                        NSString *imageFilename = [imageRemoteURL lastPathComponent];
                                                 
                                                 
 //                       NSURL *localImage = [self localImageURLFromRemoteURL:imageRemoteURL];
                        [self saveImageInSandbox:imageData withFilename:imageFilename];
                        
                        // Update image_url path to local. Create a new dictionary for every book with its updated image_url and add to the new array of dictionaries
                        DTCBook *book = [[DTCBook alloc]initWithDictionary:dict];
                        
                        book.photoURL = [NSURL URLWithString:imageFilename];
                        NSDictionary *bookDictionary = [book proxyForJSON];
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


- (void) saveImageInSandbox: (NSData *) imageData withFilename: (NSString *) filename{
    // Save image in /Documents
//    NSURL *url = [self defaultSandboxURLForType:@"docs"];
//    url = [url URLByAppendingPathComponent:filename];
    NSURL *url = [DTCSandboxURL URLToDocumentsCustomFolder:@"images" forFilename:filename];
    NSError *error;
    BOOL ec = NO;
    
    // Save image in local directory
    ec = [imageData writeToURL:url
                       options:kNilOptions
                         error:&error];
    
    // Error when saving image
    if (ec==NO) {
        NSLog(@"Error %@. Couldn't save image at %@", error.localizedDescription,[url path]);
    }
    else{
        // Initialize every book with its local image path
        
        NSLog(@"Image successfully downloaded to %@", [url path]);
    }
}


#pragma mark - Sandbox
// NSURL with the default sandbox folder to save data (cache
- (NSURL *) defaultSandboxURLForType: (NSString *) aType{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *url = nil;
    
    if ([aType isEqualToString:@"docs"]) {
        url = [[manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        //NSLog(@"Documents folder");
    }
    else if ([aType isEqualToString:@"cache"]){
        url = [[manager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
        //NSLog(@"Caches folder");
    }
    else{
        // Save in tmp folder by default
        url = [[manager URLsForDirectory:NSDownloadsDirectory inDomains:NSUserDomainMask] lastObject];
        //NSLog(@"Downloads folder");
    }
    return url;
}




- (void) saveModelToSandbox: (NSData *) modelData{
    // Save JSON model in a file of the app Documents directory
//    NSURL *url = [self defaultSandboxURLForType:@"docs"];
//    url = [url URLByAppendingPathComponent:@"library.txt"];
//    
    NSURL *url = [DTCSandboxURL URLToDocumentsFolderForFilename:SANDBOX_MODEL_FILENAME];
    NSError *error;
    BOOL ec = NO;
    ec = [modelData writeToURL:url
                       options:kNilOptions
                         error:&error];
    if (!ec) {
        // Error when saving
        NSLog(@"Error when saving model to Sandbox: %@",error.localizedDescription);
    }
    else{
        // Saved successfully
        NSLog(@"JSON updated model saved successfully to sandbox");
    }
}

- (NSArray *) loadModelFromSandbox{
//    NSURL *url = [self defaultSandboxURLForType:@"docs"];
//    url = [url URLByAppendingPathComponent:@"library.txt"];
    
    NSURL *url = [DTCSandboxURL URLToDocumentsFolderForFilename:SANDBOX_MODEL_FILENAME];
    NSError *error;
    NSData *modelData = [NSData dataWithContentsOfURL:url
                                              options:kNilOptions
                                                error:&error];
    NSArray *libraryArray = nil;
    if (!modelData) {
        // Error when loading
        NSLog(@"Error when loading from Sandbox: %@",error.localizedDescription);
    }
    else{
        // Loaded successfully
        NSLog(@"JSON model successfully loaded from sandbox");
        // Convert this data into an array of Dictionaries
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

/*
- (NSString *) cleanRemoteURLString: (NSString *) remoteURLString{
    // Clean slashes from remote url filepath
    NSMutableString *path = [NSMutableString stringWithString:remoteURLString];
    [path deleteCharactersInRange:[path rangeOfString:@"http://"]];
    NSString *tmpStr = [path stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    
    return tmpStr;
}
*/




#pragma mark - Network

@end
