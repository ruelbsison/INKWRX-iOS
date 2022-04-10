//
//  IWRoundedRectangleDescriptor.h
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//

#define RADIUS_X @"rx"
#define RADIUS_Y @"ry"

#import "IWRectangleDescriptor.h"

@interface IWRoundedRectangleDescriptor : IWRectangleDescriptor {
    float rX;
    float rY;
}

@property float rX;
@property float rY;

+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder;
+ (id) newWithOriginal:(IWRoundedRectangleDescriptor *)original;
@end
