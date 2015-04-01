//
//  DTCBook.m
//  HackerBooks
//
//  Created by David de Tena on 27/03/15.
//  Copyright (c) 2015 David de Tena. All rights reserved.
//

@import UIKit;
#import "DTCBook.h"
#import "DTCSandboxURL.h"

@implementation DTCBook

// When a readonly property is created and a custom getter is coded, like in this case,
// the compiler assumes that you will not need an instance variable. But we do need it here,
// so we have to tell it to include the variable, with @synthesize
@synthesize photo = _photo;

#pragma mark - Properties

-(UIImage *)photo{
    // This will block the app and should be run in background.
    // At the moment, we do not know how to do that
    
    // Lazy load: image loaded only if needed
    if(_photo==nil){
        _photo = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.photoURL]];
    }
    return _photo;
}

#pragma mark - Class ("factory") init
// Main class method
+ (instancetype) bookWithTitle:(NSString *)aTitle
                       authors:(NSString *)stringOfAuthors
                          tags:(NSString *)stringOfTags
                      photoURL:(NSURL *)aPhotoURL
                        pdfURL:(NSURL *)aPdfURL{
    
    return [[self alloc] initWithTitle:aTitle
                               authors:stringOfAuthors
                                  tags:stringOfTags
                              photoURL:aPhotoURL
                                pdfURL:aPdfURL];
}


#pragma mark - Instance init
// Main init
- (id) initWithTitle:(NSString *) aTitle
             authors:(NSString *) stringOfAuthors
                tags:(NSString *) stringOfTags
            photoURL:(NSURL *) aPhotoURL
              pdfURL:(NSURL *) aPdfURL{
    
    if(self = [super init]){
        _title = aTitle;
        _authors = [self extractItemsFromString:stringOfAuthors];
        _tags = [self extractItemsFromString:stringOfTags];
        _photoURL = aPhotoURL;
        _pdfURL = aPdfURL;
    }
    return self;
}

// Init from a dictionary
- (id) initWithDictionary: (NSDictionary *) aDictionary{
    return [self initWithTitle:[aDictionary objectForKey:@"title"]
                       authors:[aDictionary objectForKey:@"authors"]
                          tags:[aDictionary objectForKey:@"tags"]
                      photoURL:[DTCSandboxURL URLToDocumentsCustomFolder:@"images" forFilename:[aDictionary objectForKey:@"image_url"]]
                        pdfURL:[NSURL URLWithString:[aDictionary objectForKey:@"pdf_url"]]];
}

#pragma mark - Utils

// Utility method to extrac authors/tags from NSString and add to an array
-(NSArray *) extractItemsFromString: (NSString *)string{
    NSArray *arrayStrings = [string componentsSeparatedByString:@", "];
    return arrayStrings;
}

// Returns a string containing all the objects in the array, separated by comma
-(NSString *) stringOfItemsFromArray: (NSArray *) anArray{
    NSString *string = @"";
    for (NSString *str in anArray) {
        string = [string stringByAppendingString:str];
        string = [string stringByAppendingString:@", "];
    }
    NSString *stringOfItems = [string substringWithRange:NSMakeRange(0,[string length]-2)];
    return stringOfItems;
}

- (NSString *) urlPathWithBackslashesDeletedFromPath: (NSURL *) aPath{
    // Clean slashes from remote url filepath
    NSMutableString *path = [NSMutableString stringWithString:[aPath absoluteString]];
    NSString *clearPath = [path stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    
    return clearPath;
}

#pragma mark - JSON
// Turn an object of this class into a NSDictionary to use it to create a JSON
- (NSDictionary *) proxyForJSON{
    return @{@"title"       : self.title,
             @"authors"     : [self stringOfItemsFromArray:self.authors],
             @"tags"        : [self stringOfItemsFromArray:self.tags],
             @"image_url"   : [self urlPathWithBackslashesDeletedFromPath:self.photoURL],
             @"pdf_url"     : [self urlPathWithBackslashesDeletedFromPath:self.pdfURL]};
}

@end
