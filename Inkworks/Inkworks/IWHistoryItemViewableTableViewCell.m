//
//  IWHistoryItemViewableTableViewCell.m
//  Inkworks
//
//  Created by Jamie Duggan on 14/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWHistoryItemViewableTableViewCell.h"

@implementation IWHistoryItemViewableTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
