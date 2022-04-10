//
//  IWNonClippingLabel.m
//  Inkworks
//
//  Created by Jamie Duggan on 18/07/2016.
//  Copyright © 2016 Destiny Wireless. All rights reserved.
//

#import "IWNonClippingLabel.h"

@implementation IWNonClippingLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)drawRect:(CGRect)rect
{
    // fixes word wrapping issue
    CGRect newRect = rect;
    newRect.origin.x = rect.origin.x + GUTTER;
    newRect.size.width = rect.size.width;// - 2 * GUTTER;
    [self.attributedText drawInRect:newRect];
}

- (UIEdgeInsets)alignmentRectInsets
{
    return UIEdgeInsetsMake(0, GUTTER, 0, GUTTER);
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [super intrinsicContentSize];
    size.width += 2 * GUTTER;
    return size;
}

-(CGSize)sizeThatFits:(CGSize)size
{
    CGSize size_ = [super sizeThatFits:size];
    size_.width += 2 * GUTTER;
    return size_;
}

@end
