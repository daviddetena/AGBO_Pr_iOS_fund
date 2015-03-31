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
@property (strong,nonatomic) NSArray *books;
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
        DTCBook *book1 = [[DTCBook alloc] initWithTitle:@"Pro Git"
                                                authors:@"Scott Chacon, Ben Straub"
                                                   tags:@"version control, git"
                                               photoURL:[NSURL URLWithString:@"http://hackershelf.com/media/cache/b4/24/b42409de128aa7f1c9abbbfa549914de.jpg"]
                                                 pdfURL:[NSURL URLWithString:@"https://progit2.s3.amazonaws.com/en/2015-03-06-439c2/progit-en.376.pdf"]];
        
        DTCBook *book2 = [[DTCBook alloc] initWithTitle:@"Eloquent Javascript"
                                                authors:@"Marijn Haverbeke"
                                                   tags:@"javascript"
                                               photoURL:[NSURL URLWithString:@"http://hackershelf.com/media/cache/e5/27/e527064919530802af898a4798318ab9.jpg"]
                                                 pdfURL:[NSURL URLWithString:@"http://eloquentjavascript.net/Eloquent_JavaScript.pdf"]];
        
        DTCBook *book3 = [[DTCBook alloc] initWithTitle:@"Think Complexity"
                                                authors:@"Allen B. Downey"
                                                   tags:@"programming, python, data structures"
                                               photoURL:[NSURL URLWithString:@"http://hackershelf.com/media/cache/97/bf/97bfce708365236e0a5f3f9e26b4a796.jpg"]
                                                 pdfURL:[NSURL URLWithString:@"http://greenteapress.com/compmod/thinkcomplexity.pdf"]];
        
        DTCBook *book4 = [[DTCBook alloc] initWithTitle:@"Think Python"
                                                authors:@"Allen B. Downey "
                                                   tags:@"python, cs"
                                               photoURL:[NSURL URLWithString:@"http://hackershelf.com/media/cache/f3/fe/f3fec7d794709480759e9b311fb7f2ec.jpg"]
                                                 pdfURL:[NSURL URLWithString:@"http://greenteapress.com/thinkpython/thinkpython.pdf"]];
        // Save books in the array
        self.books = @[book1,book2,book3,book4];
        self.auxTags = [[NSMutableArray alloc]init];
        [self addTagsFromArray: [book1 tags]];
        [self addTagsFromArray: [book2 tags]];
        [self addTagsFromArray: [book3 tags]];
        [self addTagsFromArray: [book4 tags]];
        
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
