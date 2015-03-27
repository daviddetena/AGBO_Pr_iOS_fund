//
//  DTCBookViewController.m
//  HackerBooks
//
//  Created by David de Tena on 27/03/15.
//  Copyright (c) 2015 David de Tena. All rights reserved.
//

#import "DTCBookViewController.h"
#import "DTCBook.h"

@interface DTCBookViewController ()
@end

@implementation DTCBookViewController

#pragma mark - Synthetize


#pragma mark - Instance init
- (id) initWithModel:(DTCBook *) aModel{
    if (self = [super initWithNibName:nil
                               bundle:nil]) {
        _model = aModel;
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

}


#pragma mark - Utils
- (void) syncModelWithView{
    self.title = self.model.title;
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
