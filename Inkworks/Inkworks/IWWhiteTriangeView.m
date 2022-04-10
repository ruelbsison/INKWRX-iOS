//
//  IWWhiteTriangeView.m
//  Inkworks
//
//  Created by Jamie Duggan on 22/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWWhiteTriangeView.h"

@implementation IWWhiteTriangeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:rect.origin];
    [path addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y)];
    [path addLineToPoint:CGPointMake((rect.origin.x + rect.size.width) / 2, rect.origin.y + rect.size.height)];
    [path closePath];
    [[UIColor whiteColor] setFill];
    [path fill];
}


@end
