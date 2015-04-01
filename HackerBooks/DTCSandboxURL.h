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
// Class init
/*
+ (instancetype) sandboxURLWithString: (NSString *) URLString;
+ (instancetype) sandboxURLWithFilename: (NSString *) aFilename;
 */
+ (NSURL *) urlToDocumentsFolder: (NSString *) aFilename;
+ (NSURL *) urlToCacheFolder: (NSString *) aFilename;
+ (NSURL *) URLToFolder: (NSString *) aFolder;

#pragma mark - Init
/*
- (id) initWithString:(NSString *) URLString;
- (id) initWithFilename:(NSString *) aFilename;
 */

@end
