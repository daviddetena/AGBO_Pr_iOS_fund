//
//  DTCBook.m
//  HackerBooks
//
//  Created by David de Tena on 27/03/15.
//  Copyright (c) 2015 David de Tena. All rights reserved.
//

@import UIKit;
#import "DTCBook.h"

@implementation DTCBook

// When a readonly property is created and you implement a custom getter, like in this case,
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
- (id) initWithTitle:(NSString *) aTitle
             authors:(NSString *) stringOfAuthors
                tags:(NSString *) stringOfTags
            photoURL:(NSURL *) aPhotoURL
              pdfURL:(NSURL *) aPdfURL{
    
    if(self = [super init]){
        _title = aTitle;
        _authors = [self extractFromString:stringOfAuthors];
        _tags = [self extractFromString:stringOfTags];
        _photoURL = aPhotoURL;
        _pdfURL = aPdfURL;
    }
    return self;
}

#pragma mark - Utils

// Utility method to extrac authors/tags from NSString and add to an array
-(NSArray *) extractFromString: (NSString *)string{
    NSArray *arrayStrings = [string componentsSeparatedByString:@", "];
    return arrayStrings;
}

// Returns a string containing all the objects in the array, separated by comma
-(NSString *) convertToString: (NSArray *) anArray{
    NSString *string = @"";
    for (NSString *str in anArray) {
        string = [string stringByAppendingString:str];
        string = [string stringByAppendingString:@", "];
    }
    return string;
}

@end
