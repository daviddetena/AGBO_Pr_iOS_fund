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
#import "Settings.h"

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

    [self configureView];
    [self syncModelWithView];
    
    // Add portrait view
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        [self addPortraitViewWithProperFrame];
    }
    
    // Suscribe to own notifications
    NSNotificationCenter *defCenter = [NSNotificationCenter defaultCenter];
    [defCenter addObserver:self selector:@selector(notifyThatBookDidToggleFavorite:) name:NOTIF_NAME_BOOK_TOGGLE_FAVORITE object:nil];
    
    // Suscribe to SimplePDF notifications
    [defCenter addObserver:self selector:@selector(notifyThatBookPdfURLDidChange:) name:NOTIF_NAME_URL_PDF_CHANGE object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // Unsuscribe from own notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Device orientation

// Add/remove portrait view when the device orientation changes
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) {
        // Portrait
        [self.portraitView removeFromSuperview];
    }
    else {
        // Landscape
        [self addPortraitViewWithProperFrame];
    }
}

// Set the frame to the view in order for it to resize
- (void)addPortraitViewWithProperFrame
{
    CGRect iPhoneScreen = [[UIScreen mainScreen] bounds];
    CGRect portraitRect = CGRectMake(0, 0, iPhoneScreen.size.height, iPhoneScreen.size.width);
    self.portraitView.frame = portraitRect;
    [self.view addSubview:self.portraitView];
}



#pragma mark - Memory
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

// Mark/unmark book as favorite
- (IBAction)toggleFavorite:(id)sender{
    self.model.isFavorite = !self.model.isFavorite;
    
    // Notify and update interface
    [self postNotificationBookDidToggleFavorite];
    [self updateUIForFavoriteStatus];
}

- (IBAction)displayPdfURL:(id)sender{
    DTCSimplePDFViewController *pdfVC = [[DTCSimplePDFViewController alloc]initWithModel:self.model];
    [self.navigationController pushViewController:pdfVC animated:YES];
}


#pragma mark - Utils

- (void) configureView{
    UIColor *bgColor = [UIColor colorWithRed:255.0/255.0 green:249.0/255.0 blue:240.0/255.0 alpha:1];
    [self.view setBackgroundColor:bgColor];
    
    // Make sure the view not to use the whole screen when embeded in combiners
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // Landscape
    self.titleLabel.numberOfLines = 0;
    self.authorsLabel.numberOfLines = 0;
    self.tagsLabel.numberOfLines = 0;
    
    
    // Portrait
    self.titleLabelPortrait.numberOfLines = 0;
    self.authorsLabelPortrait.numberOfLines = 0;
    self.tagsLabelPortrait.numberOfLines = 0;
    
    // Display or hide the button that shows the table in portrait mode on iPads
    if (!IS_IPHONE) {
        // For iPads, we puts the button that shows/hides the table
        self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    }
    
    [self syncModelWithView];
    
    /*
    // ajustamos los labels según su tamaño o reducimos la fuente en su caso ya que en el iPhone puede ocurrir que no quepa todo el texto
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    self.wineryNameLabel.adjustsFontSizeToFitWidth = YES;
    self.typeLabel.adjustsFontSizeToFitWidth = YES;
    self.originLabel.adjustsFontSizeToFitWidth = YES;
    [self.grapesLabel sizeToFit];
     */
    
    
}

- (void) syncModelWithView{
    // Landscape
    self.titleLabel.text = self.model.title;
    self.authorsLabel.text = [self.model stringOfItemsFromArray:self.model.authors];
    self.tagsLabel.text = [self.model stringOfItemsFromArray:self.model.tags];
    self.photoImageView.image = self.model.photo;
    
    // Portrait
    self.titleLabelPortrait.text = self.model.title;
    self.authorsLabelPortrait.text = [self.model stringOfItemsFromArray:self.model.authors];
    self.tagsLabelPortrait.text = [self.model stringOfItemsFromArray:self.model.tags];
    self.photoImageViewPortrait.image = self.model.photo;
    
    [self updateUIForFavoriteStatus];
}

// Set favorite button background image in relation to its state
- (void) updateUIForFavoriteStatus{
    UIImage *image = nil;
    if (self.model.isFavorite) {
        image = [UIImage imageNamed:@"favorite-filled"];
    }
    else{
        image = [UIImage imageNamed:@"favorite-outline"];
    }
    [self.favoriteButton setImage:image];
    [self.favoriteButtonPortrait setImage:image];
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

// Post notification to point the book was marked/unmarked as favorite (the table and pdf VC should suscribe to this)
- (void) postNotificationBookDidToggleFavorite{
    // Create a notification to let the others VC know that there was a change in the model
    NSNotification *not = [NSNotification notificationWithName:NOTIF_NAME_BOOK_TOGGLE_FAVORITE object:self userInfo:@{NOTIF_KEY_BOOK_FAVORITE:self.model}];
    // Send the notification
    [[NSNotificationCenter defaultCenter] postNotification:not];
}

// Notification received from DTCBookVC
- (void) notifyThatBookDidToggleFavorite: (NSNotification *) notification{
    [self updateUIForFavoriteStatus];
}


// Notification received from SimplePDFVC
- (void) notifyThatBookPdfURLDidChange: (NSNotification *) notification{
    // Get the book
    NSDictionary *dict = [notification userInfo];
    DTCBook *book = [dict objectForKey:NOTIF_KEY_URL_PDF_CHANGE];
    self.model = book;
}

@end
