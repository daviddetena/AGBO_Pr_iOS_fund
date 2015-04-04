//
//  DTCBookTableViewCell.m
//  HackerBooks
//
//  Created by David de Tena on 04/04/15.
//  Copyright (c) 2015 David de Tena. All rights reserved.
//

#import "DTCBookTableViewCell.h"

@implementation DTCBookTableViewCell


#pragma mark - Class Methods
// Use the name of the class as its cell ID
+ (NSString *) cellId{
    return NSStringFromClass(self);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)prepareForReuse{
    // Deinitialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
