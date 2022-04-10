//
//  IWLineDescriptor.h
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//

#define X1 @"x1"
#define X2 @"x2"
#define Y1 @"y1"
#define Y2 @"y2"


#import "IWShapeDescriptor.h"

@interface IWLineDescriptor : IWShapeDescriptor {
    NSString *lineType;
    
    long x1;
    long x2;
    long y1;
    long y2;
}

@property NSString *lineType;
@property long x1;
@property long x2;
@property long y1;
@property long y2;

+ (id) newWithXml: (GDataXMLElement *) aXml atZOrder:(int) aZOrder;
+ (id) newWithOriginal: (IWLineDescriptor *) original;
@end
