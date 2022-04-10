//
//  IWCircleDescriptor.h
//  Inkworks
//
//  Created by Jamie Duggan on 12/02/2016.
//  Copyright © 2016 Destiny Wireless. All rights reserved.
//

#import "IWShapeDescriptor.h"

#define FILL @"fill"

@interface IWCircleDescriptor : IWShapeDescriptor {
    float cX;
    float cY;
    float r;
}

@property float cX;
@property float cY;
@property float r;

- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder;
- (id) initWithOriginal:(IWCircleDescriptor *)original;
+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder;
+ (id) newWithOriginal:(IWCircleDescriptor *)original;

@end
