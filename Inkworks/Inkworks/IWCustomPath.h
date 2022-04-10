//
//  IWCustomPath.h
//  Inkworks
//
//  Created by Jamie Duggan on 19/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWCustomPath : NSObject {
    NSMutableArray *xArray;
    NSMutableArray *yArray;
    struct CGPoint origin;
    UIBezierPath *path;
}

@property UIBezierPath *path;
@property struct CGPoint origin;
@property NSMutableArray *xArray;
@property NSMutableArray *yArray;

- (id) initWithOrigin: (struct CGPoint) ori;

- (void) moveTo: (struct CGPoint) p;
- (void) pathTo: (struct CGPoint) p;

- (float) getMinX;
- (float) getMaxX;
- (float) getMinY;
- (float) getMaxY;

@end
