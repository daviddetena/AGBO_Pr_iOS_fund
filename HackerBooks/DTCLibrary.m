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
@property (strong,nonatomic) NSMutableArray *auxBooks;
@property (strong,nonatomic) NSMutableArray *auxTags;

@end


@implementation DTCLibrary

#pragma mark - Properties

// Retrive the books sorted alphabetically
- (NSArray *) books{
    // Set a custom sort rule to sort books by title
    NSSortDescriptor *firstDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:firstDescriptor, nil];
    NSArray *sortedBooks = [self.auxBooks sortedArrayUsingDescriptors:sortDescriptors];
    return sortedBooks;

}

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
- (id) initWithArray:(NSArray *)arrayOfModels{
    if (self = [super init]) {
        // Init books and tags arrays
        self.auxBooks = [NSMutableArray arrayWithCapacity:[arrayOfModels count]];
        self.auxTags = [[NSMutableArray alloc]init];
        
        for (NSDictionary *dict in arrayOfModels) {
            // Create books from dictionary. Add the books and new tags from them to the library
            DTCBook *book = [[DTCBook alloc] initWithDictionary:dict];
            [self.auxBooks addObject:book];
            [self addTagsFromArray:book.tags];
        }
        //_books = [NSArray arrayWithArray:self.auxBooks];
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

#pragma mark - JSON
// Turn an object of this class into a NSArray of NSDictionary to use it to create a JSON
- (NSArray *) proxyForJSON{
    NSMutableArray *arrayOfBooks = [NSMutableArray arrayWithCapacity:self.booksCount];
    for (DTCBook *book in self.books) {
        NSDictionary *dict = [book proxyForJSON];
        [arrayOfBooks addObject:dict];
    }
    return arrayOfBooks;
}



@end
