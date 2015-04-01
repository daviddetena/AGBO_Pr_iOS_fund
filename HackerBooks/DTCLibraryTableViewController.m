//
//  DTCLibraryTableViewController.m
//  HackerBooks
//
//  Created by David de Tena on 30/03/15.
//  Copyright (c) 2015 David de Tena. All rights reserved.
//

#import "DTCLibraryTableViewController.h"
#import "DTCBook.h"
#import "DTCBookViewController.h"
#import "DTCLibrary.h"
#import "Settings.h"

@import UIKit;


@implementation DTCLibraryTableViewController

#pragma mark - Instance init
- (id) initWithModel:(DTCLibrary *)model style:(UITableViewStyle)aStyle{
    if(self = [super initWithStyle:aStyle]){
        _model = model;
        _favoriteBooks = [NSMutableArray arrayWithCapacity:0];
        self.title = @"Nerds library";
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Suscribe to notification the book sends when toggling its favorite status
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(notifyThatBookDidToggleFavorite:) name:NOTIF_NAME_BOOK_TOGGLE_FAVORITE object:nil];
}


#pragma mark - Memory
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    // Unsuscribe from notifications when deallocating
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


#pragma mark - Table view data source
// The table will have as much sections as tags in the library and one more for favorites
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return ([self.model.tags count] + 1);
}

// Number of rows in section will be bookCountForTag: method in the library model
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // First section is for favorites
    if (section==0) {
        return [self.favoriteBooks count];
    }
    else{
        return [self.model bookCountForTag:[self.model.tags objectAtIndex:section-1]];
    }
}

// The title of every row will be the proper tag
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return @"Favorites";
    }
    else{
        return [self.model.tags objectAtIndex:section -1];
    }
}

// The footer will be the number of books for every tag
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (section == 0) {
        if ([self.favoriteBooks count]==0) {
            return @"No favorites in the library";
        }
        else{
            if([self.favoriteBooks count]==1){
                return [NSString stringWithFormat:@"%ld book",(unsigned long)[self.favoriteBooks count]];
            }
            else{
                return [NSString stringWithFormat:@"%ld books",(unsigned long)[self.favoriteBooks count]];
            }
        }
    }
    else{
        if([self.model bookCountForTag:[self.model.tags objectAtIndex:section-1]]==1){
            return [NSString stringWithFormat:@"%ld book",(unsigned long)[self.model bookCountForTag:[self.model.tags objectAtIndex:section-1]]];
        }
        else{
            return [NSString stringWithFormat:@"%ld books",(unsigned long)[self.model bookCountForTag:[self.model.tags objectAtIndex:section-1]]];
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // Book model
    DTCBook *book = [self bookAtIndexPath:indexPath];
    
    // Create the cell, initialized once and reused every time this method is called
    static NSString *cellId = @"BookCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil) {
        // Create a new cell by hand
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    // Configure cell
    cell.imageView.image = book.photo;
    cell.textLabel.text = book.title;
    cell.detailTextLabel.text = [book stringOfItemsFromArray:book.authors];
    
    // Return cell with the book
    return cell;
}

#pragma mark - Table view delegate
// Show the book of the current indexPath
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Get the current selected book
    DTCBook *book = [self bookAtIndexPath:indexPath];
    
    // Notify the delegate (book model) that the model has changed (only if the delegate understands the message [implements it])
    if([self.delegate respondsToSelector:@selector(libraryTableViewController:didSelectBook:)]){
        [self.delegate libraryTableViewController:self didSelectBook:book];
    }
    
    // Notify the PDFViewer through notifications that the model has changed. Send the new selected book
    NSNotification *notification = [NSNotification notificationWithName:NOTIF_NAME_BOOK_SELECTED_PDF_URL object:self userInfo:@{NOTIF_KEY_BOOK:book}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    // Save current book in NSUserDefaults
    [self saveLastSelectedBookAtIndexPath:indexPath];
    
    NSLog(@"Image path: %@",[book.photoURL absoluteString]);
}


#pragma mark - Utils
// Returns the book at a specified index path
- (DTCBook *) bookAtIndexPath: (NSIndexPath *)indexPath{
    DTCBook *book = nil;
    if (indexPath.section == 0) {
        book = [self.favoriteBooks objectAtIndex:indexPath.row];
    }
    else{
        book = [self.model bookForTag:[self.model.tags objectAtIndex:indexPath.section -1] atIndex:indexPath.row];
    }
    return book;
}


#pragma mark - Auto delegate (por iphones)
// Push the detail view controller of the book selected
- (void) libraryTableViewController:(DTCLibraryTableViewController *)libraryVC didSelectBook:(DTCBook *)aBook{
    DTCBookViewController *bookVC = [[DTCBookViewController alloc]initWithModel:aBook];
    [self.navigationController pushViewController:bookVC animated:YES];
}

#pragma mark - Notifications
- (void) notifyThatBookDidToggleFavorite: (NSNotification *) notification{
    // Get the book
    NSDictionary *dict = [notification userInfo];
    DTCBook *book = [dict objectForKey:NOTIF_KEY_BOOK_FAVORITE];
    
    // Check favorite status and add/remove it from favorites
    if (book.favorite) {
        if (![self.favoriteBooks containsObject:book]) {
            [self.favoriteBooks addObject:book];
        }
    }
    else{
        if ([self.favoriteBooks containsObject:book]) {
            [self.favoriteBooks removeObject:book];
        }
    }
    
    // Reload table data
    [self.tableView reloadData];
}

#pragma mark - Persistence
- (void) saveLastSelectedBookAtIndexPath: (NSIndexPath *) indexPath {
    // Get NSUserDefaults and save coords of the current selected book
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *coords = @[@(indexPath.section),@(indexPath.row)];
    [defaults setObject:coords forKey:LAST_SELECTED_BOOK];
    
    [defaults synchronize];
}

@end
