//
//  DTCLibrary.m
//  HackerBooks
//
//  Created by David de Tena on 30/03/15.
//  Copyright (c) 2015 David de Tena. All rights reserved.
//

#import "DTCLibrary.h"
#import "DTCBook.h"

@interface DTCLibrary ()

// Array with all the books
@property (strong,nonatomic) NSMutableArray *books;
@property (strong,nonatomic) NSMutableArray *auxTags;

@end


@implementation DTCLibrary

#pragma mark - Properties
// Total number of books
- (NSUInteger) booksCount{
    return [self.books count];
}

// Array of tags in the library
- (NSArray *) tags{
    return [NSArray arrayWithArray:[self.auxTags sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
}


#pragma mark - Class init

#pragma mark - Instance init
- (id) init{
    if(self = [super init]){
        // Initialize model
        
        // Get data from a remote resource via JSON
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://keepcodigtest.blob.core.windows.net/containerblobstest/books_readable.json"]];
        
        // Get response from server dealing with errors
        NSURLResponse *response = [[NSURLResponse alloc]init];
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];
        if (data!=nil) {
            // There is data
            id JSONObjects = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&error];
            if (JSONObjects!=nil) {
                // Data parsed successfully => Create an Array of NSDictionary
                if ([JSONObjects isKindOfClass:[NSArray class]]) {
                    self.books = [NSMutableArray arrayWithCapacity:[JSONObjects count]];
                    self.auxTags = [[NSMutableArray alloc]init];
                    
                    // Check out if data was parsed as NSArray of NSDictionary
                    for (NSDictionary *dict in JSONObjects) {
                        // Create books from dictionary. Add the books and new tags from them to the library
                        DTCBook *book = [[DTCBook alloc] initWithDictionary:dict];
                        [self.books addObject:book];
                        [self addTagsFromArray:book.tags];
                    }
                }
            }
            else{
                NSLog(@"Error while parsin JSON: %@",error.localizedDescription);
            }
        }
        else{
            // No data or error
            NSLog(@"Error while downloading JSON from server: %@",error.localizedDescription);
        }
    }
    return self;
}

#pragma mark - Instance methods

// Number of books with a specific tag
- (NSUInteger) bookCountForTag: (NSString *) tag{
    if(![self.tags containsObject:tag]){
        return 0;
    }
    return [[self booksForTag:tag] count];
}

// Array with the books of a specific tag
- (NSArray *) booksForTag: (NSString *) tag{
    NSMutableArray *arrayOfBooks = [NSMutableArray arrayWithCapacity:[self.books count]];
    for (DTCBook *book in self.books) {
        for (NSString *each in book.tags) {
            if ([each isEqualToString:tag]) {
                [arrayOfBooks addObject:book];
            }
        }
    }
    if ([arrayOfBooks count]==0) {
        return nil;
    }
    
    // Set a custom sort rule to sort books by title
    NSSortDescriptor *firstDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:firstDescriptor, nil];
    NSArray *sortedBooks = [arrayOfBooks sortedArrayUsingDescriptors:sortDescriptors];
    return sortedBooks;
}

// Book at a specified index with a specific tag. Returns nil if index or
- (DTCBook *) bookForTag: (NSString *) tag atIndex: (NSUInteger) index{
    
    if((index>= [[self booksForTag:tag] count]) || ![self.tags containsObject:tag]){
        return nil;
    }
    return [[self booksForTag:tag] objectAtIndex:index];
}

#pragma mark - Utils
// Save every new tag in the aux array
- (void) addTagsFromArray: (NSArray *) arrayOfTags{
    for (NSString *str in arrayOfTags) {
        if(![self.auxTags containsObject:str]){
            [self.auxTags addObject:str];
        }
    }
}

@end
