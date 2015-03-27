//
//  DTCBook.h
//  HackerBooks
//
//  Created by David de Tena on 27/03/15.
//  Copyright (c) 2015 David de Tena. All rights reserved.
//
//  This class represents a book in the library

#import <Foundation/Foundation.h>

@interface DTCBook : NSObject

#pragma mark - Properties
@property (copy,nonatomic) NSString *title;
@property (strong,nonatomic) NSArray *authors;
@property (strong,nonatomic) NSArray *tags;
@property (strong,nonatomic) NSURL *photoURL;
@property (strong,nonatomic) NSURL *pdfURL;
@property (strong,nonatomic, readonly) UIImage *photo;
@property (nonatomic) BOOL favorite;

#pragma mark - Class init
+ (instancetype) bookWithTitle: (NSString *) aTitle
                       authors:(NSString *) stringOfAuthors
                          tags:(NSString *) stringOfTags
                      photoURL:(NSURL *) aPhotoURL
                        pdfURL:(NSURL *) aPdfURL;

#pragma mark - Instance init
// Designated
- (id) initWithTitle: (NSString *) aTitle
             authors:(NSString *) stringOfAuthors
                tags:(NSString *) stringOfTags
            photoURL:(NSURL *) aPhotoURL
              pdfURL:(NSURL *) aPdfURL;

#pragma mark - Utils
// Used to include every tag/author into a string that will be displayed
// in the Authors UILabel
-(NSString *) convertToString: (NSArray *) anArray;


@end
