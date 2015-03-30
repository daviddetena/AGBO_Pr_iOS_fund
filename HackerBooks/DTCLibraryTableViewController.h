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

@class DTCLibraryTableViewController;
//@class DTCLibrary;
//@class DTCBook;

#pragma mark - Custom protocol
@protocol DTCLibraryTableViewControllerDelegate <NSObject>

@optional
- (void) libraryTableViewController:(DTCLibraryTableViewController *) libraryVC
                      didSelectBook:(DTCBook *) aBook;
@end

@interface DTCLibraryTableViewController : UITableViewController

#pragma mark - Properties
// Library model and array of favorites
@property (strong,nonatomic) DTCLibrary *model;
@property (strong,nonatomic) NSMutableArray *favoriteBooks;
// Delegate => will be the DTCBookVC
@property (weak,nonatomic) id<DTCLibraryTableViewControllerDelegate> delegate;


#pragma mark - Instance init
- (id) initWithModel:(DTCLibrary *) model
               style:(UITableViewStyle) aStyle;

@end
