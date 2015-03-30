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

@import UIKit;

@interface DTCLibraryTableViewController ()

@end

@implementation DTCLibraryTableViewController

#pragma mark - Instance init
- (id) initWithModel:(DTCLibrary *)model style:(UITableViewStyle)aStyle{
    if(self = [super initWithStyle:aStyle]){
        self.model = model;
        self.favoriteBooks = [NSMutableArray arrayWithCapacity:0];
        self.title = @"Nerds library";
    }
    return self;
}

#pragma mark - View Lifecycle
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self syncModelWithView];
    
}

#pragma mark - Memory
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    cell.detailTextLabel.text = [book convertToString:book.authors];
    
    // Return cell with the book
    return cell;
}

#pragma mark - Table view delegate
// Show the book of the current indexPath
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Tell the delegate (Book Model) that the model has changed
    DTCBook *book = [self bookAtIndexPath:indexPath];
    
    // Notify the delegate (book model) that the model has changed (only if the delegate understands the message [implements it])
    if([self.delegate respondsToSelector:@selector(libraryTableViewController:didSelectBook:)]){
        [self.delegate libraryTableViewController:self didSelectBook:book];
    }
    
    // Notify the PDFViewer that the model has changed through notifications. Send the new selected book
    NSNotification *notification = [NSNotification notificationWithName:NOTIF_NAME_BOOK_SELECTED_PDF_URL object:self userInfo:@{NOTIF_KEY_BOOK:book}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
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

@end