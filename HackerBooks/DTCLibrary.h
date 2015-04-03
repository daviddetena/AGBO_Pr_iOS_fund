//
//  DTCLibrary.h
//  HackerBooks
//
//  Created by David de Tena on 30/03/15.
//  Copyright (c) 2015 David de Tena. All rights reserved.
//
//  This model represents a library of books

#import <Foundation/Foundation.h>

// Forward declaration
@class DTCBook;


@interface DTCLibrary : NSObject

#pragma mark - Properties
@property (strong, nonatomic) NSArray *books;
@property (nonatomic) NSUInteger booksCount;
@property (strong, nonatomic) NSArray *tags;


#pragma mark - Class init


#pragma mark - Instance init
- (id) initWithArray: (NSArray *) arrayOfModels;


#pragma mark - Instance methods
// Number of books with a specific tag
- (NSUInteger) bookCountForTag: (NSString *) tag;
// Array with the books of a specific tag
- (NSArray *) booksForTag: (NSString *) tag;
// Book at a specified index with a specific tag
- (DTCBook *) bookForTag: (NSString *) tag atIndex: (NSUInteger) index;

#pragma mark - JSON
// Turn an object of this class into a NSArray of NSDictionary to use it to create a JSON
- (NSArray *) proxyForJSON;


@end
