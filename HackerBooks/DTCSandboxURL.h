//
//  DTCSandboxURL.h
//  HackerBooks
//
//  Created by David de Tena on 01/04/15.
//  Copyright (c) 2015 David de Tena. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTCSandboxURL : NSURL

#pragma mark - Properties
@property (weak,nonatomic) NSString *filename;

#pragma mark - Class methods
+ (NSURL *) URLToDocumentsFolderForFilename: (NSString *) aFilename;
+ (NSURL *) URLToDocumentsCustomFolder: (NSString *) aFolder forFilename: (NSString *) aFilename;
+ (NSURL *) URLToCacheFolderForFilename: (NSString *) aFilename;
+ (NSURL *) URLToCacheCustomFolder: (NSString *) aFolder forFilename: (NSString *) aFilename;
+ (NSURL *) URLToFolder: (NSString *) aFolder;
+ (NSString *) filenameFromURL: (NSURL *) aURL;

@end
