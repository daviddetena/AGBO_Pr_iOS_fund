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
    [self syncModelWithView];
    
}

#pragma mark - Memory
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions
- (IBAction)toggleFavorite:(id)sender{
    self.model.favorite = !self.model.favorite;
    NSLog(@"Favorite = %d", self.model.favorite);
    [self setFavoriteImage];
    
}

- (IBAction)displayPdfURL:(id)sender{
    DTCSimplePDFViewController *pdfVC = [[DTCSimplePDFViewController alloc]initWithModel:self.model];
    [self.navigationController pushViewController:pdfVC animated:YES];
}


#pragma mark - Utils
- (void) syncModelWithView{
    self.titleLabel.text = self.model.title;
    self.authorsLabel.text = [self.model convertToString:self.model.authors];
    self.tagsLabel.text = [self.model convertToString:self.model.tags];
    self.photoImageView.image = self.model.photo;
    
    [self setFavoriteImage];
}

// Set favourite button background image regarding its state
- (void)setFavoriteImage{
    UIImage *image = nil;
    if (self.model.favorite) {
        image = [UIImage imageNamed:@"favorite-filled"];
    }
    else{
        image = [UIImage imageNamed:@"favorite-outline"];
    }
    [self.favoriteButton setImage:image forState:UIControlStateNormal];
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
// Implements the protocol method for the table view
- (void) libraryTableViewController:(DTCLibraryTableViewController *) libraryVC didSelectBook:(DTCBook *) aBook{
    // Update the model
    self.title = aBook.title;
    self.model = aBook;
    [self syncModelWithView];
}


@end
