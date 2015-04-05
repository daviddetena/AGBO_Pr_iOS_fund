//
//  DTCSandboxURL.m
//  HackerBooks
//
//  Created by David de Tena on 01/04/15.
//  Copyright (c) 2015 David de Tena. All rights reserved.
//

#import "DTCSandboxURL.h"

@implementation DTCSandboxURL

#pragma mark - Class methods

// Get the whole path to Documents folder including the filename
+ (NSURL *) URLToDocumentsFolderForFilename: (NSString *) aFilename{
    NSURL *url = [self URLToFolder:@"docs"];
    url = [url URLByAppendingPathComponent:aFilename];
    return url;
}

// Get the whole path to Docsuments folder including the filename
+ (NSURL *) URLToDocumentsCustomFolder: (NSString *) aFolder forFilename: (NSString *) aFilename{
    // Create new folder into Documents folder
    NSURL *url = [self URLToFolder:@"docs"];
    NSURL *newFolder = [url URLByAppendingPathComponent:aFolder];
    NSURL *path = nil;
    
    BOOL ec = NO;
    NSError *error;
    
    // Create a folder for the book images
    if (![[NSFileManager defaultManager] fileExistsAtPath:[newFolder path]]){
        ec = [[NSFileManager defaultManager] createDirectoryAtPath:[newFolder path]
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error];
        if (!ec) {
            path = [self URLToDocumentsFolderForFilename:aFilename];
        }
        else{
            path = [newFolder URLByAppendingPathComponent:aFilename];
        }
    }
    else{
        path = [newFolder URLByAppendingPathComponent:aFilename];
    }
    return path;
}

// Get the whole path to Docsuments folder including the filename
+ (NSURL *) URLToCacheCustomFolder: (NSString *) aFolder forFilename: (NSString *) aFilename{
    // Create new folder into Documents folder
    NSURL *url = [self URLToFolder:@"cache"];
    NSURL *newFolder = [url URLByAppendingPathComponent:aFolder];
    NSURL *path = nil;
    
    BOOL ec = NO;
    NSError *error;
    
    // Create a folder for the book images
    if (![[NSFileManager defaultManager] fileExistsAtPath:[newFolder path]]){
        ec = [[NSFileManager defaultManager] createDirectoryAtPath:[newFolder path]
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error];
        if (!ec) {
            path = [self URLToDocumentsFolderForFilename:aFilename];
        }
        else{
            path = [newFolder URLByAppendingPathComponent:aFilename];
        }
    }
    else{
        path = [newFolder URLByAppendingPathComponent:aFilename];
    }
    return path;
}

// Get the whole path to cache folder including the filename
+ (NSURL *) URLToCacheFolderForFilename: (NSString *) aFilename{
    NSURL *url = [self URLToFolder:@"cache"];
    url = [url URLByAppendingPathComponent:aFilename];
    return url;
}

// Get the path to <aFolder> folder in Sandbox
+ (NSURL *) URLToFolder: (NSString *) aFolder{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *url = nil;
    if ([aFolder isEqualToString:@"cache"]) {
        url = [[manager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    }
    else{
        // URL to /Documents by defaults
        url = [[manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    }
    return url;
}

// Get only the filename from a url
+ (NSString *) filenameFromURL: (NSURL *) aURL{
    NSArray *urlParts = [[aURL path] componentsSeparatedByString:@"/"];
    if ([urlParts lastObject]) {
        return [urlParts lastObject];
    }
    else{
        return [aURL absoluteString];
    }
}


@end
