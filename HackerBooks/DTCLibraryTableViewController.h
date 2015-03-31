//
//  DTCLibraryTableViewController.h
//  HackerBooks
//
//  Created by David de Tena on 30/03/15.
//  Copyright (c) 2015 David de Tena. All rights reserved.
//
//  TableViewController used to display the Library model

#import <UIKit/UIKit.h>
#import "DTCBook.h"
#import "DTCLibrary.h"

#define NOTIF_NAME_BOOK_SELECTED_PDF_URL @"newBookPdfURL"
#define NOTIF_KEY_BOOK @"book"

@class DTCLibraryTableViewController;

#pragma mark - Custom protocol
@protocol DTCLibraryTableViewControllerDelegate <NSObject>

@optional
- (void) libraryTableViewController:(DTCLibraryTableViewController *) libraryVC
                      didSelectBook:(DTCBook *) aBook;
@end

// Auto-delegate
@interface DTCLibraryTableViewController : UITableViewController<DTCLibraryTableViewControllerDelegate>

#pragma mark - Properties
// Library model and array of favorites
@property (strong,nonatomic) DTCLibrary *model;
@property (strong,nonatomic) NSMutableArray *favoriteBooks;
// Delegate => will be the DTCBookVC for iPad and self for iPhone
@property (weak,nonatomic) id<DTCLibraryTableViewControllerDelegate> delegate;


#pragma mark - Instance init
- (id) initWithModel:(DTCLibrary *) model
               style:(UITableViewStyle) aStyle;

@end
