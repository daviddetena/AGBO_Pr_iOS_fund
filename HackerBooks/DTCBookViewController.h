//
//  DTCBookViewController.h
//  HackerBooks
//
//  Created by David de Tena on 27/03/15.
//  Copyright (c) 2015 David de Tena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTCLibraryTableViewController.h"

#define NOTIF_NAME_BOOK_TOGGLE_FAVORITE @"bookToggleFavorite"
#define NOTIF_KEY_BOOK_FAVORITE @"bookFavorite"

// Forward declaration
@class DTCBook;

@interface DTCBookViewController : UIViewController<UISplitViewControllerDelegate, DTCLibraryTableViewControllerDelegate>

#pragma mark - Properties
@property (weak,nonatomic) IBOutlet UILabel *titleLabel;
@property (weak,nonatomic) IBOutlet UILabel *authorsLabel;
@property (weak,nonatomic) IBOutlet UILabel *tagsLabel;
@property (weak,nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak,nonatomic) IBOutlet UIBarButtonItem *favoriteButton;
@property (strong,nonatomic) DTCBook *model;


#pragma mark - Instance init
- (id) initWithModel: (DTCBook *) aModel;

#pragma mark - Actions
- (IBAction)toggleFavorite:(id)sender;
- (IBAction)displayPdfURL:(id)sender;

@end
