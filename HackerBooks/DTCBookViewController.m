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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self syncModelWithView];
    
}

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


@end
