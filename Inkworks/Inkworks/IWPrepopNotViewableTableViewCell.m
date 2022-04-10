//
//  IWPrepopNotViewableTableViewCell.m
//  Inkworks
//
//  Created by Paul Gowing on 25/01/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

#import "IWPrepopNotViewableTableViewCell.h"

@implementation IWPrepopNotViewableTableViewCell

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
