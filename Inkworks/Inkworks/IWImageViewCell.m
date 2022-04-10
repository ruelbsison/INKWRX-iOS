//
//  IWImageViewCell.m
//  Inkworks
//
//  Created by Jamie Duggan on 13/06/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWImageViewCell.h"

@implementation IWImageViewCell

@synthesize imageView, imageTypeIcon, loadedImage, loadedURL;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
