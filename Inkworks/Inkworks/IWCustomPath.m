//
//  IWCustomPath.m
//  Inkworks
//
//  Created by Jamie Duggan on 19/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWCustomPath.h"

@implementation IWCustomPath

@synthesize path, xArray, yArray, origin;

- (id)initWithOrigin:(struct CGPoint)ori{
    self = [super init];
    if (self){
        self.origin = ori;
        xArray = [NSMutableArray array];
        yArray = [NSMutableArray array];
    }
    return self;
}

- (void)moveTo:(struct CGPoint)p {
    path = [[UIBezierPath alloc] init];
    [path moveToPoint:p];
    [xArray addObject:[NSNumber numberWithInt:p.x + origin.x]];
    [yArray addObject:[NSNumber numberWithInt:p.y + origin.y]];
}

- (void)pathTo:(struct CGPoint)p{
    [path addLineToPoint:p];
    [xArray addObject:[NSNumber numberWithInt:p.x + origin.x]];
    [yArray addObject:[NSNumber numberWithInt:p.y + origin.y]];
}

- (float)getMinX {
    if ([xArray count] == 0) return 0;
    float xmin = MAXFLOAT;
    for (NSNumber *num in xArray){
        float xval = num.floatValue;
        if (xval < xmin) xmin = xval;
    }
    return xmin;
}

- (float)getMaxX{
    if ([xArray count] == 0) return 0;
    float xmax = -MAXFLOAT;
    for (NSNumber *num in xArray){
        float xval = num.floatValue;
        if (xval > xmax) xmax = xval;
    }
    return xmax;
}

- (float)getMinY {
    if ([yArray count] == 0) return 0;
    float ymin = MAXFLOAT;
    for (NSNumber *num in yArray){
        float yval = num.floatValue;
        if (yval < ymin) ymin = yval;
    }
    return ymin;
}

- (float)getMaxY{
    if ([yArray count] == 0) return 0;
    float ymax = -MAXFLOAT;
    for (NSNumber *num in yArray){
        float yval = num.floatValue;
        if (yval > ymax) ymax = yval;
    }
    return ymax;
}

@end
