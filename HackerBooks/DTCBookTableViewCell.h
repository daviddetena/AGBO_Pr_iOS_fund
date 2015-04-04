//
//  DTCBookTableViewCell.h
//  HackerBooks
//
//  Created by David de Tena on 04/04/15.
//  Copyright (c) 2015 David de Tena. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTCBookTableViewCell : UITableViewCell

#pragma mark - Properties
@property (weak, nonatomic) IBOutlet UIImageView *bookIcon;
@property (weak, nonatomic) IBOutlet UIImageView *downloadIcon;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *authors;

#pragma mark - Class methods
+ (NSString *) cellId;

@end
