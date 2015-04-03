//
//  DTCBookViewController.m
//  HackerBooks
//
//  Created by David de Tena on 27/03/15.
//  Copyright (c) 2015 David de Tena. All rights reserved.
//

#import "DTCBookViewController.h"
#import "DTCBook.h"
#import "DTCSimplePDFViewController.h"
#import "DTCLibraryTableViewController.h"

@implementation DTCBookViewController

#pragma mark - Instance init
- (id) initWithModel:(DTCBook *) aModel{
    if (self = [super initWithNibName:nil
                               bundle:nil]) {
        _model = aModel;
        self.title = aModel.title;
    }
    return self;
}

#pragma mark - View Lifecycle
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // Display or hide the button that shows the table in portrait mode on iPads
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    
    // Suscribe to own notifications
    NSNotificationCenter *defCenter = [NSNotificationCenter defaultCenter];
    [defCenter addObserver:self selector:@selector(notifyThatBookDidToggleFavorite:) name:NOTIF_NAME_BOOK_TOGGLE_FAVORITE object:nil];
    
    // Suscribe to SimplePDF notifications
    [defCenter addObserver:self selector:@selector(notifyThatBookPdfURLDidChange:) name:NOTIF_NAME_URL_PDF_CHANGE object:nil];
    
    
    [self syncModelWithView];
    NSLog(@"PDF path in Book: %@", [self.model.pdfURL absoluteString]);
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // Unsuscribe from own notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Memory
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions
- (IBAction)toggleFavorite:(id)sender{
    self.model.favorite = !self.model.favorite;
    //NSLog(@"Favorite = %d", self.model.favorite);
    
    [self postNotificationBookDidToggleFavorite];
    [self updateFavoriteStatus];
}

- (IBAction)displayPdfURL:(id)sender{
    DTCSimplePDFViewController *pdfVC = [[DTCSimplePDFViewController alloc]initWithModel:self.model];
    [self.navigationController pushViewController:pdfVC animated:YES];
}


#pragma mark - Utils
- (void) syncModelWithView{
    self.titleLabel.text = self.model.title;
    self.authorsLabel.text = [self.model stringOfItemsFromArray:self.model.authors];
    self.tagsLabel.text = [self.model stringOfItemsFromArray:self.model.tags];
    
    self.titleLabel.numberOfLines = 0;
    self.authorsLabel.numberOfLines = 0;
    self.tagsLabel.numberOfLines = 0;
    
    self.photoImageView.image = self.model.photo;
    [self updateFavoriteStatus];
}

// Set favourite button background image regarding its state
- (void) updateFavoriteStatus{
    UIImage *image = nil;
    if (self.model.favorite) {
        image = [UIImage imageNamed:@"favorite-filled"];
    }
    else{
        image = [UIImage imageNamed:@"favorite-outline"];
    }
    [self.favoriteButton setImage:image];
}

#pragma mark - UISplitViewControllerDelegate
// Display or hide the button that shows the table in portrait mode on iPads
- (void) splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode{
    
    // Check out if the table is visible
    if (displayMode==UISplitViewControllerDisplayModePrimaryHidden) {
        // Table hidden => show button on the navigation
        self.navigationItem.leftBarButtonItem = svc.displayModeButtonItem;
    }
    else{
        // Table visible => Hide split button
        self.navigationItem.leftBarButtonItem = nil;
    }
}


#pragma mark - DTCLibraryTableViewControllerDelegate
// Implements custom protocol method of the table view
- (void) libraryTableViewController:(DTCLibraryTableViewController *) libraryVC didSelectBook:(DTCBook *) aBook{
    // Update the model
    self.title = aBook.title;
    self.model = aBook;
    [self syncModelWithView];
}



#pragma mark - Notifications
- (void) postNotificationBookDidToggleFavorite{
    // Create a notification to let the others VC know that there was a change in the model
    NSNotification *not = [NSNotification notificationWithName:NOTIF_NAME_BOOK_TOGGLE_FAVORITE object:self userInfo:@{NOTIF_KEY_BOOK_FAVORITE:self.model}];
    // Send the notification
    [[NSNotificationCenter defaultCenter] postNotification:not];
}

// Notification received from DTCBookVC
- (void) notifyThatBookDidToggleFavorite: (NSNotification *) notification{
    [self updateFavoriteStatus];
}


// Notification received from SimplePDFVC
- (void) notifyThatBookPdfURLDidChange: (NSNotification *) notification{
    // Get the book
    NSDictionary *dict = [notification userInfo];
    DTCBook *book = [dict objectForKey:NOTIF_KEY_URL_PDF_CHANGE];
    self.model = book;
    
    NSLog(@"notifyThatBookPdfURLDidChange in DTCBookVC. New pdf url: %@", [self.model.pdfURL path]);
    //[self syncModelWithView];
}

@end
